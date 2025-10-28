import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/sector_model.dart';
import '../../../shared/models/team_model.dart';

final sectorControlServiceProvider = Provider<SectorControlService>((ref) {
  return SectorControlService();
});

class SectorControlService {
  final _supabase = Supabase.instance.client;

  /// Obtiene el equipo que controla un sector específico
  Future<TeamModel?> getSectorControllingTeam(String sectorId) async {
    try {
      final response =
          await _supabase
              .from('sector_control')
              .select('team_id, teams(*)')
              .eq('sector_id', sectorId)
              .maybeSingle();

      if (response == null) return null;

      return TeamModel.fromJson(response['teams']);
    } catch (e) {
      debugPrint('Error obteniendo equipo controlador: $e');
      return null;
    }
  }

  /// Obtiene el historial de control de un sector
  Future<List<Map<String, dynamic>>> getSectorControlHistory(
    String sectorId,
  ) async {
    try {
      final response = await _supabase
          .from('sector_control_history')
          .select('''
            id, 
            sector_id,
            team_id,
            control_start,
            control_end,
            match_id,
            teams(id, name, logo_url)
          ''')
          .eq('sector_id', sectorId)
          .order('control_start', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error obteniendo historial de control: $e');
      return [];
    }
  }

  /// Actualiza el control de un sector después de un partido
  Future<void> updateSectorControl({
    required String sectorId,
    required String teamId,
    required String matchId,
  }) async {
    try {
      // Obtener el control actual
      final currentControl =
          await _supabase
              .from('sector_control')
              .select()
              .eq('sector_id', sectorId)
              .maybeSingle();

      // Iniciar una transacción
      await _supabase.rpc('begin_transaction');

      try {
        // Si existe un control previo, actualizar su registro en el historial
        if (currentControl != null) {
          final previousTeamId = currentControl['team_id'];

          // Solo si el equipo que gana es diferente al que ya controlaba
          if (previousTeamId != teamId) {
            // Cerrar el período de control anterior
            await _supabase
                .from('sector_control_history')
                .update({'control_end': DateTime.now().toIso8601String()})
                .eq('sector_id', sectorId)
                .isFilter('control_end', null);

            // Actualizar el control del sector
            await _supabase
                .from('sector_control')
                .update({
                  'team_id': teamId,
                  'control_date': DateTime.now().toIso8601String(),
                  'match_id': matchId,
                })
                .eq('sector_id', sectorId);

            // Crear nuevo registro en el historial
            await _supabase.from('sector_control_history').insert({
              'sector_id': sectorId,
              'team_id': teamId,
              'control_start': DateTime.now().toIso8601String(),
              'match_id': matchId,
            });
          }
        } else {
          // Si no existe control previo, crear uno nuevo
          await _supabase.from('sector_control').insert({
            'sector_id': sectorId,
            'team_id': teamId,
            'control_date': DateTime.now().toIso8601String(),
            'match_id': matchId,
          });

          // Crear registro en el historial
          await _supabase.from('sector_control_history').insert({
            'sector_id': sectorId,
            'team_id': teamId,
            'control_start': DateTime.now().toIso8601String(),
            'match_id': matchId,
          });
        }

        // Confirmar la transacción
        await _supabase.rpc('commit_transaction');
      } catch (e) {
        // Revertir la transacción en caso de error
        await _supabase.rpc('rollback_transaction');
        rethrow;
      }
    } catch (e) {
      debugPrint('Error actualizando control de sector: $e');
      rethrow;
    }
  }

  /// Obtiene todos los sectores controlados por un equipo
  Future<List<SectorModel>> getTeamControlledSectors(String teamId) async {
    try {
      final response = await _supabase
          .from('sector_control')
          .select('sector_id, sectors(*)')
          .eq('team_id', teamId);

      return response.map<SectorModel>((record) {
        return SectorModel.fromJson(record['sectors']);
      }).toList();
    } catch (e) {
      debugPrint('Error obteniendo sectores controlados: $e');
      return [];
    }
  }

  /// Obtiene estadísticas de control territorial de un equipo
  Future<Map<String, dynamic>> getTeamControlStats(String teamId) async {
    try {
      final response = await _supabase.rpc(
        'get_team_territorial_stats',
        params: {'team_id_param': teamId},
      );

      return Map<String, dynamic>.from(response);
    } catch (e) {
      debugPrint('Error obteniendo estadísticas de control: $e');
      return {
        'sectors_controlled': 0,
        'total_control_days': 0,
        'average_control_days': 0,
        'elo_bonus': 0,
      };
    }
  }
}
