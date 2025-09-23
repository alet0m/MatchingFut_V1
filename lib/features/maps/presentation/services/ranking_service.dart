import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/models/team_model.dart';
import '../../../core/config/supabase_config.dart';

/// Servicio para gestionar los rankings de equipos y territorios
class RankingService {
  final _supabase = Supabase.instance.client;

  /// Obtiene el ranking global de equipos ordenados por ELO
  Future<List<TeamModel>> getGlobalRankings() async {
    try {
      final response = await _supabase
          .from('teams')
          .select('*')
          .order('average_elo', ascending: false)
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
          .order('average_elo', ascending: false)
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
      // Esta consulta debe ser adaptada a la estructura real de la base de datos
      // Usamos una vista o función que devuelve equipos con sectores controlados
      final response = await _supabase
          .rpc(
            'get_sector_controllers_by_comuna',
            params: {'comuna_id_param': comunaId},
          )
          .limit(50);

      // La respuesta podría incluir información adicional sobre sectores controlados
      return response.map((data) {
        final team = TeamModel.fromJson(data);
        // No podemos añadir propiedades personalizadas sin modificar el modelo
        return team;
      }).toList();
    } catch (e) {
      debugPrint('Error obteniendo controladores de sectores: $e');
      // Si la función RPC no existe, intentamos una consulta alternativa
      try {
        // Consulta alternativa usando joins en caso de que la RPC no esté disponible
        final response = await _supabase
            .from('sector_control')
            .select('team_id, teams(*)')
            .eq('teams.comuna_id', comunaId)
            .order('control_date', ascending: false)
            .limit(50);

        // Procesamos manualmente para extraer equipos únicos
        final Map<String, TeamModel> uniqueTeams = {};

        for (final record in response) {
          final teamData = record['teams'];
          final teamId = teamData['id'];

          if (!uniqueTeams.containsKey(teamId)) {
            final team = TeamModel.fromJson(teamData);
            uniqueTeams[teamId] = team;
          }
        }

        return uniqueTeams.values.toList();
      } catch (innerError) {
        debugPrint('Error en consulta alternativa: $innerError');
        return [];
      }
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
