import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
import '../../../shared/models/user_model.dart';

class FriendsService {
  final SupabaseClient _supabase;

  FriendsService(this._supabase);

  // Mapea una fila de la tabla profiles (snake_case) a UserModel (camelCase)
  UserModel _mapProfileRowToUser(Map<String, dynamic> row) {
    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString()) ?? DateTime.now();
    }

    return UserModel(
      id: row['id'] as String,
      email: (row['email'] ?? '') as String,
      fullName:
          (row['full_name'] ?? row['display_name'] ?? row['email'] ?? 'Usuario')
              as String,
      // No existe 'nickname' en el esquema; usamos 'tag' como alias para mostrar @handle en la UI
      nickname: (row['nickname'] ?? row['tag']) as String?,
      bio: row['bio'] as String?,
      dateOfBirth:
          row['date_of_birth'] != null
              ? DateTime.tryParse(row['date_of_birth'].toString())
              : null,
      age: row['age'] as int?,
      comunaId: row['comuna_id'] as String?,
      sectorName: row['sector_name'] as String?,
      // Soportar distintos nombres para la foto de perfil
      profileImageUrl:
          (row['profile_image_url'] ??
                  row['profile_picture_url'] ??
                  row['photo_url'])
              as String?,
      isEmailVerified: (row['is_email_verified'] ?? false) as bool,
      hasCompletedOnboarding:
          (row['has_completed_onboarding'] ?? false) as bool,
      createdAt: parseDate(row['created_at']),
      updatedAt: parseDate(row['updated_at']),
    );
  }

  // Enviar solicitud de amistad
  Future<void> sendFriendRequest(String toUserId) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null || currentUser.id == toUserId) {
      throw Exception('Usuario no válido');
    }

    // Verificar bloqueos en ambas direcciones
    final anyBlock =
        await _supabase
            .from('user_blocks')
            .select('id')
            .or(
              'and(blocker_id.eq.${currentUser.id},blocked_id.eq.$toUserId),and(blocker_id.eq.$toUserId,blocked_id.eq.${currentUser.id})',
            )
            .maybeSingle();
    if (anyBlock != null) {
      throw Exception('No puedes enviar una solicitud a este usuario');
    }

    print('📤 Enviando solicitud de amistad de ${currentUser.id} a $toUserId');

    // Verificar que no exista ya una solicitud pendiente
    final existingRequest =
        await _supabase
            .from('friendships')
            .select()
            .eq('requester_id', currentUser.id)
            .eq('receiver_id', toUserId)
            .eq('status', 'pending')
            .maybeSingle();

    if (existingRequest != null) {
      throw Exception('Ya enviaste una solicitud de amistad a este usuario');
    }

    // Verificar que no sean ya amigos
    final existingFriendship =
        await _supabase
            .from('friendships')
            .select()
            .or(
              'and(requester_id.eq.${currentUser.id},receiver_id.eq.$toUserId,status.eq.accepted),and(requester_id.eq.$toUserId,receiver_id.eq.${currentUser.id},status.eq.accepted)',
            )
            .maybeSingle();

    if (existingFriendship != null) {
      throw Exception('Ya son amigos');
    }

    // Crear la solicitud de amistad
    await _supabase.from('friendships').insert({
      'requester_id': currentUser.id,
      'receiver_id': toUserId,
      'status': 'pending',
    });

    print('✅ Solicitud de amistad enviada correctamente');
  }

  // Responder a una solicitud de amistad
  // Nota: el parámetro requesterUserId corresponde al ID del usuario que envió la solicitud.
  // La UI actual pasa el id del solicitante (UserModel.id), no el id del registro de amistad.
  Future<void> respondToFriendRequest(
    String requesterUserId,
    bool accept,
  ) async {
    final currentUser = _supabase.auth.currentUser;
    // Si no hay sesión (estado transitorio tras registro/redirección), salimos en silencio
    if (currentUser == null) return;

    final Map<String, dynamic> updateData =
        accept
            ? {
              'status': 'accepted',
              'accepted_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            }
            : {
              'status': 'rejected',
              'updated_at': DateTime.now().toIso8601String(),
            };

    final updated =
        await _supabase
            .from('friendships')
            .update(updateData)
            .eq('requester_id', requesterUserId)
            .eq('receiver_id', currentUser.id)
            .eq('status', 'pending')
            .select();

    if (updated.isEmpty) {
      throw Exception('No se encontró la solicitud pendiente para responder');
    }

    print('✅ Solicitud de amistad ${accept ? 'aceptada' : 'rechazada'}');
  }

  // Obtener lista de amigos
  Future<List<UserModel>> getFriends() async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return [];

    try {
      final friendships = await _supabase
          .from('friendships')
          .select('*')
          .eq('status', 'accepted')
          .or(
            'requester_id.eq.${currentUser.id},receiver_id.eq.${currentUser.id}',
          );

      final List<UserModel> friends = [];

      for (final friendship in friendships) {
        // Determinar el ID del amigo (el que no es el usuario actual)
        final friendId =
            friendship['requester_id'] == currentUser.id
                ? friendship['receiver_id']
                : friendship['requester_id'];

        // Obtener información del amigo
        try {
          final friendData =
              await _supabase
                  .from('profiles')
                  .select('*')
                  .eq('id', friendId)
                  .single();

          friends.add(_mapProfileRowToUser(friendData));
        } catch (e) {
          print('Error al obtener datos del amigo $friendId: $e');
        }
      }

      return friends;
    } catch (e) {
      print('Error obteniendo amigos: $e');
      return [];
    }
  }

  // Obtener solicitudes de amistad pendientes
  Future<List<UserModel>> getFriendRequests() async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return [];

    try {
      final requests = await _supabase
          .from('friendships')
          .select('*')
          .eq('receiver_id', currentUser.id)
          .eq('status', 'pending');

      final List<UserModel> requesters = [];

      for (final request in requests) {
        try {
          final requesterData =
              await _supabase
                  .from('profiles')
                  .select('*')
                  .eq('id', request['requester_id'])
                  .single();

          requesters.add(_mapProfileRowToUser(requesterData));
        } catch (e) {
          print('Error al obtener datos del solicitante: $e');
        }
      }

      return requesters;
    } catch (e) {
      print('Error obteniendo solicitudes: $e');
      return [];
    }
  }

  // Eliminar amistad
  Future<void> removeFriend(String friendId) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return;

    await _supabase
        .from('friendships')
        .delete()
        .or(
          'and(requester_id.eq.${currentUser.id},receiver_id.eq.$friendId),and(requester_id.eq.$friendId,receiver_id.eq.${currentUser.id})',
        )
        .eq('status', 'accepted');

    print('✅ Amistad eliminada');
  }

  // Buscar usuarios por nombre o nickname
  Future<List<UserModel>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];

    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return [];

    try {
      final response = await _supabase
          .from('profiles')
          .select('*')
          .or(
            'full_name.ilike.%$query%,email.ilike.%$query%,tag.ilike.%$query%',
          )
          .eq('is_active', true)
          .neq('id', currentUser.id) // Excluir al usuario actual
          .limit(20);

      // Excluir usuarios bloqueados/que te bloquearon (cliente) para este resultado limitado
      final blockedByMe = await _supabase
          .from('user_blocks')
          .select('blocked_id')
          .eq('blocker_id', currentUser.id);
      final blockedMe = await _supabase
          .from('user_blocks')
          .select('blocker_id')
          .eq('blocked_id', currentUser.id);

      final blockedByMeSet = {
        for (final r in blockedByMe) r['blocked_id'] as String,
      };
      final blockedMeSet = {
        for (final r in blockedMe) r['blocker_id'] as String,
      };

      return response
          .where(
            (row) =>
                !blockedByMeSet.contains(row['id']) &&
                !blockedMeSet.contains(row['id']),
          )
          .map<UserModel>((row) => _mapProfileRowToUser(row))
          .toList();
    } catch (e) {
      print('Error buscando usuarios: $e');
      return [];
    }
  }

  // Verificar si son amigos
  Future<bool> areFriends(String userId) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return false;

    try {
      final friendship =
          await _supabase
              .from('friendships')
              .select()
              .or(
                'and(requester_id.eq.${currentUser.id},receiver_id.eq.$userId),and(requester_id.eq.$userId,receiver_id.eq.${currentUser.id})',
              )
              .eq('status', 'accepted')
              .maybeSingle();

      return friendship != null;
    } catch (e) {
      print('Error verificando amistad: $e');
      return false;
    }
  }

  // Obtener estado de la amistad
  Future<String?> getFriendshipStatus(String userId) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return null;

    try {
      final friendship =
          await _supabase
              .from('friendships')
              .select()
              .or(
                'and(requester_id.eq.${currentUser.id},receiver_id.eq.$userId),and(requester_id.eq.$userId,receiver_id.eq.${currentUser.id})',
              )
              .maybeSingle();

      return friendship?['status'];
    } catch (e) {
      print('Error obteniendo estado de amistad: $e');
      return null;
    }
  }

  // Verificar si hay solicitud pendiente
  Future<String?> getPendingRequestStatus(String userId) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return null;

    try {
      // Buscar solicitud enviada por el usuario actual
      final sentRequest =
          await _supabase
              .from('friendships')
              .select()
              .eq('requester_id', currentUser.id)
              .eq('receiver_id', userId)
              .eq('status', 'pending')
              .maybeSingle();

      if (sentRequest != null) return 'sent';

      // Buscar solicitud recibida por el usuario actual
      final receivedRequest =
          await _supabase
              .from('friendships')
              .select()
              .eq('requester_id', userId)
              .eq('receiver_id', currentUser.id)
              .eq('status', 'pending')
              .maybeSingle();

      if (receivedRequest != null) return 'received';

      return null;
    } catch (e) {
      print('Error verificando solicitudes pendientes: $e');
      return null;
    }
  }
}

// Provider para el servicio de amigos
final friendsServiceProvider = Provider<FriendsService>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return FriendsService(supabase);
});

// Provider para obtener amigos del usuario actual
final friendsProvider = FutureProvider<List<UserModel>>((ref) {
  final friendsService = ref.watch(friendsServiceProvider);
  return friendsService.getFriends();
});

// Provider para obtener solicitudes de amistad
final friendRequestsProvider = FutureProvider<List<UserModel>>((ref) {
  final friendsService = ref.watch(friendsServiceProvider);
  return friendsService.getFriendRequests();
});
