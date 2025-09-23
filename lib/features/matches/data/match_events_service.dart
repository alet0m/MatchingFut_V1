// ignore_for_file: avoid_print

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/match_event_model.dart';

class MatchEventsService {
  final SupabaseClient _supabase;

  MatchEventsService(this._supabase);

  // Obtener eventos de un partido
  Future<List<MatchEvent>> getMatchEvents(String matchId) async {
    try {
      final response = await _supabase
          .from('match_events')
          .select('*')
          .eq('match_id', matchId)
          .order('minute', ascending: true)
          .order('created_at', ascending: true);

      return response
          .map<MatchEvent>(
            (json) => MatchEvent.fromJson(_mapEventFromDatabase(json)),
          )
          .toList();
    } catch (e) {
      print('Error al obtener eventos del partido: $e');
      return [];
    }
  }

  // Agregar nuevo evento
  Future<MatchEvent> addEvent({
    required String matchId,
    required String eventType,
    required String teamId,
    String? playerId,
    required int minute,
    String? description,
    Map<String, dynamic>? extraData,
  }) async {
    final eventData = {
      'match_id': matchId,
      'event_type': eventType,
      'team_id': teamId,
      'player_id': playerId,
      'minute': minute,
      'description': description,
      'extra_data': extraData ?? {},
      'created_at': DateTime.now().toIso8601String(),
    };

    final response =
        await _supabase
            .from('match_events')
            .insert(eventData)
            .select()
            .single();

    return MatchEvent.fromJson(_mapEventFromDatabase(response));
  }

  // Stream de eventos en tiempo real
  Stream<List<MatchEvent>> watchMatchEvents(String matchId) {
    return _supabase
        .from('match_events')
        .stream(primaryKey: ['id'])
        .eq('match_id', matchId)
        .order('minute', ascending: true)
        .map(
          (data) =>
              data
                  .map<MatchEvent>(
                    (json) => MatchEvent.fromJson(_mapEventFromDatabase(json)),
                  )
                  .toList(),
        );
  }

  // Obtener estadísticas de eventos por tipo
  Future<Map<String, int>> getEventStats(String matchId) async {
    try {
      final response = await _supabase
          .from('match_events')
          .select('event_type')
          .eq('match_id', matchId);

      final stats = <String, int>{};
      for (final event in response) {
        final eventType = event['event_type'] as String;
        stats[eventType] = (stats[eventType] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      print('Error al obtener estadísticas de eventos: $e');
      return {};
    }
  }

  // Eliminar evento
  Future<void> deleteEvent(String eventId) async {
    await _supabase.from('match_events').delete().eq('id', eventId);
  }

  // Mapear desde base de datos
  Map<String, dynamic> _mapEventFromDatabase(Map<String, dynamic> dbEvent) {
    return {
      'id': dbEvent['id'],
      'matchId': dbEvent['match_id'],
      'eventType': dbEvent['event_type'],
      'playerId': dbEvent['player_id'],
      'teamId': dbEvent['team_id'],
      'minute': dbEvent['minute'] ?? 0,
      'description': dbEvent['description'],
      'extraData': dbEvent['extra_data'] ?? {},
      'createdAt':
          dbEvent['created_at'] != null
              ? DateTime.parse(
                dbEvent['created_at'] as String,
              ).toIso8601String()
              : DateTime.now().toIso8601String(),
    };
  }
}

// Providers
final matchEventsServiceProvider = Provider<MatchEventsService>((ref) {
  return MatchEventsService(Supabase.instance.client);
});

// Provider para eventos de un partido específico
final matchEventsProvider = FutureProvider.family<List<MatchEvent>, String>((
  ref,
  matchId,
) async {
  final service = ref.read(matchEventsServiceProvider);
  return service.getMatchEvents(matchId);
});

// Provider para stream de eventos en tiempo real
final matchEventsStreamProvider =
    StreamProvider.family<List<MatchEvent>, String>((ref, matchId) {
      final service = ref.read(matchEventsServiceProvider);
      return service.watchMatchEvents(matchId);
    });

// Provider para estadísticas de eventos
final eventStatsProvider = FutureProvider.family<Map<String, int>, String>((
  ref,
  matchId,
) async {
  final service = ref.read(matchEventsServiceProvider);
  return service.getEventStats(matchId);
});
