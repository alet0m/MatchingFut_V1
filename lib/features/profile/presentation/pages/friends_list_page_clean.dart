// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Mock provider para amigos
final friendsProvider =
    StateNotifierProvider<FriendsNotifier, AsyncValue<List<Friend>>>((ref) {
      return FriendsNotifier();
    });

class Friend {
  final String id;
  final String name;
  final String profileImageUrl;
  final bool isOnline;
  final String lastSeen;

  const Friend({
    required this.id,
    required this.name,
    required this.profileImageUrl,
    required this.isOnline,
    required this.lastSeen,
  });
}

class FriendsNotifier extends StateNotifier<AsyncValue<List<Friend>>> {
  FriendsNotifier() : super(const AsyncValue.loading()) {
    _loadFriends();
  }

  void _loadFriends() {
    // Simular carga de amigos
    Future.delayed(const Duration(milliseconds: 500), () {
      final friends = [
        const Friend(
          id: '1',
          name: 'Carlos Rodríguez',
          profileImageUrl: 'https://i.pravatar.cc/150?u=carlos',
          isOnline: true,
          lastSeen: 'En línea',
        ),
        const Friend(
          id: '2',
          name: 'María González',
          profileImageUrl: 'https://i.pravatar.cc/150?u=maria',
          isOnline: false,
          lastSeen: 'Hace 2 horas',
        ),
        const Friend(
          id: '3',
          name: 'Diego Silva',
          profileImageUrl: 'https://i.pravatar.cc/150?u=diego',
          isOnline: true,
          lastSeen: 'En línea',
        ),
      ];
      state = AsyncValue.data(friends);
    });
  }
}

class FriendsListPage extends ConsumerWidget {
  const FriendsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsState = ref.watch(friendsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis Amigos',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          ),
        ),
        child: Column(
          children: [
            // Buscador de amigos
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () {
                    // TODO: Implementar búsqueda de amigos
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.white70, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Buscar amigos...',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Lista de amigos
            Expanded(
              child: friendsState.when(
                data: (friends) {
                  if (friends.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 80,
                            color: Colors.white54,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No tienes amigos aún',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Busca usuarios y agrégalos como amigos',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      final friend = friends[index];
                      return _buildFriendCard(friend);
                    },
                  );
                },
                loading:
                    () => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                error:
                    (error, stackTrace) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Error al cargar amigos',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error.toString(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implementar agregar amigo
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.person_add, color: Color(0xFF2E7D32)),
      ),
    );
  }

  Widget _buildFriendCard(Friend friend) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar con indicador de estado
            Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: friend.isOnline ? Colors.green : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      friend.profileImageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 56,
                          height: 56,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.person,
                            size: 32,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (friend.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),

            // Información del amigo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friend.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    friend.lastSeen,
                    style: TextStyle(
                      fontSize: 14,
                      color: friend.isOnline ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Botones de acción
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    // TODO: Implementar chat
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline,
                      color: Color(0xFF2E7D32),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    // TODO: Implementar invitar a partido
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.sports_soccer,
                      color: Color(0xFF2E7D32),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
