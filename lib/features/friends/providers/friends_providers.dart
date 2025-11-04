import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/friends_service.dart';
import '../../../shared/models/user_model.dart';
import '../../auth/data/auth_service.dart';

// Provider del servicio de amigos
final friendsServiceProvider = Provider<FriendsService>((ref) {
  return FriendsService(Supabase.instance.client);
});

// Provider para la lista de amigos
final friendsProvider = FutureProvider.autoDispose<List<UserModel>>((
  ref,
) async {
  // Recalcular cuando cambie el estado de autenticación
  ref.watch(authStateProvider);
  final service = ref.read(friendsServiceProvider);
  return service.getFriends();
});

// Provider para solicitudes de amistad pendientes (stream en vivo, estable)
final friendRequestsProvider = StreamProvider<List<UserModel>>((ref) async* {
  // Recalcular cuando cambie el estado de autenticación
  ref.watch(authStateProvider);
  final service = ref.read(friendsServiceProvider);
  final supabase = Supabase.instance.client;

  Future<List<UserModel>> fetch() => service.getFriendRequests();

  final controller = StreamController<List<UserModel>>.broadcast();
  List<UserModel>? lastEmitted;
  bool computing = false;
  Timer? debounce;

  void scheduleEmit() {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 200), () async {
      if (computing) return;
      computing = true;
      final value = await fetch();
      // Dedupe por contenido para evitar reconstrucciones innecesarias
      if (lastEmitted?.length != value.length || (lastEmitted == null)) {
        lastEmitted = value;
        controller.add(value);
      }
      computing = false;
    });
  }

  scheduleEmit();

  final ch =
      supabase.channel('notifications:friendships')
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'friendships',
          callback: (_) async => scheduleEmit(),
        )
        ..subscribe();

  ref.onDispose(() {
    controller.close();
    debounce?.cancel();
    supabase.removeChannel(ch);
  });

  yield* controller.stream;
});

// Provider para búsqueda de usuarios
final userSearchProvider = FutureProvider.autoDispose
    .family<List<UserModel>, String>((ref, query) async {
      if (query.trim().isEmpty) return [];
      // Atar búsqueda a cambios de auth para evitar fugas de sesión
      ref.watch(authStateProvider);
      final service = ref.read(friendsServiceProvider);
      return service.searchUsers(query);
    });

// Provider para verificar si existe amistad
final friendshipStatusProvider = FutureProvider.autoDispose
    .family<String?, String>((ref, userId) async {
      ref.watch(authStateProvider);
      final service = ref.read(friendsServiceProvider);
      return service.getFriendshipStatus(userId);
    });

// Provider para estadísticas sociales
final socialStatsProvider = FutureProvider.autoDispose<Map<String, int>>((
  ref,
) async {
  ref.watch(authStateProvider);
  final service = ref.read(friendsServiceProvider);
  final friends = await service.getFriends();
  final requests = await service.getFriendRequests();
  return {'friends': friends.length, 'pendingRequests': requests.length};
});
