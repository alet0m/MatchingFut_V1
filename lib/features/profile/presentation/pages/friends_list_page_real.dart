// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../teams/data/providers/friends_providers.dart';

class FriendsListPageReal extends ConsumerStatefulWidget {
  const FriendsListPageReal({super.key});

  @override
  ConsumerState<FriendsListPageReal> createState() =>
      _FriendsListPageRealState();
}

class _FriendsListPageRealState extends ConsumerState<FriendsListPageReal> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.white),
            onPressed: () => _showAddFriendDialog(context),
          ),
        ],
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
                return _buildPendingRequestsSection(requests);
              },
              loading: () => const SizedBox.shrink(),
              error: (error, _) => const SizedBox.shrink(),
            ),

            // Lista de amigos
            Expanded(
              child: friendsList.when(
                data: (friends) {
                  if (friends.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildFriendsList(friends);
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
                            onPressed: () => ref.refresh(friendsListProvider),
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

  Widget _buildPendingRequestsSection(List<dynamic> requests) {
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
          ...requests.map((request) => _buildPendingRequestCard(request)),
        ],
      ),
    );
  }

  Widget _buildPendingRequestCard(dynamic request) {
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
                  onPressed: () => _acceptRequest(requestId),
                  icon: const Icon(Icons.check, color: Colors.green),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.green.withOpacity(0.1),
                  ),
                ),
                IconButton(
                  onPressed: () => _rejectRequest(requestId),
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

  Widget _buildFriendsList(List<dynamic> friends) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        return _buildFriendCard(friend);
      },
    );
  }

  Widget _buildFriendCard(dynamic friend) {
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
                      color:
                          friend['is_online'] == true
                              ? Colors.green
                              : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child:
                        (friend['profile_image_url'] != null &&
                                (friend['profile_image_url'] as String)
                                    .isNotEmpty)
                            ? Image.network(
                              friend['profile_image_url'],
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
                if (friend['is_online'] == true)
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
                    friend['full_name'] ?? 'Sin nombre',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    friend['email'] ?? '',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  if (friend['friendship_date'] != null)
                    Text(
                      'Amigos desde: ${_formatDate(DateTime.parse(friend['friendship_date']))}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),

            // Botones de acción
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'chat':
                    _startChat(friend);
                    break;
                  case 'invite':
                    _inviteToMatch(friend);
                    break;
                  case 'remove':
                    _confirmRemoveFriend(friend);
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
                    const PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(Icons.person_remove, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Eliminar amigo',
                            style: TextStyle(color: Colors.red),
                          ),
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

  Widget _buildEmptyState() {
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
            'Busca usuarios y agrégalos como amigos',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showAddFriendDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2E7D32),
            ),
            child: const Text('Agregar amigos'),
          ),
        ],
      ),
    );
  }

  void _showAddFriendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Agregar amigo'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Email del usuario',
                    hintText: 'ejemplo@email.com',
                    prefixIcon: Icon(Icons.email),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty && value.contains('@')) {
                      ref.read(userSearchProvider.notifier).searchUsers(value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Resultados de búsqueda
                Consumer(
                  builder: (context, ref, child) {
                    final searchResults = ref.watch(userSearchProvider);
                    return searchResults.when(
                      data: (users) {
                        if (users.isEmpty) return const SizedBox.shrink();
                        return Container(
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      user['profile_image_url'] != null
                                          ? NetworkImage(
                                            user['profile_image_url'],
                                          )
                                          : null,
                                  child:
                                      user['profile_image_url'] == null
                                          ? const Icon(Icons.person)
                                          : null,
                                ),
                                title: Text(user['full_name'] ?? 'Sin nombre'),
                                subtitle: Text(user['email']),
                                trailing: IconButton(
                                  icon: const Icon(Icons.person_add),
                                  onPressed: () {
                                    _sendFriendRequest(user['email']);
                                    Navigator.pop(context);
                                  },
                                ),
                              );
                            },
                          ),
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (error, _) => Text('Error: $error'),
                    );
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  ref.read(userSearchProvider.notifier).clearSearch();
                  _searchController.clear();
                  Navigator.pop(context);
                },
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_searchController.text.isNotEmpty) {
                    _sendFriendRequest(_searchController.text);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Enviar solicitud'),
              ),
            ],
          ),
    );
  }

  void _sendFriendRequest(String email) async {
    try {
      final result = await ref.read(sendFriendRequestProvider(email).future);

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Solicitud enviada a $email'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Error al enviar solicitud'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      // Refrescar la lista
      ref.invalidate(friendsListProvider);
      ref.invalidate(pendingRequestsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _acceptRequest(String requestId) async {
    try {
      final result = await ref.read(
        acceptFriendRequestProvider(requestId).future,
      );

      if (result) {
        ref.invalidate(friendsListProvider);
        ref.invalidate(pendingRequestsProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Solicitud aceptada'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo aceptar la solicitud'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _rejectRequest(String requestId) async {
    try {
      final result = await ref.read(
        rejectFriendRequestProvider(requestId).future,
      );

      if (result) {
        ref.invalidate(pendingRequestsProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Solicitud rechazada'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo rechazar la solicitud'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _startChat(dynamic friend) {
    // TODO: Implementar chat
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Iniciando chat con ${friend['full_name']}')),
    );
  }

  void _inviteToMatch(dynamic friend) {
    // TODO: Implementar invitación a partido
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invitando a ${friend['full_name']} a partido')),
    );
  }

  void _confirmRemoveFriend(dynamic friend) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar amigo'),
            content: Text(
              '¿Estás seguro de que quieres eliminar a ${friend['full_name']} de tu lista de amigos?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  _removeFriend(friend);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }

  void _removeFriend(dynamic friend) async {
    try {
      final friendId = friend['userId'] ?? friend['friend_user_id'];
      if (friendId != null) {
        final result = await ref.read(removeFriendProvider(friendId).future);

        if (result) {
          ref.invalidate(friendsListProvider);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${friend['full_name']} eliminado de amigos'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No se pudo eliminar al amigo'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
