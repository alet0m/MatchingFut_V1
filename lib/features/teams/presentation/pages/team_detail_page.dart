import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'manage_players_page.dart'; // Temporalmente deshabilitado para desbloquear build
import 'package:go_router/go_router.dart';
import '../../../teams/data/players_service.dart';
import '../../../../core/config/supabase_config.dart';

class TeamDetailPage extends ConsumerWidget {
  final dynamic
  team; // Usaremos dynamic por ahora hasta que arreglemos los imports

  const TeamDetailPage({super.key, required this.team});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int readElo(dynamic t) {
      // Soporta TeamModel.eloRating y legados con averageElo
      try {
        final v = t.eloRating;
        if (v is int) return v;
        if (v is num) return v.toInt();
      } catch (_) {}
      try {
        final v = t.averageElo;
        if (v is int) return v;
        if (v is num) return v.toInt();
      } catch (_) {}
      return 1200;
    }

    final playersCountAsync = ref.watch(teamPlayersCountProvider(team.id));
    final currentUser = ref.read(supabaseProvider).auth.currentUser;
    final bool isCaptain =
        currentUser?.id == (team.captainId ?? team.captain_id);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          team.name ?? 'Equipo',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        actions: [
          // Botón de Chat siempre visible
          IconButton(
            tooltip: 'Chat del equipo',
            icon: Icon(
              Icons.chat_bubble_outline,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: () {
              // Navega al chat del equipo usando GoRouter
              context.push('/teams/${team.id}/chat');
            },
          ),
          if (isCaptain)
            IconButton(
              icon: Icon(
                Icons.group_add,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Gestión de jugadores no disponible temporalmente',
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header del equipo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    radius: 40,
                    child: Text(
                      (team.name ?? 'T').substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    team.name ?? 'Equipo',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ELO: ${readElo(team)}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  // Botón CTA destacado para Chat
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.push('/teams/${team.id}/chat');
                      },
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Abrir chat del equipo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Estadísticas
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
                  Text(
                    'Estadísticas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(
                        context,
                        'Partidos',
                        '${team.totalMatches ?? 0}',
                      ),
                      _buildStatColumn(context, 'Ganados', '${team.wins ?? 0}'),
                      _buildStatColumn(
                        context,
                        'Empates',
                        '${team.draws ?? 0}',
                      ),
                      _buildStatColumn(
                        context,
                        'Perdidos',
                        '${team.losses ?? 0}',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Gestión de Jugadores
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
                children: [
                  Icon(
                    Icons.group,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Jugadores del Equipo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Contador de jugadores
                  playersCountAsync.when(
                    data:
                        (count) => Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  count >= 7
                                      ? Icons.check_circle
                                      : Icons.warning,
                                  color:
                                      count >= 7
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.primary
                                          : Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$count jugadores',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        count >= 7
                                            ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                            : Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              count >= 7
                                  ? 'Tu equipo está listo para partidos'
                                  : 'Necesitas al menos 7 jugadores para partidos',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    count >= 7
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Botón para gestionar jugadores (solo capitán)
                            if (isCaptain)
                              ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Gestión de jugadores no disponible temporalmente',
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.group_add),
                                label: Text(
                                  count == 0
                                      ? 'Agregar Jugadores'
                                      : 'Gestionar Jugadores',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                          ],
                        ),
                    loading: () => const CircularProgressIndicator(),
                    error:
                        (error, stack) => Column(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(height: 8),
                            Text('Error: $error'),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Gestión de jugadores no disponible temporalmente',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.group_add),
                              label: const Text('Gestionar Jugadores'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
