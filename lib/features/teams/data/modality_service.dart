import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/models/football_modality.dart';
import '../../../../shared/models/team_elo_model.dart';

class ModalityService {
  final SupabaseClient _supabase;

  ModalityService(this._supabase);

  /// Obtener ELO de un equipo por modalidad
  Future<TeamEloModel?> getTeamEloByModality(
    String teamId,
    FootballModality modality,
  ) async {
    try {
      final response =
          await _supabase
              .from('team_elo_by_modality')
              .select()
              .eq('team_id', teamId)
              .eq('modality', modality.value)
              .maybeSingle();

      if (response == null) return null;

      return TeamEloModel.fromJson({...response, 'modality': modality.value});
    } catch (e) {
      print('Error obteniendo ELO del equipo: $e');
      return null;
    }
  }

  /// Obtener estadísticas de jugador por modalidad
  Future<PlayerModalityStats?> getPlayerStatsByModality(
    String userId,
    FootballModality modality,
  ) async {
    try {
      final response =
          await _supabase
              .from('player_modality_stats')
              .select()
              .eq('user_id', userId)
              .eq('modality', modality.value)
              .maybeSingle();

      if (response == null) return null;

      return PlayerModalityStats.fromJson({
        ...response,
        'modality': modality.value,
      });
    } catch (e) {
      print('Error obteniendo stats del jugador: $e');
      return null;
    }
  }

  /// Inicializar estadísticas de equipo para todas las modalidades
  Future<bool> initializeTeamStats(String teamId) async {
    try {
      final batch = <Map<String, dynamic>>[];

      for (final modality in FootballModality.values) {
        batch.add({
          'team_id': teamId,
          'modality': modality.value,
          'elo_rating': 1200,
          'matches_played': 0,
          'wins': 0,
          'losses': 0,
          'draws': 0,
          'goals_for': 0,
          'goals_against': 0,
        });
      }

      await _supabase.from('team_elo_by_modality').upsert(batch);
      return true;
    } catch (e) {
      print('Error inicializando stats del equipo: $e');
      return false;
    }
  }

  /// Inicializar estadísticas de jugador para una modalidad
  Future<bool> initializePlayerStats(
    String userId,
    FootballModality modality, {
    SkillLevel skillLevel = SkillLevel.principiante,
    String? preferredPosition,
  }) async {
    try {
      await _supabase.from('player_modality_stats').upsert({
        'user_id': userId,
        'modality': modality.value,
        'skill_level': skillLevel.value,
        'preferred_position': preferredPosition,
        'matches_played': 0,
        'goals': 0,
        'assists': 0,
        'rating_avg': 0.0,
        'is_active': true,
      });
      return true;
    } catch (e) {
      print('Error inicializando stats del jugador: $e');
      return false;
    }
  }

  /// Obtener ranking de equipos por modalidad
  Future<List<Map<String, dynamic>>> getModalityRanking(
    FootballModality modality, {
    String? comuna,
    int limit = 50,
  }) async {
    try {
      var query = _supabase.rpc(
        'get_modality_ranking',
        params: {'modality_param': modality.value, 'limit_param': limit},
      );

      if (comuna != null) {
        // Filtrar por comuna en el cliente por ahora
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error obteniendo ranking: $e');
      return [];
    }
  }

  /// Buscar jugadores por modalidad y nivel
  Future<List<Map<String, dynamic>>> searchPlayersByModality(
    FootballModality modality, {
    SkillLevel? skillLevel,
    String? position,
    String? comuna,
  }) async {
    try {
      var query = _supabase
          .from('player_modality_stats')
          .select('''
            *,
            profiles:user_id (
              id,
              first_name,
              last_name,
              profile_picture_url,
              comuna
            )
          ''')
          .eq('modality', modality.value)
          .eq('is_active', true);

      if (skillLevel != null) {
        query = query.eq('skill_level', skillLevel.value);
      }

      if (position != null) {
        query = query.eq('preferred_position', position);
      }

      final response = await query.limit(50);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error buscando jugadores: $e');
      return [];
    }
  }

  /// Obtener posiciones disponibles por modalidad
  List<PlayerPosition> getPositionsByModality(FootballModality modality) {
    return modality.availablePositions;
  }

  /// Actualizar ELO después de un partido
  Future<bool> updateEloAfterMatch({
    required String teamId,
    required FootballModality modality,
    required int newElo,
    required bool won,
    required bool lost,
    required bool draw,
    required int goalsFor,
    required int goalsAgainst,
  }) async {
    try {
      await _supabase.rpc(
        'update_team_elo_after_match',
        params: {
          'team_id_param': teamId,
          'modality_param': modality.value,
          'new_elo_param': newElo,
          'won_param': won,
          'lost_param': lost,
          'draw_param': draw,
          'goals_for_param': goalsFor,
          'goals_against_param': goalsAgainst,
        },
      );
      return true;
    } catch (e) {
      print('Error actualizando ELO: $e');
      return false;
    }
  }
}
