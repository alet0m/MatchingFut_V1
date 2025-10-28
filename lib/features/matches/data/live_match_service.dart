// ignore_for_file: avoid_print

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/match_model.dart';

class LiveMatchService {
  final SupabaseClient _supabase;

  LiveMatchService(this._supabase);

  // Obtener partido en vivo
  Future<MatchModel> getLiveMatch(String matchId) async {
    final response =
        await _supabase.from('matches').select('*').eq('id', matchId).single();

    return MatchModel.fromJson(_mapMatchFromDatabase(response));
  }

  // Stream de partido en tiempo real
  Stream<MatchModel> watchLiveMatch(String matchId) {
    return _supabase
        .from('matches')
        .stream(primaryKey: ['id'])
        .eq('id', matchId)
        .map(
          (data) =>
              data.isNotEmpty
                  ? MatchModel.fromJson(_mapMatchFromDatabase(data.first))
                  : throw Exception('Partido no encontrado'),
        );
  }

  // Iniciar partido
  Future<MatchModel> startMatch(String matchId) async {
    final response =
        await _supabase
            .from('matches')
            .update({'status': 'in_progress'})
            .eq('id', matchId)
            .select()
            .single();

    return MatchModel.fromJson(_mapMatchFromDatabase(response));
  }

  // Finalizar partido
  Future<MatchModel> endMatch(String matchId) async {
    final response =
        await _supabase
            .from('matches')
            .update({'status': 'finished'})
            .eq('id', matchId)
            .select()
            .single();

    return MatchModel.fromJson(_mapMatchFromDatabase(response));
  }

  // Agregar gol
  Future<MatchModel> addGoal(String matchId, String teamId) async {
    // Primero obtener el partido actual
    final currentMatch = await getLiveMatch(matchId);

    // Incrementar el marcador del equipo correspondiente
    int newHomeScore = currentMatch.homeScore;
    int newAwayScore = currentMatch.awayScore;

    if (teamId == currentMatch.homeTeamId) {
      newHomeScore++;
    } else if (teamId == currentMatch.awayTeamId) {
      newAwayScore++;
    }

    // Actualizar en la base de datos
    final response =
        await _supabase
            .from('matches')
            .update({'home_score': newHomeScore, 'away_score': newAwayScore})
            .eq('id', matchId)
            .select()
            .single();

    return MatchModel.fromJson(_mapMatchFromDatabase(response));
  }

  // Restar gol (en caso de error)
  Future<MatchModel> removeGoal(String matchId, String teamId) async {
    final currentMatch = await getLiveMatch(matchId);

    int newHomeScore = currentMatch.homeScore;
    int newAwayScore = currentMatch.awayScore;

    if (teamId == currentMatch.homeTeamId && newHomeScore > 0) {
      newHomeScore--;
    } else if (teamId == currentMatch.awayTeamId && newAwayScore > 0) {
      newAwayScore--;
    }

    final response =
        await _supabase
            .from('matches')
            .update({'home_score': newHomeScore, 'away_score': newAwayScore})
            .eq('id', matchId)
            .select()
            .single();

    return MatchModel.fromJson(_mapMatchFromDatabase(response));
  }

  // Pausar partido
  Future<void> pauseMatch(String matchId) async {
    // Esta funcionalidad se maneja en el cliente, no necesita actualizar DB
    // Solo para control local del timer
  }

  // Reanudar partido
  Future<void> resumeMatch(String matchId) async {
    // Esta funcionalidad se maneja en el cliente, no necesita actualizar DB
    // Solo para control local del timer
  }

  // Obtener estadísticas en vivo
  Future<Map<String, dynamic>> getLiveStats(String matchId) async {
    try {
      // Obtener eventos del partido
      final eventsResponse = await _supabase
          .from('match_events')
          .select('event_type, team_id')
          .eq('match_id', matchId);

      final stats = <String, Map<String, int>>{};

      for (final event in eventsResponse) {
        final eventType = event['event_type'] as String;
        final teamId = event['team_id'] as String;

        if (!stats.containsKey(teamId)) {
          stats[teamId] = {};
        }

        stats[teamId]![eventType] = (stats[teamId]![eventType] ?? 0) + 1;
      }

      return {'events_by_team': stats, 'total_events': eventsResponse.length};
    } catch (e) {
      print('Error al obtener estadísticas en vivo: $e');
      return {};
    }
  }

  // Mapear desde base de datos
  Map<String, dynamic> _mapMatchFromDatabase(Map<String, dynamic> dbMatch) {
    return {
      'id': dbMatch['id'],
      'homeTeamId': dbMatch['home_team_id'],
      'awayTeamId': dbMatch['away_team_id'],
      'canchaId': dbMatch['cancha_id'],
      'sectorId': dbMatch['sector_id'],
      'comunaName': dbMatch['comuna_name'],
      'canchaName': dbMatch['cancha_name'],
      'matchDate':
          dbMatch['match_date'] != null
              ? DateTime.parse(
                dbMatch['match_date'] as String,
              ).toIso8601String()
              : DateTime.now().toIso8601String(),
      'status': dbMatch['status'] ?? 'scheduled',
      'homeScore': dbMatch['home_score'] ?? 0,
      'awayScore': dbMatch['away_score'] ?? 0,
      'eloChange': dbMatch['elo_change'] ?? 0,
      'createdBy': dbMatch['created_by'],
      'createdAt':
          dbMatch['created_at'] != null
              ? DateTime.parse(
                dbMatch['created_at'] as String,
              ).toIso8601String()
              : DateTime.now().toIso8601String(),
    };
  }
}

// Providers
final liveMatchServiceProvider = Provider<LiveMatchService>((ref) {
  return LiveMatchService(Supabase.instance.client);
});

// Provider para partido en vivo
final liveMatchProvider = FutureProvider.family<MatchModel, String>((
  ref,
  matchId,
) async {
  final service = ref.read(liveMatchServiceProvider);
  return service.getLiveMatch(matchId);
});

// Provider para stream de partido en tiempo real
final liveMatchStreamProvider = StreamProvider.family<MatchModel, String>((
  ref,
  matchId,
) {
  final service = ref.read(liveMatchServiceProvider);
  return service.watchLiveMatch(matchId);
});

// Provider para estadísticas en vivo
final liveStatsProvider = FutureProvider.family<Map<String, dynamic>, String>((
  ref,
  matchId,
) async {
  final service = ref.read(liveMatchServiceProvider);
  return service.getLiveStats(matchId);
});
