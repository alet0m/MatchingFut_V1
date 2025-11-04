import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/players_service.dart';
import '../../../../shared/models/team_model.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../data/friends_service.dart';
import '../../../../shared/models/friendship_model.dart';
import '../../../../shared/ui/app_snack.dart';

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
            AppSnack.error(
              context,
              'No se pudo invitar a uno de los amigos: $e',
            );
          }
        }
      }
      // Limpiar selección y refrescar datos
      _selectedFriendIds.clear();
      ref.invalidate(teamPlayersProvider(widget.team.id));
      if (mounted) {
        AppSnack.success(context, 'Invitaciones enviadas');
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
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          'Jugadores - ${widget.team.name}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
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
                    color: Theme.of(context).colorScheme.surface,
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
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.person_add,
                                  color: Theme.of(context).colorScheme.primary,
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

                                  final Map<String, IconData> _positionIcons = const {
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
                                          if (mounted) AppSnack.error(context, 'No se pudo invitar: $e');
                                        }
                                      }
                                      _selectedFriendIds.clear();
                                      ref.invalidate(teamPlayersProvider(widget.team.id));
                                      if (mounted) AppSnack.success(context, 'Invitaciones enviadas');
                                      setState(() {});
                                    } finally {
                                      if (mounted) setState(() => _isLoading = false);
                                    }
                                  }

                                  @override
                                  Widget build(BuildContext context) {
                                    final playersAsync = ref.watch(teamPlayersProvider(widget.team.id));
                                    final friendsFuture = ref.read(friendsServiceProvider).getFriends();
                                    final pendingInvitesFuture =
                                        ref.read(playersServiceProvider).getPendingInvitedUserIds(widget.team.id);
                                    final currentUser = Supabase.instance.client.auth.currentUser;
                                    final isCaptain = currentUser?.id == widget.team.captainId;

                                    final scheme = Theme.of(context).colorScheme;

                                    return Scaffold(
                                      backgroundColor: scheme.background,
                                      appBar: AppBar(
                                        backgroundColor: scheme.surface,
                                        elevation: 0,
                                        title: Text(
                                          'Jugadores - ${widget.team.name}',
                                          style: TextStyle(
                                            color: scheme.onSurface,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        iconTheme: IconThemeData(color: scheme.onSurface),
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
                                              if (isCaptain)
                                                _buildInviteCard(context, scheme, friendsFuture, pendingInvitesFuture, playersAsync),
                                              const SizedBox(height: 24),
                                              _buildPlayersSection(context, scheme, playersAsync),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  Widget _buildInviteCard(
                                    BuildContext context,
                                    ColorScheme scheme,
                                    Future<List<FriendModel>> friendsFuture,
                                    Future<Set<String>> pendingInvitesFuture,
                                    AsyncValue<List<dynamic>> playersAsync,
                                  ) {
                                    return Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: scheme.surface,
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
                                                      color: scheme.primary.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Icon(Icons.person_add, color: scheme.primary),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    'Invitar amigos',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: scheme.primary,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  if (pendingCount > 0)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: scheme.secondary.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.hourglass_empty, color: scheme.secondary, size: 16),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            '$pendingCount pendientes',
                                                            style: TextStyle(color: scheme.secondary, fontWeight: FontWeight.w600),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          TextField(
                                            controller: _searchController,
                                            onChanged: (value) => setState(() => _friendQuery = value.trim().toLowerCase()),
                                            decoration: InputDecoration(
                                              labelText: 'Buscar amigo por nombre o email',
                                              prefixIcon: const Icon(Icons.search),
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          FutureBuilder<List<FriendModel>>(
                                            future: friendsFuture,
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                                              final friends = snapshot.data!;
                                              final filtered = _friendQuery.isEmpty
                                                  ? friends
                                                  : friends
                                                      .where((f) => f.fullName.toLowerCase().contains(_friendQuery) || f.email.toLowerCase().contains(_friendQuery))
                                                      .toList();

                                              final teamMembers = playersAsync.maybeWhen(data: (players) => players, orElse: () => const []);
                                              final memberIds = teamMembers.map((p) => p.userId).toSet();

                                              filtered.sort((a, b) => a.fullName.compareTo(b.fullName));
                                              final limit = 6;
                                              final showAll = _expandedFriends || _friendQuery.isNotEmpty;
                                              final display = showAll ? filtered : filtered.take(limit).toList();

                                              if (display.isEmpty) {
                                                return Text(
                                                  'No hay amigos que coincidan con la búsqueda.',
                                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                                );
                                              }

                                              return FutureBuilder<Set<String>>(
                                                future: pendingInvitesFuture,
                                                builder: (context, invSnap) {
                                                  final invited = invSnap.data ?? <String>{};
                                                  return Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                            decoration: BoxDecoration(
                                                              color: scheme.primary.withOpacity(0.1),
                                                              borderRadius: BorderRadius.circular(12),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Icon(Icons.checklist, color: scheme.primary, size: 16),
                                                                const SizedBox(width: 6),
                                                                Text(
                                                                  'Seleccionados: ${_selectedFriendIds.length}',
                                                                  style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w600),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const Spacer(),
                                                          TextButton.icon(
                                                            onPressed: () => setState(() => _expandedFriends = !_expandedFriends),
                                                            icon: Icon(_expandedFriends ? Icons.expand_less : Icons.expand_more),
                                                            label: Text(_expandedFriends ? 'Ver menos' : 'Ver más'),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 8),
                                                      ...display.map((f) {
                                                        final isMember = memberIds.contains(f.userId);
                                                        final isInvited = invited.contains(f.userId);
                                                        final isDisabled = isMember || isInvited;
                                                        final selected = _selectedFriendIds.contains(f.userId);
                                                        return ListTile(
                                                          contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                                          leading: Checkbox(
                                                            value: selected && !isDisabled,
                                                            onChanged: isDisabled
                                                                ? null
                                                                : (val) => setState(() {
                                                                      if (val == true) {
                                                                        _selectedFriendIds.add(f.userId);
                                                                      } else {
                                                                        _selectedFriendIds.remove(f.userId);
                                                                      }
                                                                    }),
                                                          ),
                                                          title: Row(
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  f.fullName,
                                                                  style: TextStyle(color: isDisabled ? Colors.grey : Colors.black),
                                                                ),
                                                              ),
                                                              if (isMember) _buildBadge('Miembro', scheme.primary),
                                                              if (!isMember && isInvited) _buildBadge('Pendiente', scheme.secondary),
                                                            ],
                                                          ),
                                                          subtitle: Text(
                                                            f.email,
                                                            style: TextStyle(color: isDisabled ? Colors.grey : Colors.grey[700]),
                                                          ),
                                                          trailing: CircleAvatar(
                                                            backgroundColor: scheme.primary,
                                                            child: Text(
                                                              (f.fullName.isNotEmpty ? f.fullName[0] : 'A').toUpperCase(),
                                                              style: TextStyle(color: scheme.onPrimary, fontWeight: FontWeight.bold),
                                                            ),
                                                          ),
                                                          onTap: isDisabled
                                                              ? null
                                                              : () => setState(() {
                                                                    if (selected) {
                                                                      _selectedFriendIds.remove(f.userId);
                                                                    } else {
                                                                      _selectedFriendIds.add(f.userId);
                                                                    }
                                                                  }),
                                                        );
                                                      }),
                                                      const SizedBox(height: 12),
                                                      Align(
                                                        alignment: Alignment.centerRight,
                                                        child: ElevatedButton.icon(
                                                          onPressed: _isLoading || _selectedFriendIds.isEmpty ? null : _inviteSelectedFriends,
                                                          icon: const Icon(Icons.send),
                                                          label: const Text('Invitar seleccionados'),
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: scheme.primary,
                                                            foregroundColor: scheme.onPrimary,
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
                                    );
                                  }

                                  Widget _buildPlayersSection(
                                    BuildContext context,
                                    ColorScheme scheme,
                                    AsyncValue<List<dynamic>> playersAsync,
                                  ) {
                                    return Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: scheme.surface,
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
                                                  color: scheme.primary.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Icon(Icons.group, color: scheme.primary),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                'Jugadores del Equipo',
                                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: scheme.primary),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                          playersAsync.when(
                                            data: (players) {
                                              if (players.isEmpty) {
                                                return const EmptyStateWidget(
                                                  icon: Icons.group_add,
                                                  title: 'Sin jugadores',
                                                  description: 'Este equipo no tiene jugadores aún.\nAgrega el primer jugador para comenzar.',
                                                );
                                              }
                                              return Column(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(12),
                                                    decoration: BoxDecoration(
                                                      color: (players.length >= 7 ? scheme.primary : scheme.secondary).withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(players.length >= 7 ? Icons.check_circle : Icons.warning,
                                                            color: players.length >= 7 ? scheme.primary : scheme.secondary),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          '${players.length} jugadores',
                                                          style: TextStyle(fontWeight: FontWeight.bold, color: players.length >= 7 ? scheme.primary : scheme.secondary),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          players.length >= 7 ? '(Listo para partidos)' : '(Mínimo 7 para partidos)',
                                                          style: TextStyle(fontSize: 12, color: players.length >= 7 ? scheme.primary : scheme.secondary),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  ...players.map((player) => Container(
                                                        margin: const EdgeInsets.only(bottom: 12),
                                                        padding: const EdgeInsets.all(16),
                                                        decoration: BoxDecoration(
                                                          border: Border.all(color: scheme.outlineVariant),
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              padding: const EdgeInsets.all(8),
                                                              decoration: BoxDecoration(
                                                                color: scheme.primary.withOpacity(0.1),
                                                                borderRadius: BorderRadius.circular(8),
                                                              ),
                                                              child: Icon(_positionIcons[player.position] ?? Icons.person, color: scheme.primary),
                                                            ),
                                                            const SizedBox(width: 12),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Text(player.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                                                      if (player.isCaptain) ...[
                                                                        const SizedBox(width: 8),
                                                                        Container(
                                                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                                          decoration: BoxDecoration(
                                                                            color: scheme.secondary,
                                                                            borderRadius: BorderRadius.circular(12),
                                                                          ),
                                                                          child: const Text('CAPITÁN', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                                                        ),
                                                                      ],
                                                                    ],
                                                                  ),
                                                                  Text('${player.position} • ELO: ${player.elo}',
                                                                      style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14)),
                                                                  if (player.email != null)
                                                                    Text(player.email!, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
                                                                ],
                                                              ),
                                                            ),
                                                            Container(
                                                              padding: const EdgeInsets.all(8),
                                                              child: Column(
                                                                children: [
                                                                  Text('${player.goalsScored}',
                                                                      style: TextStyle(fontWeight: FontWeight.bold, color: scheme.primary)),
                                                                  const Text('goles', style: TextStyle(fontSize: 10)),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )),
                                                ],
                                              );
                                            },
                                            loading: () => const LoadingWidget(),
                                            error: (error, stack) => Center(
                                              child: Column(
                                                children: const [
                                                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                                                  SizedBox(height: 16),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                }
                                    ),
