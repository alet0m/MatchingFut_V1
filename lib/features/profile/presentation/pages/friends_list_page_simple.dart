// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../teams/data/providers/friends_providers.dart';

class FriendsListPageSimple extends ConsumerWidget {
  const FriendsListPageSimple({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsList = ref.watch(friendsListProvider);
    final pendingRequests = ref.watch(pendingRequestsProvider);

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
            // Solicitudes pendientes
            pendingRequests.when(
              data: (requests) {
                if (requests.isEmpty) return const SizedBox.shrink();
                return _buildPendingRequestsSection(context, ref, requests);
              },
              loading: () => const SizedBox.shrink(),
              error:
                  (error, _) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Error cargando solicitudes: $error',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
            ),

            // Lista de amigos
            Expanded(
              child: friendsList.when(
                data: (friends) {
                  if (friends.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  return _buildFriendsList(context, ref, friends);
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
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed:
                                () => ref.invalidate(friendsListProvider),
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingRequestsSection(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> requests,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.notifications, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Solicitudes pendientes (${requests.length})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...requests.map(
            (request) => _buildPendingRequestCard(context, ref, request),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingRequestCard(
    BuildContext context,
    WidgetRef ref,
    dynamic request,
  ) {
    final friendName = request['friend_full_name'] ?? 'Usuario';
    final friendEmail = request['friend_email'] ?? '';
    final friendImage = request['friend_profile_image'];
    final requestId = request['id'];

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage:
                  (friendImage != null && (friendImage as String).isNotEmpty)
                      ? NetworkImage(friendImage)
                      : null,
              backgroundColor: Colors.grey[300],
              child:
                  (friendImage == null || (friendImage as String).isEmpty)
                      ? const Icon(Icons.person, size: 25, color: Colors.grey)
                      : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friendName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    friendEmail,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () async {
                    try {
                      await ref.read(
                        acceptFriendRequestProvider(requestId).future,
                      );
                      ref.invalidate(friendsListProvider);
                      ref.invalidate(pendingRequestsProvider);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Solicitud aceptada'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.check, color: Colors.green),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.green.withOpacity(0.1),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    try {
                      await ref.read(
                        rejectFriendRequestProvider(requestId).future,
                      );
                      ref.invalidate(pendingRequestsProvider);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Solicitud rechazada'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.close, color: Colors.red),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsList(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> friends,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        return _buildFriendCard(context, friend);
      },
    );
  }

  Widget _buildFriendCard(BuildContext context, dynamic friend) {
    final fullName = friend['full_name'] ?? 'Usuario';
    final email = friend['email'] ?? '';
    final profileImage = friend['profile_image_url'];
    final isOnline = friend['is_online'] ?? false;

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
                      color: isOnline ? Colors.green : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child:
                        (profileImage != null &&
                                (profileImage as String).isNotEmpty)
                            ? Image.network(
                              profileImage,
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
                            )
                            : Container(
                              width: 56,
                              height: 56,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.person,
                                size: 32,
                                color: Colors.grey,
                              ),
                            ),
                  ),
                ),
                if (isOnline)
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
                    fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    isOnline ? 'En línea' : 'Desconectado',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOnline ? Colors.green : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Botón de menú
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'chat':
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Iniciando chat con $fullName')),
                    );
                    break;
                  case 'invite':
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Invitando a $fullName a partido'),
                      ),
                    );
                    break;
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'chat',
                      child: Row(
                        children: [
                          Icon(Icons.chat_bubble_outline),
                          SizedBox(width: 8),
                          Text('Chatear'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'invite',
                      child: Row(
                        children: [
                          Icon(Icons.sports_soccer),
                          SizedBox(width: 8),
                          Text('Invitar a partido'),
                        ],
                      ),
                    ),
                  ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline, size: 80, color: Colors.white54),
          const SizedBox(height: 16),
          const Text(
            'No tienes amigos aún',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Conecta con otros usuarios para agregar amigos',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Función de búsqueda de usuarios por implementar',
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2E7D32),
            ),
            child: const Text('Buscar usuarios'),
          ),
        ],
      ),
    );
  }
}
