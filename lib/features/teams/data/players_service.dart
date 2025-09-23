import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
import '../../../shared/models/player_model.dart';

class PlayersService {
  final SupabaseClient _supabase;

  PlayersService(this._supabase);

  // Helper method para mapear respuestas de la base de datos
  Map<String, dynamic> _mapPlayerFromDatabase(Map<String, dynamic> dbPlayer) {
    return {
      'id': dbPlayer['id'],
      'userId': dbPlayer['user_id'],
      'teamId': dbPlayer['team_id'],
      'name': dbPlayer['name'],
      'email': dbPlayer['email'],
      'position': dbPlayer['position'],
      'elo': dbPlayer['elo'] ?? 1200,
      'goalsScored': dbPlayer['goals_scored'] ?? 0,
      'assists': dbPlayer['assists'] ?? 0,
      'yellowCards': dbPlayer['yellow_cards'] ?? 0,
      'redCards': dbPlayer['red_cards'] ?? 0,
      'isActive': dbPlayer['is_active'] ?? true,
      'isCaptain': dbPlayer['is_captain'] ?? false,
      'joinedAt':
          dbPlayer['joined_at'] != null
              ? DateTime.parse(
                dbPlayer['joined_at'] as String,
              ).toIso8601String()
              : null,
      'createdAt':
          dbPlayer['created_at'] != null
              ? DateTime.parse(
                dbPlayer['created_at'] as String,
              ).toIso8601String()
              : DateTime.now().toIso8601String(),
    };
  }

  // Agregar jugador a equipo
  Future<PlayerModel> addPlayerToTeam({
    required String teamId,
    required String userId,
    required String name,
    String? email,
    String? position,
    bool isCaptain = false,
  }) async {
    try {
      final data = {
        'team_id': teamId,
        'user_id': userId,
        'name': name,
        'email': email,
        'position': position,
        'elo': 1200,
        'is_active': true,
        'is_captain': isCaptain,
        'joined_at': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      };

      final response =
          await _supabase.from('team_members').insert(data).select().single();

      final mappedResponse = _mapPlayerFromDatabase(response);
      return PlayerModel.fromJson(mappedResponse);
    } catch (e) {
      print('Error al agregar jugador: $e');
      rethrow;
    }
  }

  // Obtener jugadores de un equipo
  Future<List<PlayerModel>> getTeamPlayers(String teamId) async {
    try {
      final response = await _supabase
          .from('team_members')
          .select()
          .eq('team_id', teamId)
          .eq('is_active', true)
          .order('is_captain', ascending: false)
          .order('joined_at', ascending: true);

      return response
          .map<PlayerModel>(
            (json) => PlayerModel.fromJson(_mapPlayerFromDatabase(json)),
          )
          .toList();
    } catch (e) {
      print('Error al obtener jugadores: $e');
      return [];
    }
  }

  // Contar jugadores activos de un equipo
  Future<int> getTeamPlayersCount(String teamId) async {
    try {
      final response = await _supabase
          .from('team_members')
          .select('id')
          .eq('team_id', teamId)
          .eq('is_active', true);

      return response.length;
    } catch (e) {
      print('Error al contar jugadores: $e');
      return 0;
    }
  }

  // Remover jugador del equipo
  Future<void> removePlayerFromTeam({
    required String teamId,
    required String userId,
  }) async {
    try {
      await _supabase
          .from('team_members')
          .update({'is_active': false})
          .eq('team_id', teamId)
          .eq('user_id', userId);
    } catch (e) {
      print('Error al remover jugador: $e');
      rethrow;
    }
  }

  // Actualizar posición de jugador
  Future<void> updatePlayerPosition({
    required String teamId,
    required String userId,
    required String position,
  }) async {
    try {
      await _supabase
          .from('team_members')
          .update({'position': position})
          .eq('team_id', teamId)
          .eq('user_id', userId);
    } catch (e) {
      print('Error al actualizar posición: $e');
      rethrow;
    }
  }

  // Validar si equipo tiene jugadores suficientes para partido
  Future<bool> hasEnoughPlayers(String teamId, {int minimum = 7}) async {
    final count = await getTeamPlayersCount(teamId);
    return count >= minimum;
  }
}

// Provider para el servicio de jugadores
final playersServiceProvider = Provider<PlayersService>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return PlayersService(supabase);
});

// Provider para obtener jugadores de un equipo
final teamPlayersProvider = FutureProvider.family<List<PlayerModel>, String>((
  ref,
  teamId,
) async {
  final playersService = ref.watch(playersServiceProvider);
  return playersService.getTeamPlayers(teamId);
});

// Provider para contar jugadores de un equipo
final teamPlayersCountProvider = FutureProvider.family<int, String>((
  ref,
  teamId,
) async {
  final playersService = ref.watch(playersServiceProvider);
  return playersService.getTeamPlayersCount(teamId);
});
