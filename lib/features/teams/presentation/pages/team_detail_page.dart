import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'manage_players_page.dart';
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: Text(
          team.name ?? 'Equipo',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Botón de Chat siempre visible
          IconButton(
            tooltip: 'Chat del equipo',
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            onPressed: () {
              // Navega al chat del equipo usando GoRouter
              context.push('/teams/${team.id}/chat');
            },
          ),
          if (isCaptain)
            IconButton(
              icon: const Icon(Icons.group_add, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManagePlayersPage(team: team),
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
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF2E7D32),
                    radius: 40,
                    child: Text(
                      (team.name ?? 'T').substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    team.name ?? 'Equipo',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
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
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
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
                  const Text(
                    'Estadísticas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('Partidos', '${team.totalMatches ?? 0}'),
                      _buildStatColumn('Ganados', '${team.wins ?? 0}'),
                      _buildStatColumn('Empates', '${team.draws ?? 0}'),
                      _buildStatColumn('Perdidos', '${team.losses ?? 0}'),
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
                children: [
                  const Icon(Icons.group, size: 48, color: Color(0xFF2E7D32)),
                  const SizedBox(height: 16),
                  const Text(
                    'Jugadores del Equipo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
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
                                          ? const Color(0xFF2E7D32)
                                          : Colors.orange,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$count jugadores',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        count >= 7
                                            ? const Color(0xFF2E7D32)
                                            : Colors.orange,
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
                                        ? const Color(0xFF2E7D32)
                                        : Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Botón para gestionar jugadores (solo capitán)
                            if (isCaptain)
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              ManagePlayersPage(team: team),
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
                                  backgroundColor: const Color(0xFF2E7D32),
                                  foregroundColor: Colors.white,
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            ManagePlayersPage(team: team),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.group_add),
                              label: const Text('Gestionar Jugadores'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                                foregroundColor: Colors.white,
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

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
