import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/supabase_config.dart';
import '../../../../shared/models/team_invitation_model.dart';

// Nombres de equipos por lista de IDs
// Nombres de equipos por IDs (usar firma estable para evitar loops por igualdad de listas)
// Arg: firma CSV ordenada de IDs, p.ej. "id1,id2,id3"
final teamNamesByIdsProvider =
    FutureProvider.family<Map<String, String>, String>((ref, idsCsv) async {
      final supabase = ref.watch(supabaseProvider);
      if (idsCsv.isEmpty) return {};
      final ids = idsCsv.split(',').where((e) => e.isNotEmpty).toList();
      if (ids.isEmpty) return {};
      try {
        final rows = await supabase
            .from('teams')
            .select('id, name')
            .inFilter('id', ids);
        return {
          for (final r in (rows as List))
            (r['id'] ?? '').toString(): (r['name'] ?? 'Equipo') as String,
        };
      } catch (_) {
        return {};
      }
    });

// Invitaciones de equipo pendientes (vivo) enriquecidas con nombres
final pendingTeamInvitationsProvider = StreamProvider<List<TeamInvitationView>>(
  (ref) async* {
    final supabase = ref.watch(supabaseProvider);
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) {
      yield [];
      return;
    }

    Future<List<TeamInvitationView>> fetchInvites() async {
      final invRows = await supabase
          .from('team_invitations')
          .select(
            'id, team_id, inviter_user_id, invited_user_id, status, created_at',
          )
          .eq('invited_user_id', uid)
          .eq('status', 'pending')
          .order('created_at');

      final invitations =
          (invRows as List).map((e) => TeamInvitationModel.fromMap(e)).toList();
      if (invitations.isEmpty) return [];

      final teamIds = invitations.map((i) => i.teamId).toSet().toList();
      final inviterIds =
          invitations.map((i) => i.inviterUserId).toSet().toList();

      final teamRows = await supabase
          .from('teams')
          .select('id, name')
          .inFilter('id', teamIds);
      final teamsById = {
        for (final t in (teamRows as List))
          (t['id'] ?? '').toString(): (t['name'] ?? 'Equipo') as String,
      };

      final inviterRows = await supabase
          .from('profiles')
          .select('id, full_name')
          .inFilter('id', inviterIds);
      final invitersById = {
        for (final p in (inviterRows as List))
          (p['id'] ?? '').toString(): (p['full_name'] ?? 'Jugador') as String,
      };

      return invitations
          .map(
            (inv) => TeamInvitationView(
              invitation: inv,
              teamName: teamsById[inv.teamId] ?? 'Equipo',
              inviterName: invitersById[inv.inviterUserId] ?? 'Jugador',
            ),
          )
          .toList();
    }

    final controller = StreamController<List<TeamInvitationView>>.broadcast();
    // Dedupe por firma (id:status); no necesitamos guardar la lista anterior
    String? lastSig;
    String signature(List<TeamInvitationView> list) {
      final items =
          list.map((v) => '${v.invitation.id}:${v.invitation.status}').toList()
            ..sort();
      return items.join('|');
    }

    Timer? debounce;
    bool computing = false;
    void scheduleEmit() {
      debounce?.cancel();
      debounce = Timer(const Duration(milliseconds: 200), () async {
        if (computing) return;
        computing = true;
        final value = await fetchInvites();
        final sig = signature(value);
        if (sig != lastSig) {
          lastSig = sig;
          controller.add(value);
        }
        computing = false;
      });
    }

    // Primera carga debounced
    scheduleEmit();

    final ch =
        supabase.channel('notifications:team_invitations')
          ..onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'team_invitations',
            callback: (payload) async {
              try {
                // payload es PostgresChangePayload con newRecord/oldRecord
                final newRec = (payload as dynamic).newRecord as Map?;
                final oldRec = (payload as dynamic).oldRecord as Map?;
                bool related = false;
                if (newRec != null) {
                  final invited = newRec['invited_user_id']?.toString();
                  if (invited == uid) related = true;
                }
                if (!related && oldRec != null) {
                  final invited = oldRec['invited_user_id']?.toString();
                  if (invited == uid) related = true;
                }
                if (!related) return; // ignora eventos de otros usuarios
              } catch (_) {
                // Si no podemos inspeccionar, dejamos que pase por debounce
              }
              scheduleEmit();
            },
          )
          ..subscribe();

    ref.onDispose(() {
      controller.close();
      debounce?.cancel();
      supabase.removeChannel(ch);
    });

    yield* controller.stream;
  },
);

// Contador global: invitaciones equipo + solicitudes amistad + notificaciones (si existen) + chats con no leídos
final notificationsBadgeCountProvider = StreamProvider<int>((ref) async* {
  final supabase = ref.watch(supabaseProvider);
  final uid = supabase.auth.currentUser?.id;
  if (uid == null) {
    yield 0;
    return;
  }

  var skipNotificationsQuery = false; // evita loops por 404
  int? lastEmitted;
  bool computing = false;
  Timer? debounce;

  Future<int> computeCount() async {
    try {
      final invites = await supabase
          .from('team_invitations')
          .select('id')
          .eq('invited_user_id', uid)
          .eq('status', 'pending');
      final friendReqs = await supabase
          .from('friendships')
          .select('id')
          .eq('receiver_id', uid)
          .eq('status', 'pending');

      List<dynamic> unread = const [];
      if (!skipNotificationsQuery) {
        try {
          final res = await supabase
              .from('notifications')
              .select('id')
              .eq('user_id', uid)
              .eq('is_read', false);
          unread = res as List;
        } catch (_) {
          skipNotificationsQuery = true; // tabla no existe
          unread = const [];
        }
      }

      int chats = 0;
      try {
        final res = await supabase.rpc(
          'get_unread_conversations_count',
          params: {'p_user': uid},
        );
        if (res is int) chats = res;
        if (res is String) chats = int.tryParse(res) ?? 0;
      } catch (_) {
        chats = 0;
      }

      return (invites as List).length +
          (friendReqs as List).length +
          unread.length +
          chats;
    } catch (_) {
      return 0;
    }
  }

  final controller = StreamController<int>.broadcast();

  void scheduleEmit() {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 200), () async {
      if (computing) return;
      computing = true;
      final value = await computeCount();
      if (value != lastEmitted) {
        lastEmitted = value;
        controller.add(value);
      }
      computing = false;
    });
  }

  scheduleEmit();

  final ch1 =
      supabase.channel('badge:team_invitations')
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'team_invitations',
          callback: (_) async => scheduleEmit(),
        )
        ..subscribe();
  final ch2 =
      supabase.channel('badge:friendships')
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'friendships',
          callback: (_) async => scheduleEmit(),
        )
        ..subscribe();
  final ch3 =
      supabase.channel('badge:notifications')
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications',
          callback: (_) async => scheduleEmit(),
        )
        ..subscribe();
  final ch4 =
      supabase.channel('badge:messages')
        ..onPostgresChanges(
          event:
              PostgresChangeEvent
                  .insert, // sólo nuevos mensajes afectan no leídos
          schema: 'public',
          table: 'messages',
          callback: (_) async => scheduleEmit(),
        )
        ..subscribe();
  final ch5 =
      supabase.channel('badge:last_seen_chat')
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'last_seen_chat',
          callback: (_) async => scheduleEmit(),
        )
        ..subscribe();

  ref.onDispose(() {
    controller.close();
    debounce?.cancel();
    supabase.removeChannel(ch1);
    supabase.removeChannel(ch2);
    supabase.removeChannel(ch3);
    supabase.removeChannel(ch4);
    supabase.removeChannel(ch5);
  });

  yield* controller.stream;
});

// Unread chat por equipo: { teamId: unread }
final unreadChatByTeamProvider = StreamProvider<Map<String, int>>((ref) async* {
  final supabase = ref.watch(supabaseProvider);
  final uid = supabase.auth.currentUser?.id;
  if (uid == null) {
    yield const {};
    return;
  }

  Future<Map<String, int>> fetchMap() async {
    try {
      final res = await supabase.rpc(
        'get_unread_by_team',
        params: {'p_user': uid},
      );
      final list = (res as List).cast<Map<String, dynamic>>();
      final map = <String, int>{};
      for (final row in list) {
        final teamId = row['team_id'] as String;
        final unread =
            (row['unread'] is int)
                ? row['unread'] as int
                : int.tryParse(row['unread'].toString()) ?? 0;
        map[teamId] = unread;
      }
      return map;
    } catch (_) {
      return {};
    }
  }

  final controller = StreamController<Map<String, int>>.broadcast();
  Timer? debounce;
  bool computing = false;
  Map<String, int>? lastEmitted;

  void scheduleEmit() {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 200), () async {
      if (computing) return;
      computing = true;
      final value = await fetchMap();
      if (value.toString() != lastEmitted?.toString()) {
        lastEmitted = value;
        controller.add(value);
      }
      computing = false;
    });
  }

  scheduleEmit();

  final chMsg =
      supabase.channel('unread:messages')
        ..onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (_) async => scheduleEmit(),
        )
        ..subscribe();
  final chSeen =
      supabase.channel('unread:last_seen_chat')
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'last_seen_chat',
          callback: (_) async => scheduleEmit(),
        )
        ..subscribe();

  ref.onDispose(() {
    controller.close();
    debounce?.cancel();
    supabase.removeChannel(chMsg);
    supabase.removeChannel(chSeen);
  });

  yield* controller.stream;
});
