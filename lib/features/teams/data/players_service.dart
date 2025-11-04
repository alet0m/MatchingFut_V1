import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
import '../../../shared/models/player_model.dart';
import '../../auth/data/auth_service.dart';

class PlayersService {
  final SupabaseClient _supabase;

  PlayersService(this._supabase);

  // Helper para mapear fila compuesta (team_members + profiles + players)
  PlayerModel _mapComposedPlayer({
    required Map<String, dynamic> member,
    required Map<String, dynamic>? profile,
    required Map<String, dynamic>? stats,
    required String captainId,
  }) {
    final playerId = (member['player_id'] ?? member['user_id']).toString();
    final isCaptain = playerId == captainId || (member['role'] == 'captain');
    return PlayerModel(
      id: (member['id'] ?? '').toString(),
      userId: playerId,
      teamId: (member['team_id'] ?? '').toString(),
      name: (profile?['full_name'] ?? 'Jugador') as String,
      email: profile?['email'] as String?,
      position: (member['position'] ?? '') as String?,
      elo: (stats?['elo_rating'] ?? 1200) as int,
      goalsScored: (stats?['goals'] ?? 0) as int,
      assists: (stats?['assists'] ?? 0) as int,
      yellowCards: (stats?['yellow_cards'] ?? 0) as int,
      redCards: (stats?['red_cards'] ?? 0) as int,
      isActive: (member['is_active'] ?? true) as bool,
      isCaptain: isCaptain,
      joinedAt:
          member['joined_at'] != null
              ? DateTime.tryParse(member['joined_at'].toString())
              : null,
      createdAt:
          member['created_at'] != null
              ? DateTime.tryParse(member['created_at'].toString())
              : null,
    );
  }

  // Enviar invitación a un amigo para unirse al equipo (solo capitán)
  Future<void> invitePlayerToTeam({
    required String teamId,
    required String friendUserId,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // 1) Verificar que el current user sea capitán del equipo
      final teamResp =
          await _supabase
              .from('teams')
              .select('captain_id')
              .eq('id', teamId)
              .single();

      final captainId = (teamResp['captain_id'] ?? '').toString();
      if (captainId != currentUser.id) {
        throw Exception('Solo el capitán puede invitar jugadores');
      }

      // 2) Verificar relación de amistad (vista user_friends)
      final friendRows = await _supabase
          .from('user_friends')
          .select('friend_user_id')
          .eq('friend_user_id', friendUserId);

      if (friendRows.isEmpty) {
        throw Exception('Solo puedes invitar a amigos aceptados');
      }

      // 3) Verificar si ya está en el equipo
      final existing =
          await _supabase
              .from('team_members')
              .select('id,is_active')
              .eq('team_id', teamId)
              .eq('player_id', friendUserId)
              .maybeSingle();

      if (existing != null) {
        // Si estaba inactivo, reactivar
        if (existing['is_active'] == true) {
          throw Exception('El jugador ya es miembro del equipo');
        }
        // Si estaba inactivo, se requerirá una nueva aceptación, así que no lo reactivamos aquí.
      }

      // 4) Verificar si ya existe invitación pendiente
      final pending = await _supabase
          .from('team_invitations')
          .select('id,status')
          .eq('team_id', teamId)
          .eq('invited_user_id', friendUserId)
          .eq('status', 'pending');
      if (pending.isNotEmpty) {
        throw Exception('Ya existe una invitación pendiente');
      }

      // 5) Crear invitación
      await _supabase.from('team_invitations').insert({
        'team_id': teamId,
        'inviter_user_id': currentUser.id,
        'invited_user_id': friendUserId,
        'status': 'pending',
      });

      // 6) (Opcional pero recomendado) Crear una notificación para el invitado
      try {
        String teamName = 'tu equipo';
        try {
          final teamRow =
              await _supabase
                  .from('teams')
                  .select('name')
                  .eq('id', teamId)
                  .maybeSingle();
          if (teamRow != null && teamRow['name'] != null) {
            teamName = teamRow['name'].toString();
          }
        } catch (_) {}

        await _supabase.from('notifications').insert({
          'user_id': friendUserId,
          'type': 'team_invitation',
          'title': 'Invitación a equipo',
          'message': 'Te invitaron a unirte a $teamName',
          'is_read': false,
          'metadata': {'team_id': teamId, 'inviter_user_id': currentUser.id},
        });
      } catch (e) {
        // Si la tabla notifications no existe o hay RLS, ignorar silenciosamente
        // El badge igualmente se actualiza por team_invitations
      }
    } catch (e) {
      print('Error al invitar jugador: $e');
      rethrow;
    }
  }

  // Aceptar invitación (lo debe ejecutar el jugador invitado)
  Future<void> acceptInvitation(String invitationId) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) throw Exception('Usuario no autenticado');
    try {
      // Obtener invitación
      final inv =
          await _supabase
              .from('team_invitations')
              .select('id, team_id, invited_user_id, status')
              .eq('id', invitationId)
              .single();

      if (inv['invited_user_id'] != currentUser.id) {
        throw Exception('No autorizado para aceptar esta invitación');
      }
      if (inv['status'] != 'pending') {
        throw Exception('La invitación ya no está disponible');
      }

      // Marcar aceptada (intenta con responded_at; si no existe la columna, reintenta sin ella)
      try {
        await _supabase
            .from('team_invitations')
            .update({
              'status': 'accepted',
              'responded_at': DateTime.now().toIso8601String(),
            })
            .eq('id', invitationId);
      } catch (e) {
        final msg = e.toString();
        if (msg.contains('responded_at') || msg.contains('42703')) {
          await _supabase
              .from('team_invitations')
              .update({'status': 'accepted'})
              .eq('id', invitationId);
        } else {
          rethrow;
        }
      }

      // Agregar miembro activo
      await _supabase.from('team_members').insert({
        'team_id': inv['team_id'],
        'player_id': currentUser.id,
        'role': 'player',
        'is_active': true,
        'joined_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error al aceptar invitación: $e');
      rethrow;
    }
  }

  // Rechazar/cancelar invitación (jugador invitado)
  Future<void> rejectInvitation(String invitationId) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) throw Exception('Usuario no autenticado');
    try {
      try {
        await _supabase
            .from('team_invitations')
            .update({
              'status': 'rejected',
              'responded_at': DateTime.now().toIso8601String(),
            })
            .eq('id', invitationId);
      } catch (e) {
        final msg = e.toString();
        if (msg.contains('responded_at') || msg.contains('42703')) {
          await _supabase
              .from('team_invitations')
              .update({'status': 'rejected'})
              .eq('id', invitationId);
        } else {
          rethrow;
        }
      }
    } catch (e) {
      print('Error al rechazar invitación: $e');
      rethrow;
    }
  }

  // Obtener IDs de usuarios con invitación pendiente en un equipo (para mostrar estado en UI)
  Future<Set<String>> getPendingInvitedUserIds(String teamId) async {
    try {
      final rows = await _supabase
          .from('team_invitations')
          .select('invited_user_id')
          .eq('team_id', teamId)
          .eq('status', 'pending');
      return rows.map<String>((r) => (r['invited_user_id']).toString()).toSet();
    } catch (e) {
      print('Error al obtener invitaciones pendientes: $e');
      return <String>{};
    }
  }

  // Obtener jugadores de un equipo
  Future<List<PlayerModel>> getTeamPlayers(String teamId) async {
    try {
      // Obtener miembros activos
      final members = await _supabase
          .from('team_members')
          .select(
            'id, team_id, player_id, role, position, is_active, joined_at',
          )
          .eq('team_id', teamId)
          .eq('is_active', true)
          .order('joined_at', ascending: true);

      if (members.isEmpty) return [];

      // Obtener capitán
      final teamResp =
          await _supabase
              .from('teams')
              .select('captain_id')
              .eq('id', teamId)
              .single();
      final captainId = (teamResp['captain_id'] ?? '').toString();

      // IDs de jugadores
      final ids =
          members.map((m) => m['player_id'].toString()).toSet().toList();

      // Perfiles
      final profiles = await _supabase
          .from('profiles')
          .select('id, full_name, email, profile_picture_url')
          .inFilter('id', ids);
      final profilesById = {for (final p in profiles) p['id'].toString(): p};

      // Stats de players
      final statsRows = await _supabase
          .from('players')
          .select('id, elo_rating, goals, assists, yellow_cards, red_cards')
          .inFilter('id', ids);
      final statsById = {for (final s in statsRows) s['id'].toString(): s};

      // Mapear
      return members
          .map<PlayerModel>(
            (m) => _mapComposedPlayer(
              member: Map<String, dynamic>.from(m),
              profile: profilesById[m['player_id'].toString()],
              stats: statsById[m['player_id'].toString()],
              captainId: captainId,
            ),
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
          .eq('player_id', userId);
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
          .eq('player_id', userId);
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

// Provider para validar si el usuario actual es miembro activo de un equipo
final isTeamMemberProvider = FutureProvider.family<bool, String>((
  ref,
  teamId,
) async {
  // Escuchar cambios de autenticación para recomputar en login/logout
  ref.watch(authStateProvider);

  final supabase = ref.watch(supabaseProvider);
  final user = supabase.auth.currentUser;
  if (user == null) return false;

  try {
    final rows = await supabase
        .from('team_members')
        .select('id')
        .eq('team_id', teamId)
        .eq('player_id', user.id)
        .eq('is_active', true);
    return rows.isNotEmpty;
  } catch (e) {
    // En caso de error, asumir no miembro
    return false;
  }
});
