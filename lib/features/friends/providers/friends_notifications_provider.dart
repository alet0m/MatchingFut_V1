import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';

class FriendRequestEvent {
  final String type; // incoming, accepted, rejected
  final String fromUserId;
  final DateTime at;

  FriendRequestEvent({
    required this.type,
    required this.fromUserId,
    required this.at,
  });
}

// Stream de eventos de solicitudes de amistad en tiempo real
final friendRequestEventsProvider = StreamProvider.autoDispose<
  FriendRequestEvent?
>((ref) async* {
  final supabase = ref.watch(supabaseProvider);
  final uid = supabase.auth.currentUser?.id;
  if (uid == null) {
    yield null;
    return;
  }

  final controller = StreamController<FriendRequestEvent?>.broadcast();

  final channel =
      supabase.channel('public:friendships:notifications')
        ..onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'friendships',
          callback: (payload) {
            try {
              final newRec = payload.newRecord;
              if (newRec['receiver_id'] == uid &&
                  newRec['status'] == 'pending') {
                controller.add(
                  FriendRequestEvent(
                    type: 'incoming',
                    fromUserId: newRec['requester_id'] as String,
                    at: DateTime.now(),
                  ),
                );
              }
            } catch (_) {}
          },
        )
        ..onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'friendships',
          callback: (payload) {
            try {
              final newRec = payload.newRecord;
              final oldRec = payload.oldRecord;
              // Si una solicitud del usuario actual fue aceptada/rechazada
              if (newRec['requester_id'] == uid &&
                  newRec['status'] != 'pending') {
                controller.add(
                  FriendRequestEvent(
                    type: newRec['status'] as String, // accepted | rejected
                    fromUserId: newRec['receiver_id'] as String,
                    at: DateTime.now(),
                  ),
                );
              }
              // Si el usuario actual fue receptor y acaba de aceptar/rechazar
              if (newRec['receiver_id'] == uid &&
                  oldRec['status'] == 'pending' &&
                  newRec['status'] != 'pending') {
                controller.add(
                  FriendRequestEvent(
                    type: newRec['status'] as String,
                    fromUserId: newRec['requester_id'] as String,
                    at: DateTime.now(),
                  ),
                );
              }
            } catch (_) {}
          },
        )
        ..subscribe();

  ref.onDispose(() {
    controller.close();
    supabase.removeChannel(channel);
  });

  yield* controller.stream;
});

// Conteo reactivo de solicitudes pendientes del usuario actual
final pendingFriendRequestsCountProvider = StreamProvider.autoDispose<int>((
  ref,
) async* {
  final supabase = ref.watch(supabaseProvider);
  final uid = supabase.auth.currentUser?.id;
  if (uid == null) {
    yield 0;
    return;
  }

  // Emitir conteo inicial
  Future<int> fetchCount() async {
    final list = await supabase
        .from('friendships')
        .select('id')
        .eq('receiver_id', uid)
        .eq('status', 'pending');
    return (list as List).length;
  }

  final controller = StreamController<int>.broadcast();
  controller.add(await fetchCount());

  final channel =
      supabase.channel('public:friendships:pending_count')
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'friendships',
          callback: (payload) async {
            try {
              final newMap = payload.newRecord;
              final oldMap = payload.oldRecord;
              // Recalcular solo si el cambio afecta al usuario actual
              final affects =
                  (newMap['receiver_id'] == uid ||
                      newMap['requester_id'] == uid) ||
                  (oldMap['receiver_id'] == uid ||
                      oldMap['requester_id'] == uid);
              if (affects) {
                controller.add(await fetchCount());
              }
            } catch (_) {}
          },
        )
        ..subscribe();

  ref.onDispose(() {
    controller.close();
    supabase.removeChannel(channel);
  });

  yield* controller.stream;
});
