import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';
import '../../../shared/models/team_message_model.dart';

class TeamMessageChange {
  final String op; // 'insert' | 'update' | 'delete'
  final TeamMessage? newMessage;
  final TeamMessage? oldMessage;

  TeamMessageChange({required this.op, this.newMessage, this.oldMessage});
}

final teamChatRepositoryProvider = Provider<TeamChatRepository>((ref) {
  final client = ref.read(supabaseProvider);
  return TeamChatRepository(client);
});

class TeamChatRepository {
  final SupabaseClient _client;
  TeamChatRepository(this._client);

  String? get currentUserId => _client.auth.currentUser?.id;

  Future<List<TeamMessage>> fetchLatest({
    required String teamId,
    int limit = 50,
  }) async {
    final res = await _client
        .from('messages')
        .select()
        .eq('team_id', teamId)
        .order('created_at', ascending: false)
        .limit(limit);

    final list =
        (res as List)
            .cast<Map<String, dynamic>>()
            .map(TeamMessage.fromJson)
            .toList();

    // Convert to ASC for stable UI (oldest at top)
    return list.reversed.toList();
  }

  Future<List<TeamMessage>> fetchMore({
    required String teamId,
    required DateTime before,
    int limit = 50,
  }) async {
    // We page by created_at < before
    final res = await _client
        .from('messages')
        .select()
        .eq('team_id', teamId)
        .lt('created_at', before.toIso8601String())
        .order('created_at', ascending: false)
        .limit(limit);

    final list =
        (res as List)
            .cast<Map<String, dynamic>>()
            .map(TeamMessage.fromJson)
            .toList();

    return list.reversed.toList();
  }

  Stream<TeamMessageChange> subscribeChanges({required String teamId}) {
    final controller = StreamController<TeamMessageChange>.broadcast();

    final channel =
        _client.channel('team-messages-$teamId')
          ..onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'messages',
            callback: (payload) {
              final record = payload.newRecord;
              if (record['team_id'] == teamId) {
                controller.add(
                  TeamMessageChange(
                    op: 'insert',
                    newMessage: TeamMessage.fromJson(record),
                  ),
                );
              }
            },
          )
          ..onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'messages',
            callback: (payload) {
              final newRec = payload.newRecord;
              final oldRec = payload.oldRecord;
              if (newRec['team_id'] == teamId) {
                controller.add(
                  TeamMessageChange(
                    op: 'update',
                    newMessage: TeamMessage.fromJson(newRec),
                    oldMessage:
                        oldRec.isNotEmpty ? TeamMessage.fromJson(oldRec) : null,
                  ),
                );
              }
            },
          )
          ..onPostgresChanges(
            event: PostgresChangeEvent.delete,
            schema: 'public',
            table: 'messages',
            callback: (payload) {
              final oldRec = payload.oldRecord;
              if (oldRec['team_id'] == teamId) {
                controller.add(
                  TeamMessageChange(
                    op: 'delete',
                    oldMessage: TeamMessage.fromJson(oldRec),
                  ),
                );
              }
            },
          )
          ..subscribe();

    controller.onCancel = () {
      _client.removeChannel(channel);
    };

    return controller.stream;
  }

  Future<String> send({required String teamId, required String content}) async {
    final res = await _client.rpc(
      'send_team_message',
      params: {'p_team': teamId, 'p_content': content},
    );
    if (res is String) return res;
    // If Supabase returns { data: <uuid> } via postgrest, it may be already the uuid string
    return res.toString();
  }

  Future<void> updateMessage({
    required String messageId,
    required String newContent,
  }) async {
    await _client
        .from('messages')
        .update({'content': newContent})
        .eq('id', messageId);
  }

  Future<void> deleteMessage({required String messageId}) async {
    await _client.from('messages').delete().eq('id', messageId);
  }

  Future<void> setLastSeen(String teamId) async {
    try {
      await _client.rpc('set_last_seen_chat', params: {'p_team': teamId});
    } catch (_) {
      // Ignore silently to avoid disrupting UI
    }
  }

  Future<Map<String, String>> fetchUserNames(Set<String> ids) async {
    if (ids.isEmpty) return {};
    // Use 'in' filter API; in Supabase Dart v2, the method name is 'in_'.
    // Fallback: use 'or' if 'in_' is not available in this version.
    dynamic query = _client.from('profiles').select('id, full_name, tag');
    try {
      query = query.in_('id', ids.toList());
    } catch (_) {
      final ors = ids.map((e) => 'id.eq.$e').join(',');
      query = query.or(ors);
    }
    final res = await query;
    final list = (res as List).cast<Map<String, dynamic>>();
    final map = <String, String>{};
    for (final row in list) {
      final id = row['id'] as String;
      final fullName = row['full_name'] as String?;
      final tag = row['tag'] as String?;
      final name =
          (fullName != null && fullName.trim().isNotEmpty)
              ? fullName
              : (tag != null && tag.trim().isNotEmpty)
              ? '#$tag'
              : id.substring(0, 8);
      map[id] = name;
    }
    return map;
  }
}
