import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../friends_service.dart';
import '../../../../shared/models/friendship_model.dart';

// Provider para la lista de amigos
final friendsListProvider = FutureProvider<List<FriendModel>>((ref) async {
  final friendsService = ref.watch(friendsServiceProvider);
  return await friendsService.getFriends();
});

// Provider para solicitudes pendientes
final pendingRequestsProvider = FutureProvider<List<FriendshipModel>>((
  ref,
) async {
  final friendsService = ref.watch(friendsServiceProvider);
  return await friendsService.getPendingRequests();
});

// Provider para buscar usuarios
final userSearchProvider = StateNotifierProvider<
  UserSearchNotifier,
  AsyncValue<List<Map<String, dynamic>>>
>((ref) {
  final friendsService = ref.watch(friendsServiceProvider);
  return UserSearchNotifier(friendsService);
});

class UserSearchNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final FriendsService _friendsService;

  UserSearchNotifier(this._friendsService) : super(const AsyncValue.data([]));

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final users = await _friendsService.searchUsersByEmail(query);
      state = AsyncValue.data(users);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clearSearch() {
    state = const AsyncValue.data([]);
  }
}

// Provider para enviar solicitud de amistad
final sendFriendRequestProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, email) async {
      final friendsService = ref.watch(friendsServiceProvider);
      return await friendsService.sendFriendRequest(email);
    });

// Provider para aceptar solicitud
final acceptFriendRequestProvider = FutureProvider.family<bool, String>((
  ref,
  requestId,
) async {
  final friendsService = ref.watch(friendsServiceProvider);
  return await friendsService.acceptFriendRequest(requestId);
});

// Provider para rechazar solicitud
final rejectFriendRequestProvider = FutureProvider.family<bool, String>((
  ref,
  requestId,
) async {
  final friendsService = ref.watch(friendsServiceProvider);
  return await friendsService.rejectFriendRequest(requestId);
});

// Provider para eliminar amigo
final removeFriendProvider = FutureProvider.family<bool, String>((
  ref,
  friendId,
) async {
  final friendsService = ref.watch(friendsServiceProvider);
  return await friendsService.removeFriend(friendId);
});
