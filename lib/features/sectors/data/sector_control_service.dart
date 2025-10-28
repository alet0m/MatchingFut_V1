import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/sector_control_history_model.dart';
import '../../../core/config/supabase_config.dart';

class SectorControlService {
  final SupabaseClient _supabase;

  SectorControlService(this._supabase);

  // Helper method para mapear datos
  Map<String, dynamic> _mapControlHistoryFromDatabase(
    Map<String, dynamic> dbControl,
  ) {
    return {
      'id': dbControl['id'],
      'sectorId': dbControl['sector_id'],
      'teamId': dbControl['team_id'],
      'controlStart': dbControl['control_start'],
      'controlEnd': dbControl['control_end'],
      'eloAtStart': dbControl['elo_at_start'],
      'eloAtEnd': dbControl['elo_at_end'],
      'totalDays': dbControl['total_days'],
      'matchId': dbControl['match_id'],
      'lossMatchId': dbControl['loss_match_id'],
      'createdAt': dbControl['created_at'],
    };
  }

  // Obtener historial de control de un sector
  Future<List<SectorControlHistoryModel>> getSectorControlHistory(
    String sectorId,
  ) async {
    final response = await _supabase
        .from('sector_control_history')
        .select()
        .eq('sector_id', sectorId)
        .order('control_start', ascending: false);

    return response
        .map<SectorControlHistoryModel>(
          (json) => SectorControlHistoryModel.fromJson(
            _mapControlHistoryFromDatabase(json),
          ),
        )
        .toList();
  }

  // Obtener historial de control de un equipo
  Future<List<SectorControlHistoryModel>> getTeamControlHistory(
    String teamId,
  ) async {
    final response = await _supabase
        .from('sector_control_history')
        .select()
        .eq('team_id', teamId)
        .order('control_start', ascending: false);

    return response
        .map<SectorControlHistoryModel>(
          (json) => SectorControlHistoryModel.fromJson(
            _mapControlHistoryFromDatabase(json),
          ),
        )
        .toList();
  }

  // Obtener sectores controlados actualmente por un equipo
  Future<List<Map<String, dynamic>>> getControlledSectorsByTeam(
    String teamId,
  ) async {
    final response = await _supabase
        .from('sectors')
        .select('''
          id,
          name,
          description,
          comuna_id,
          comunas!inner (
            name,
            region_id
          ),
          current_elo_threshold,
          control_start_date,
          total_matches
        ''')
        .eq('controlling_team_id', teamId);

    return List<Map<String, dynamic>>.from(response);
  }
}

// Provider para el servicio de control de sectores
final sectorControlServiceProvider = Provider<SectorControlService>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return SectorControlService(supabase);
});

// Provider para obtener historial de control de un sector
final sectorControlHistoryProvider =
    FutureProvider.family<List<SectorControlHistoryModel>, String>((
      ref,
      sectorId,
    ) async {
      final sectorControlService = ref.watch(sectorControlServiceProvider);
      return sectorControlService.getSectorControlHistory(sectorId);
    });

// Provider para obtener historial de control de un equipo
final teamControlHistoryProvider =
    FutureProvider.family<List<SectorControlHistoryModel>, String>((
      ref,
      teamId,
    ) async {
      final sectorControlService = ref.watch(sectorControlServiceProvider);
      return sectorControlService.getTeamControlHistory(teamId);
    });

// Provider para obtener sectores controlados por un equipo
final controlledSectorsByTeamProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      teamId,
    ) async {
      final sectorControlService = ref.watch(sectorControlServiceProvider);
      return sectorControlService.getControlledSectorsByTeam(teamId);
    });
