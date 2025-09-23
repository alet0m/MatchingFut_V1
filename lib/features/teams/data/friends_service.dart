import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/friendship_model.dart';

// Provider para el servicio de amigos
final friendsServiceProvider = Provider<FriendsService>((ref) {
  return FriendsService(Supabase.instance.client);
});

class FriendsService {
  final SupabaseClient _supabase;

  FriendsService(this._supabase);

  // Obtener lista de amigos del usuario actual
  Future<List<FriendModel>> getFriends() async {
    try {
      final response =
          await _supabase
              .from('user_friends') // Vista creada en SQL
              .select();

      return response
          .map<FriendModel>(
            (friend) => FriendModel(
              userId: friend['friend_user_id'],
              email: friend['email'] ?? '',
              fullName: friend['full_name'] ?? 'Sin nombre',
              profileImageUrl: friend['profile_image_url'],
              status: friend['status'] ?? 'accepted',
              friendshipDate:
                  friend['friendship_date'] != null
                      ? DateTime.parse(friend['friendship_date'])
                      : null,
            ),
          )
          .toList();
    } catch (e) {
      print('Error detallado al obtener amigos: $e');
      return []; // Retornar lista vacía en lugar de lanzar excepción
    }
  }

  // Obtener solicitudes de amistad pendientes (recibidas)
  Future<List<FriendshipModel>> getPendingRequests() async {
    try {
      final response = await _supabase
          .from('friendships')
          .select('''
            *,
            sender:user_id(id, email, full_name, profile_image_url)
          ''')
          .eq('friend_id', _supabase.auth.currentUser!.id)
          .eq('status', 'pending');

      return response
          .map<FriendshipModel>(
            (request) => FriendshipModel(
              id: request['id'],
              userId: request['user_id'],
              friendId: request['friend_id'],
              status: request['status'],
              createdAt: DateTime.parse(request['created_at']),
              updatedAt:
                  request['updated_at'] != null
                      ? DateTime.parse(request['updated_at'])
                      : null,
              friendEmail: request['sender']?['email'] ?? '',
              friendFullName: request['sender']?['full_name'] ?? 'Sin nombre',
              friendProfileImage: request['sender']?['profile_image_url'],
            ),
          )
          .toList();
    } catch (e) {
      print('Error detallado al obtener solicitudes: $e');
      return []; // Retornar lista vacía en lugar de lanzar excepción
    }
  }

  // Enviar solicitud de amistad por email
  Future<Map<String, dynamic>> sendFriendRequest(String friendEmail) async {
    try {
      final response = await _supabase.rpc(
        'send_friend_request',
        params: {'friend_email': friendEmail},
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'message': 'Error al enviar solicitud: $e'};
    }
  }

  // Aceptar solicitud de amistad
  Future<bool> acceptFriendRequest(String friendshipId) async {
    try {
      await _supabase
          .from('friendships')
          .update({
            'status': 'accepted',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', friendshipId);

      return true;
    } catch (e) {
      print('Error detallado al aceptar solicitud: $e');
      return false; // Retornamos false en lugar de lanzar excepción
    }
  }

  // Rechazar solicitud de amistad
  Future<bool> rejectFriendRequest(String friendshipId) async {
    try {
      await _supabase
          .from('friendships')
          .update({
            'status': 'rejected',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', friendshipId);

      return true;
    } catch (e) {
      print('Error detallado al rechazar solicitud: $e');
      return false; // Retornamos false en lugar de lanzar excepción
    }
  }

  // Eliminar amistad
  Future<bool> removeFriend(String friendUserId) async {
    try {
      final currentUserId = _supabase.auth.currentUser!.id;

      await _supabase
          .from('friendships')
          .delete()
          .or('user_id.eq.$currentUserId,friend_id.eq.$currentUserId')
          .or('user_id.eq.$friendUserId,friend_id.eq.$friendUserId');

      return true;
    } catch (e) {
      print('Error detallado al eliminar amistad: $e');
      return false; // Retornamos false en lugar de lanzar excepción
    }
  }

  // Buscar usuarios por email para agregar como amigos
  Future<List<Map<String, dynamic>>> searchUsersByEmail(String query) async {
    try {
      final response = await _supabase
          .from('profiles') // Cambiado de 'users' a 'profiles'
          .select('id, email, full_name, profile_image_url')
          .ilike('email', '%$query%')
          .neq('id', _supabase.auth.currentUser!.id)
          .limit(10);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error detallado al buscar usuarios: $e');
      return []; // Retornar lista vacía en lugar de lanzar excepción
    }
  }
}
