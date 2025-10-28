import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/models/team_model.dart';

/// Servicio para gestionar los rankings de equipos y territorios
class RankingService {
  final _supabase = Supabase.instance.client;

  /// Obtiene el ranking global de equipos ordenados por ELO
  Future<List<TeamModel>> getGlobalRankings() async {
    try {
      final response = await _supabase
          .from('teams')
          .select('*')
          // Cambiar a 'elo_rating' (average_elo no existe)
          .order('elo_rating', ascending: false)
          .limit(50);

      return response.map((data) => TeamModel.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error obteniendo ranking global: $e');
      return [];
    }
  }

  /// Obtiene el ranking de equipos de una comuna específica
  Future<List<TeamModel>> getComunaRankings(String comunaId) async {
    try {
      final response = await _supabase
          .from('teams')
          .select('*')
          .eq('comuna_id', comunaId)
          // Cambiar a 'elo_rating' (average_elo no existe)
          .order('elo_rating', ascending: false)
          .limit(50);

      return response.map((data) => TeamModel.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error obteniendo ranking de comuna: $e');
      return [];
    }
  }

  /// Obtiene los equipos que controlan sectores en una comuna
  Future<List<TeamModel>> getSectorControllers(String comunaId) async {
    try {
      // 1) Obtener los sectores de la comuna
      final sectors = await _supabase
          .from('sectors')
          .select('id')
          .eq('comuna_id', comunaId)
          .eq('is_active', true);

      if (sectors.isEmpty) return [];
      final sectorIds = sectors.map<String>((s) => s['id'] as String).toList();

      // 2) Buscar historial de control para esos sectores (equipos recientes)
      final history = await _supabase
          .from('sector_control_history')
          .select('team_id, teams(*)')
          .inFilter('sector_id', sectorIds)
          .order('control_start', ascending: false)
          .limit(200);

      final Map<String, TeamModel> uniqueTeams = {};
      for (final row in history) {
        final team = TeamModel.fromJson(row['teams'] as Map<String, dynamic>);
        uniqueTeams[team.id] = team;
      }

      return uniqueTeams.values.toList();
    } catch (e) {
      debugPrint('Error obteniendo controladores de sectores: $e');
      return [];
    }
  }

  /// Obtiene el historial de ELO de un equipo para gráficos
  Future<List<Map<String, dynamic>>> getTeamEloHistory(String teamId) async {
    try {
      final response = await _supabase
          .from('elo_history')
          .select('date, elo')
          .eq('team_id', teamId)
          .order('date', ascending: true)
          .limit(50);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error obteniendo historial de ELO: $e');
      return [];
    }
  }

  /// Obtiene estadísticas de territorio para un equipo
  Future<Map<String, dynamic>> getTeamTerritorialStats(String teamId) async {
    try {
      final response = await _supabase.rpc(
        'get_team_territorial_stats',
        params: {'team_id_param': teamId},
      );

      return Map<String, dynamic>.from(response);
    } catch (e) {
      debugPrint('Error obteniendo estadísticas territoriales: $e');
      return {};
    }
  }
}
