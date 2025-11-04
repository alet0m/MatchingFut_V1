import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/players_service.dart';
import '../../../../shared/models/team_model.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../data/friends_service.dart';
import '../../../../shared/models/friendship_model.dart';

class ManagePlayersPage extends ConsumerStatefulWidget {
  final TeamModel team;

  const ManagePlayersPage({super.key, required this.team});

  @override
  ConsumerState<ManagePlayersPage> createState() => _ManagePlayersPageState();
}

class _ManagePlayersPageState extends ConsumerState<ManagePlayersPage> {
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String _friendQuery = '';
  final Set<String> _selectedFriendIds = <String>{};
  bool _expandedFriends = false;

  final Map<String, IconData> _positionIcons = {
    'Portero': Icons.sports_handball,
    'Defensa': Icons.shield,
    'Mediocampo': Icons.swap_horiz,
    'Delantero': Icons.sports_soccer,
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Invitación individual removida: ahora usamos selección múltiple y acción en lote

  Future<void> _inviteSelectedFriends() async {
    if (_selectedFriendIds.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final playersService = ref.read(playersServiceProvider);
      for (final id in _selectedFriendIds) {
        try {
          await playersService.invitePlayerToTeam(
            teamId: widget.team.id,
            friendUserId: id,
          );
        } catch (e) {
          // Continuar con el resto; mostrar mensaje por cada fallo
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No se pudo invitar a uno de los amigos: $e'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
      // Limpiar selección y refrescar datos
      _selectedFriendIds.clear();
      ref.invalidate(teamPlayersProvider(widget.team.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invitaciones enviadas'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      }
      setState(() {});
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final playersAsync = ref.watch(teamPlayersProvider(widget.team.id));
    final friendsFuture = ref.read(friendsServiceProvider).getFriends();
    final pendingInvitesFuture = ref
        .read(playersServiceProvider)
        .getPendingInvitedUserIds(widget.team.id);
    final currentUser = Supabase.instance.client.auth.currentUser;
    final isCaptain = currentUser?.id == widget.team.captainId;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        title: Text(
          'Jugadores - ${widget.team.name}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(teamPlayersProvider(widget.team.id));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Agregar jugador (solo capitán): selector desde amigos
              if (isCaptain)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<Set<String>>(
                        future: pendingInvitesFuture,
                        builder: (context, invSnap) {
                          final pendingCount = invSnap.data?.length ?? 0;
                          return Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF2E7D32,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.person_add,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Invitar amigos',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                              const Spacer(),
                              if (pendingCount > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.hourglass_empty,
                                        color: Colors.orange,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$pendingCount pendientes',
                                        style: const TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Buscador de amigos
                      TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _friendQuery = value.trim().toLowerCase();
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Buscar amigo por nombre o email',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Lista de amigos elegibles (no miembros), con selección múltiple y expansión
                      FutureBuilder<List<FriendModel>>(
                        future: friendsFuture,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final friends = snapshot.data!;

                          // Cuando la búsqueda está vacía, mostramos un Top N de amigos ordenados por nombre
                          final filtered =
                              _friendQuery.isEmpty
                                  ? friends
                                  : friends
                                      .where(
                                        (f) =>
                                            f.fullName.toLowerCase().contains(
                                              _friendQuery,
                                            ) ||
                                            f.email.toLowerCase().contains(
                                              _friendQuery,
                                            ),
                                      )
                                      .toList();

                          final teamMembers = playersAsync.maybeWhen(
                            data: (players) => players,
                            orElse: () => const [],
                          );
                          final memberIds =
                              teamMembers.map((p) => p.userId).toSet();

                          // Orden alfabético
                          filtered.sort(
                            (a, b) => a.fullName.compareTo(b.fullName),
                          );

                          // Si no expandido y sin búsqueda, mostrar primeros N (p.ej., 6)
                          final int limit = 6;
                          final bool showAll =
                              _expandedFriends || _friendQuery.isNotEmpty;
                          final display =
                              showAll
                                  ? filtered
                                  : filtered.take(limit).toList();

                          if (display.isEmpty) {
                            return const Text(
                              'No hay amigos que coincidan con la búsqueda.',
                              style: TextStyle(color: Colors.grey),
                            );
                          }

                          return FutureBuilder<Set<String>>(
                            future: pendingInvitesFuture,
                            builder: (context, invSnap) {
                              final invited = invSnap.data ?? <String>{};
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Contador de seleccionados
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF2E7D32,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.checklist,
                                              color: Color(0xFF2E7D32),
                                              size: 16,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Seleccionados: ${_selectedFriendIds.length}',
                                              style: const TextStyle(
                                                color: Color(0xFF2E7D32),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Spacer(),
                                      TextButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            _expandedFriends =
                                                !_expandedFriends;
                                          });
                                        },
                                        icon: Icon(
                                          _expandedFriends
                                              ? Icons.expand_less
                                              : Icons.expand_more,
                                        ),
                                        label: Text(
                                          _expandedFriends
                                              ? 'Ver menos'
                                              : 'Ver más',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Lista de amigos con checkbox
                                  ...display.map((f) {
                                    final isMember = memberIds.contains(
                                      f.userId,
                                    );
                                    final isInvited = invited.contains(
                                      f.userId,
                                    );
                                    final isDisabled = isMember || isInvited;
                                    final selected = _selectedFriendIds
                                        .contains(f.userId);

                                    return ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 4,
                                            horizontal: 8,
                                          ),
                                      leading: Checkbox(
                                        value: selected && !isDisabled,
                                        onChanged:
                                            isDisabled
                                                ? null
                                                : (val) {
                                                  setState(() {
                                                    if (val == true) {
                                                      _selectedFriendIds.add(
                                                        f.userId,
                                                      );
                                                    } else {
                                                      _selectedFriendIds.remove(
                                                        f.userId,
                                                      );
                                                    }
                                                  });
                                                },
                                      ),
                                      title: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              f.fullName,
                                              style: TextStyle(
                                                color:
                                                    isDisabled
                                                        ? Colors.grey
                                                        : Colors.black,
                                              ),
                                            ),
                                          ),
                                          if (isMember)
                                            _buildBadge(
                                              'Miembro',
                                              const Color(0xFF2E7D32),
                                            ),
                                          if (!isMember && isInvited)
                                            _buildBadge(
                                              'Pendiente',
                                              Colors.orange,
                                            ),
                                        ],
                                      ),
                                      subtitle: Text(
                                        f.email,
                                        style: TextStyle(
                                          color:
                                              isDisabled
                                                  ? Colors.grey
                                                  : Colors.grey[700],
                                        ),
                                      ),
                                      trailing: CircleAvatar(
                                        backgroundColor: const Color(
                                          0xFF2E7D32,
                                        ),
                                        child: Text(
                                          (f.fullName.isNotEmpty
                                                  ? f.fullName[0]
                                                  : 'A')
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      onTap:
                                          isDisabled
                                              ? null
                                              : () {
                                                setState(() {
                                                  if (selected) {
                                                    _selectedFriendIds.remove(
                                                      f.userId,
                                                    );
                                                  } else {
                                                    _selectedFriendIds.add(
                                                      f.userId,
                                                    );
                                                  }
                                                });
                                              },
                                    );
                                  }),

                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton.icon(
                                      onPressed:
                                          _isLoading ||
                                                  _selectedFriendIds.isEmpty
                                              ? null
                                              : _inviteSelectedFriends,
                                      icon: const Icon(Icons.send),
                                      label: const Text(
                                        'Invitar seleccionados',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF2E7D32,
                                        ),
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Lista de jugadores
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.group,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Jugadores del Equipo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Lista de jugadores
                    playersAsync.when(
                      data: (players) {
                        if (players.isEmpty) {
                          return const EmptyStateWidget(
                            icon: Icons.group_add,
                            title: 'Sin jugadores',
                            description:
                                'Este equipo no tiene jugadores aún.\nAgrega el primer jugador para comenzar.',
                          );
                        }

                        return Column(
                          children: [
                            // Contador de jugadores
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    players.length >= 7
                                        ? const Color(
                                          0xFF2E7D32,
                                        ).withOpacity(0.1)
                                        : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    players.length >= 7
                                        ? Icons.check_circle
                                        : Icons.warning,
                                    color:
                                        players.length >= 7
                                            ? const Color(0xFF2E7D32)
                                            : Colors.orange,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${players.length} jugadores',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          players.length >= 7
                                              ? const Color(0xFF2E7D32)
                                              : Colors.orange,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    players.length >= 7
                                        ? '(Listo para partidos)'
                                        : '(Mínimo 7 para partidos)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          players.length >= 7
                                              ? const Color(0xFF2E7D32)
                                              : Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Lista de jugadores
                            ...players.map(
                              (player) => Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    // Icono de posición
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF2E7D32,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        _positionIcons[player.position] ??
                                            Icons.person,
                                        color: const Color(0xFF2E7D32),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Información del jugador
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                player.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              if (player.isCaptain) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFFFF6F00,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: const Text(
                                                    'CAPITÁN',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          Text(
                                            '${player.position} • ELO: ${player.elo}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                          if (player.email != null)
                                            Text(
                                              player.email!,
                                              style: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: 12,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),

                                    // Estadísticas rápidas
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        children: [
                                          Text(
                                            '${player.goalsScored}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2E7D32),
                                            ),
                                          ),
                                          const Text(
                                            'goles',
                                            style: TextStyle(fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const LoadingWidget(),
                      error:
                          (error, stack) => Center(
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),
                                Text('Error: $error'),
                              ],
                            ),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildBadge(String text, Color color) {
  return Container(
    margin: const EdgeInsets.only(left: 8),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
    ),
  );
}
