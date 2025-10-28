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

  // Obtener lista de amigos del usuario actual - Compatible con ambas estructuras
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
              acceptedAt:
                  friend['accepted_at'] != null
                      ? DateTime.parse(friend['accepted_at'])
                      : null,
            ),
          )
          .toList();
    } catch (e) {
      print('Error detallado al obtener amigos: $e');
      return []; // Retornar lista vacía en lugar de lanzar excepción
    }
  }

  // Obtener solicitudes de amistad pendientes usando la función RPC
  Future<List<FriendshipModel>> getPendingRequests() async {
    try {
      // Usar la función RPC que maneja automáticamente la estructura correcta
      final response = await _supabase.rpc('get_pending_friend_requests');

      return response
          .map<FriendshipModel>(
            (request) => FriendshipModel(
              id: request['id'],
              userId: request['sender_id'],
              friendId: _supabase.auth.currentUser!.id,
              status: 'pending',
              createdAt: DateTime.parse(request['created_at']),
              updatedAt: null,
              friendEmail: request['sender_email'] ?? '',
              friendFullName: request['sender_name'] ?? 'Sin nombre',
              friendProfileImage: request['sender_image'],
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
  Future<Map<String, dynamic>> acceptFriendRequest(String friendshipId) async {
    try {
      final response = await _supabase.rpc(
        'accept_friend_request',
        params: {'friendship_id': friendshipId},
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      print('Error detallado al aceptar solicitud: $e');
      return {'success': false, 'message': 'Error al aceptar solicitud: $e'};
    }
  }

  // Rechazar solicitud de amistad
  Future<Map<String, dynamic>> rejectFriendRequest(String friendshipId) async {
    try {
      final response = await _supabase.rpc(
        'reject_friend_request',
        params: {'friendship_id': friendshipId},
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      print('Error detallado al rechazar solicitud: $e');
      return {'success': false, 'message': 'Error al rechazar solicitud: $e'};
    }
  }

  // Eliminar amistad
  Future<Map<String, dynamic>> removeFriend(String friendUserId) async {
    try {
      final response = await _supabase.rpc(
        'remove_friend',
        params: {'friend_id': friendUserId},
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      print('Error detallado al eliminar amistad: $e');
      return {'success': false, 'message': 'Error al eliminar amistad: $e'};
    }
  }

  // Buscar usuarios por email para agregar como amigos
  Future<List<Map<String, dynamic>>> searchUsersByEmail(String query) async {
    try {
      final response = await _supabase
          .from('profiles') // Cambiado de 'users' a 'profiles'
          .select(
            'id, email, full_name, profile_image_url, profile_picture_url',
          )
          .ilike('email', '%$query%')
          .neq('id', _supabase.auth.currentUser!.id)
          .limit(10);

      // Mapear los resultados para manejar las diferentes columnas de imágenes
      return response.map<Map<String, dynamic>>((profile) {
        return {
          'id': profile['id'],
          'email': profile['email'] ?? '',
          'full_name': profile['full_name'] ?? 'Sin nombre',
          'profile_image_url':
              profile['profile_image_url'] ?? profile['profile_picture_url'],
        };
      }).toList();
    } catch (e) {
      print('Error detallado al buscar usuarios: $e');
      return []; // Retornar lista vacía en lugar de lanzar excepción
    }
  }
}
