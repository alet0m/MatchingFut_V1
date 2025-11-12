import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../data/teams_service.dart';
import '../../../../shared/models/team_model.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import 'create_team_page_new.dart';
import 'team_detail_page.dart';
import 'teams_search_page.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';
import '../../../../shared/ui/app_snack.dart';

class TeamsPage extends ConsumerWidget {
  const TeamsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userTeams = ref.watch(userTeamsProvider);
    final topTeams = ref.watch(topTeamsProvider);

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Custom AppBar
          Container(
            color: Theme.of(context).colorScheme.primary,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(
                      'Equipos',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.search_rounded,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 28,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TeamsSearchPage(),
                          ),
                        );
                      },
                      tooltip: 'Buscar equipos',
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.add_rounded,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 24,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateTeamPageNew(),
                            ),
                          );
                        },
                        tooltip: 'Crear equipo',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(userTeamsProvider);
                ref.invalidate(topTeamsProvider);
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mis Equipos
                    _buildSection(
                      'Mis Equipos',
                      userTeams,
                      isUserTeams: true,
                      context: context,
                    ).animate().fadeIn(duration: 600.ms),

                    const SizedBox(height: 32),

                    // Top Equipos
                    _buildSection(
                      'Top Equipos',
                      topTeams,
                      isUserTeams: false,
                      context: context,
                    ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    AsyncValue<List<TeamModel>> teamsAsync, {
    required bool isUserTeams,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        teamsAsync.when(
          data: (teams) {
            if (teams.isEmpty) {
              return _buildEmptyState(isUserTeams, context);
            }
            return _buildTeamsList(teams, context);
          },
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(error.toString()),
        ),
      ],
    );
  }

  Widget _buildTeamsList(List<TeamModel> teams, BuildContext context) {
    return Column(
      children: teams.map((team) => _buildTeamCard(team, context)).toList(),
    );
  }

  Widget _buildTeamCard(TeamModel team, BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        // Obtener el usuario actual para verificar si es capitán
        final currentUser = ref.read(supabaseProvider).auth.currentUser;
        final isCaptain = currentUser?.id == team.captainId;
        final unreadMapAsync = ref.watch(unreadChatByTeamProvider);
        final unread = unreadMapAsync.asData?.value[team.id] ?? 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                team.name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    team.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (unread > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      unread > 99 ? '99+' : '$unread',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (isCaptain)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'CAPITÁN',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                if (team.tag?.isNotEmpty == true) ...[
                  Text(
                    '#${team.tag}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  'ELO: ${team.eloRating} • ${team.totalMatches} partidos',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildStatChip(
                      '${team.wins}G',
                      Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    _buildStatChip(
                      '${team.draws}E',
                      Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 4),
                    _buildStatChip(
                      '${team.losses}P',
                      Theme.of(context).colorScheme.error,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        // Navegar al chat del equipo
                        context.push('/teams/${team.id}/chat');
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: Row(
                        children: [
                          const Text('Chat'),
                          if (unread > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                unread > 99 ? '99+' : '$unread',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isCaptain)
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onSelected: (value) async {
                      switch (value) {
                        case 'edit':
                          await _editTeam(context, team);
                          break;
                        case 'delete':
                          await _deleteTeam(context, ref, team);
                          break;
                      }
                    },
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                const Text('Editar equipo'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Eliminar equipo',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                  ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.primary,
                  size: 16,
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TeamDetailPage(team: team),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isUserTeams, BuildContext context) {
    if (isUserTeams) {
      return EmptyTeamsWidget(
        onCreateTeam: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateTeamPageNew()),
          );
        },
      );
    } else {
      return EmptyStateWidget(
        icon: Icons.sports_soccer,
        title: 'No hay equipos disponibles',
        description:
            'Aún no hay equipos registrados en la plataforma.\n¡Sé el primero en crear uno!',
        color: Theme.of(context).colorScheme.primary,
      );
    }
  }

  Widget _buildLoadingState() {
    return const LoadingWidget(message: 'Cargando equipos...');
  }

  Widget _buildErrorState(String error) {
    return CustomErrorWidget(
      message: 'Por favor, verifica tu conexión e intenta nuevamente',
      onRetry: () {
        // El RefreshIndicator se encarga del retry
      },
    );
  }

  // Función para editar equipo
  Future<void> _editTeam(BuildContext context, TeamModel team) async {
    // Navegar a la página de edición (por ahora reutilizamos CreateTeamPage)
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder:
            (context) => const CreateTeamPageNew(), // TODO: Crear EditTeamPage
      ),
    );

    // Si se editó exitosamente, refrescar la lista
    if (result == true && context.mounted) {
      // Refrescar la lista de equipos
      AppSnack.success(context, '¡Equipo editado exitosamente!');
    }
  }

  // Función para eliminar equipo - VERSION SIMPLIFICADA
  Future<void> _deleteTeam(
    BuildContext context,
    WidgetRef ref,
    TeamModel team,
  ) async {
    try {
      // Verificar usuario actual
      final currentUser = ref.read(supabaseProvider).auth.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // Verificar permisos (capitán)
      if (team.captainId != currentUser.id) {
        AppSnack.error(context, 'Solo el capitán puede eliminar el equipo');
        return;
      }

      // Confirmación simple con ScaffoldMessenger
      final shouldDelete =
          await showDialog<bool>(
            context: context,
            builder:
                (ctx) => AlertDialog(
                  title: const Text('⚠️ Eliminar Equipo'),
                  content: Text(
                    '¿Eliminar "${team.name}"?\nEsta acción no se puede deshacer.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        'Eliminar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
          ) ??
          false;

      if (!shouldDelete) return;

      // Eliminar directamente sin loading dialog complicado
      final teamsService = ref.read(teamsServiceProvider);
      await teamsService.deleteTeam(teamId: team.id, userId: currentUser.id);

      // Refrescar datos
      ref.invalidate(userTeamsProvider);

      // Mensaje de éxito
      if (context.mounted) {
        AppSnack.success(context, '✅ Equipo eliminado');
      }
    } catch (e) {
      // Mensaje de error simple
      if (context.mounted) {
        AppSnack.error(
          context,
          '❌ Error: ${e.toString().replaceAll('Exception: ', '')}',
        );
      }
    }
  }
}
