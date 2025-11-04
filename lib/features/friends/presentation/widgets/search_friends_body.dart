import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/friends_providers.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/ui/app_snack.dart';

class SearchFriendsBody extends ConsumerStatefulWidget {
  const SearchFriendsBody({super.key});

  @override
  ConsumerState<SearchFriendsBody> createState() => _SearchFriendsBodyState();
}

class _SearchFriendsBodyState extends ConsumerState<SearchFriendsBody> {
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _searchResults = [];
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [_buildSearchBar(), Expanded(child: _buildSearchResults())],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o nickname...',
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
          ),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimary.withOpacity(0.7),
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _clearSearch();
                    },
                  )
                  : null,
          filled: true,
          fillColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
              width: 2,
            ),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
          _performSearch(value);
        },
        onSubmitted: _performSearch,
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchQuery.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Busca amigos futboleros',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Escribe el nombre o nickname de la persona que buscas',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_isSearching) {
      return const LoadingWidget();
    }

    if (_searchResults.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No se encontraron usuarios',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No hay usuarios que coincidan con "$_searchQuery"',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Theme.of(context).colorScheme.primary,
          backgroundImage:
              user.profileImageUrl != null
                  ? NetworkImage(user.profileImageUrl!)
                  : null,
          child:
              user.profileImageUrl == null
                  ? Text(
                    user.fullName.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                  : null,
        ),
        title: Text(
          user.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((user.nickname ?? '').isNotEmpty)
              Text(
                '@${user.nickname}',
                style: const TextStyle(color: Colors.grey),
              ),
          ],
        ),
        trailing: _buildActionButton(user),
        onTap: () => context.push('/profile/${user.id}'),
      ),
    );
  }

  Widget _buildActionButton(UserModel user) {
    return FutureBuilder<String?>(
      future: ref.read(friendsServiceProvider).getPendingRequestStatus(user.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        final status = snapshot.data;

        if (status == 'sent') {
          return Chip(
            label: const Text('Enviado', style: TextStyle(fontSize: 12)),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            labelStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          );
        }

        if (status == 'received') {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Rechazar',
                onPressed: () => _respondToRequest(user.id, false),
                icon: const Icon(Icons.close, color: Colors.red),
              ),
              const SizedBox(width: 4),
              ElevatedButton.icon(
                onPressed: () => _respondToRequest(user.id, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                ),
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Aceptar', style: TextStyle(fontSize: 12)),
              ),
            ],
          );
        }

        return FutureBuilder<bool>(
          future: ref.read(friendsServiceProvider).areFriends(user.id),
          builder: (context, friendshipSnapshot) {
            if (friendshipSnapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            }

            final areFriends = friendshipSnapshot.data ?? false;

            if (areFriends) {
              return Chip(
                label: const Text('Amigos', style: TextStyle(fontSize: 12)),
                backgroundColor: Theme.of(context).colorScheme.primary,
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              );
            }

            return ElevatedButton.icon(
              onPressed: () => _sendFriendRequest(user),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              icon: const Icon(Icons.person_add, size: 16),
              label: const Text('Agregar', style: TextStyle(fontSize: 12)),
            );
          },
        );
      },
    );
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final friendsService = ref.read(friendsServiceProvider);
      final results = await friendsService.searchUsers(query.trim());

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });

        AppSnack.error(context, 'Error en la búsqueda: $e');
      }
    }
  }

  void _clearSearch() {
    setState(() {
      _searchResults = [];
      _isSearching = false;
      _searchQuery = '';
    });
  }

  Future<void> _sendFriendRequest(UserModel user) async {
    try {
      final friendsService = ref.read(friendsServiceProvider);
      await friendsService.sendFriendRequest(user.id);

      if (mounted) {
        AppSnack.success(context, 'Solicitud enviada a ${user.fullName}');

        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        AppSnack.error(context, 'Error: $e');
      }
    }
  }

  Future<void> _respondToRequest(String requesterUserId, bool accept) async {
    try {
      final friendsService = ref.read(friendsServiceProvider);
      await friendsService.respondToFriendRequest(requesterUserId, accept);

      if (mounted) {
        ref.invalidate(friendRequestsProvider);
        ref.invalidate(friendsProvider);
        if (accept) {
          AppSnack.success(context, 'Solicitud aceptada');
        } else {
          AppSnack.warning(context, 'Solicitud rechazada');
        }
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        AppSnack.error(context, 'Error: $e');
      }
    }
  }
}
