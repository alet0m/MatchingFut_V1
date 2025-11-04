import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../teams/data/players_service.dart';
import '../../../teams/data/teams_service.dart';
import '../providers/notifications_providers.dart';
import '../../../friends/providers/friends_providers.dart';
import '../../../../shared/models/user_model.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingInvites = ref.watch(pendingTeamInvitationsProvider);
    final friendRequests = ref.watch(friendRequestsProvider);
    final unreadByTeam = ref.watch(unreadChatByTeamProvider);

    return RefreshIndicator(
      onRefresh: () async {
        // Invalida y permite que los providers (Future/Stream) emitan el primer valor de nuevo
        ref.invalidate(pendingTeamInvitationsProvider);
        ref.invalidate(friendRequestsProvider);
        ref.invalidate(unreadChatByTeamProvider);
        // Evitar cuelgues esperando futuros de StreamProvider: pequeño delay es suficiente
        await Future.delayed(const Duration(milliseconds: 200));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Notificaciones',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _InvitationsSection(pendingInvites: pendingInvites),
          const SizedBox(height: 24),
          _FriendRequestsSection(friendRequests: friendRequests),
          const SizedBox(height: 24),
          _TeamChatsSection(unreadByTeam: unreadByTeam),
        ],
      ),
    );
  }
}

class _InvitationsSection extends ConsumerWidget {
  final AsyncValue pendingInvites;
  const _InvitationsSection({required this.pendingInvites});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.group_add, color: Color(0xFF2E7D32)),
            SizedBox(width: 8),
            Text(
              'Invitaciones a equipo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        pendingInvites.when(
          data: (list) {
            final invites = list as List;
            if (invites.isEmpty) {
              return _EmptyBox(
                icon: Icons.inbox_outlined,
                title: 'Sin invitaciones pendientes',
                subtitle: 'Cuando te inviten a un equipo, aparecerá aquí',
              );
            }
            return Column(
              children:
                  invites.map<Widget>((v) => _InvitationCard(view: v)).toList(),
            );
          },
          loading:
              () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
          error:
              (e, st) => _EmptyBox(
                icon: Icons.error_outline,
                title: 'Error al cargar',
                subtitle: e.toString(),
              ),
        ),
      ],
    );
  }
}

class _FriendRequestsSection extends ConsumerWidget {
  final AsyncValue friendRequests;
  const _FriendRequestsSection({required this.friendRequests});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.person_add_alt_1, color: Color(0xFF2E7D32)),
            SizedBox(width: 8),
            Text(
              'Solicitudes de amistad',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        friendRequests.when(
          data: (list) {
            final reqs = list as List<UserModel>;
            if (reqs.isEmpty) {
              return const _EmptyBox(
                icon: Icons.mail_outline,
                title: 'Sin solicitudes de amistad',
                subtitle: 'Cuando te envíen solicitudes, aparecerán aquí',
              );
            }
            return Column(
              children:
                  reqs.map<Widget>((u) => _FriendRequestCard(user: u)).toList(),
            );
          },
          loading:
              () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
          error:
              (e, st) => _EmptyBox(
                icon: Icons.error_outline,
                title: 'Error al cargar',
                subtitle: e.toString(),
              ),
        ),
      ],
    );
  }
}

class _InvitationCard extends ConsumerStatefulWidget {
  final dynamic view; // TeamInvitationView
  const _InvitationCard({required this.view});

  @override
  ConsumerState<_InvitationCard> createState() => _InvitationCardState();
}

class _InvitationCardState extends ConsumerState<_InvitationCard> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final v = widget.view;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFF2E7D32),
                  child: Icon(Icons.groups, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        v.teamName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Te invitó: ${v.inviterName}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        _loading
                            ? null
                            : () async {
                              await _handleRespond(accept: false);
                            },
                    icon: const Icon(Icons.close, color: Colors.black87),
                    label: const Text('Rechazar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        _loading
                            ? null
                            : () async {
                              await _handleRespond(accept: true);
                            },
                    icon: const Icon(Icons.check),
                    label: const Text('Aceptar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
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

  Future<void> _handleRespond({required bool accept}) async {
    setState(() => _loading = true);
    final players = ref.read(playersServiceProvider);
    final invId = widget.view.invitation.id as String;
    try {
      if (accept) {
        await players.acceptInvitation(invId);
      } else {
        await players.rejectInvitation(invId);
      }
      if (mounted) {
        ref.invalidate(pendingTeamInvitationsProvider);
        // También refrescar conteos globales de notificaciones
        ref.invalidate(friendRequestsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              accept ? '¡Invitación aceptada!' : 'Invitación rechazada',
            ),
            backgroundColor: accept ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _FriendRequestCard extends ConsumerStatefulWidget {
  final UserModel user;
  const _FriendRequestCard({required this.user});

  @override
  ConsumerState<_FriendRequestCard> createState() => _FriendRequestCardState();
}

class _FriendRequestCardState extends ConsumerState<_FriendRequestCard> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final u = widget.user;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFF2E7D32),
                  backgroundImage:
                      u.profileImageUrl != null
                          ? NetworkImage(u.profileImageUrl!)
                          : null,
                  child:
                      u.profileImageUrl == null
                          ? Text(
                            (u.fullName.isNotEmpty ? u.fullName[0] : '?')
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          )
                          : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        u.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        u.nickname != null ? '@${u.nickname}' : 'Jugador',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _loading ? null : () => _respond(accept: false),
                    icon: const Icon(Icons.close, color: Colors.black87),
                    label: const Text('Rechazar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : () => _respond(accept: true),
                    icon: const Icon(Icons.check),
                    label: const Text('Aceptar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
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

  Future<void> _respond({required bool accept}) async {
    setState(() => _loading = true);
    try {
      final friendsService = ref.read(friendsServiceProvider);
      await friendsService.respondToFriendRequest(widget.user.id, accept);
      if (mounted) {
        ref.invalidate(friendRequestsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              accept
                  ? '¡Solicitud aceptada! Ya son amigos'
                  : 'Solicitud rechazada',
            ),
            backgroundColor: accept ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _EmptyBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyBox({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 42, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _TeamChatsSection extends ConsumerWidget {
  final AsyncValue<Map<String, int>> unreadByTeam;
  const _TeamChatsSection({required this.unreadByTeam});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userTeamsAsync = ref.watch(userTeamsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.chat_bubble, color: Color(0xFF2E7D32)),
            SizedBox(width: 8),
            Text(
              'Chats de equipos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        unreadByTeam.when(
          data: (map) {
            final entries =
                map.entries.where((e) => e.value > 0).toList()
                  ..sort((a, b) => b.value.compareTo(a.value));
            if (entries.isEmpty) {
              return const _EmptyBox(
                icon: Icons.mark_chat_read_outlined,
                title: 'Sin mensajes no leídos',
                subtitle: 'Los nuevos mensajes aparecerán aquí',
              );
            }

            return userTeamsAsync.when(
              data: (teams) {
                final allowedIds = teams.map((t) => t.id).toSet();
                final filtered =
                    entries.where((e) => allowedIds.contains(e.key)).toList();
                if (filtered.isEmpty) {
                  return const _EmptyBox(
                    icon: Icons.groups_2_outlined,
                    title: 'Sin chats de tus equipos',
                    subtitle: 'Únete a un equipo para chatear',
                  );
                }

                final ids =
                    (filtered.map((e) => e.key).toSet().toList()..sort());
                final sig = ids.join(',');
                final namesAsync = ref.watch(teamNamesByIdsProvider(sig));
                return namesAsync.when(
                  data: (names) {
                    return Column(
                      children: [
                        for (final e in filtered)
                          _TeamChatRow(
                            teamId: e.key,
                            teamName: names[e.key] ?? 'Equipo',
                            unread: e.value,
                          ),
                      ],
                    );
                  },
                  loading:
                      () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  error:
                      (e, st) => _EmptyBox(
                        icon: Icons.error_outline,
                        title: 'Error al cargar nombres',
                        subtitle: e.toString(),
                      ),
                );
              },
              loading:
                  () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
              error:
                  (e, st) => _EmptyBox(
                    icon: Icons.error_outline,
                    title: 'Error al verificar membresía',
                    subtitle: e.toString(),
                  ),
            );
          },
          loading:
              () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
          error:
              (e, st) => _EmptyBox(
                icon: Icons.error_outline,
                title: 'Error al cargar chats',
                subtitle: e.toString(),
              ),
        ),
      ],
    );
  }
}

class _TeamChatRow extends StatelessWidget {
  final String teamId;
  final String teamName;
  final int unread;
  const _TeamChatRow({
    required this.teamId,
    required this.teamName,
    required this.unread,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFF2E7D32),
              child: Icon(Icons.groups, color: Colors.white),
            ),
            Positioned(
              right: -6,
              top: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6F00),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  unread > 99 ? '99+' : '$unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        title: Text(
          teamName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: const Text('Mensajes no leídos'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navegar directo al chat del equipo (GoRouter)
          context.push('/teams/$teamId/chat');
        },
      ),
    );
  }
}
