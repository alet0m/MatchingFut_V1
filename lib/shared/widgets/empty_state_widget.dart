import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;
  final Color? color;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.actionText,
    this.onAction,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? const Color(0xFF2E7D32);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 60, color: primaryColor),
                )
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut)
                .then()
                .shimmer(duration: 2000.ms),

            const SizedBox(height: 32),

            Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                )
                .animate()
                .fadeIn(duration: 800.ms, delay: 300.ms)
                .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 12),

            Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                )
                .animate()
                .fadeIn(duration: 800.ms, delay: 500.ms)
                .slideY(begin: 0.3, end: 0),

            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                    onPressed: onAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      actionText!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 800.ms, delay: 700.ms)
                  .slideY(begin: 0.3, end: 0)
                  .then()
                  .shimmer(duration: 2000.ms, delay: 1000.ms),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyTeamsWidget extends StatelessWidget {
  final VoidCallback onCreateTeam;

  const EmptyTeamsWidget({super.key, required this.onCreateTeam});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.group_add,
      title: '¡Forma tu primer equipo!',
      description:
          'Aún no tienes equipos creados.\nComienza formando tu equipo y únete a la competencia en Quilicura.',
      actionText: 'Crear Mi Primer Equipo',
      onAction: onCreateTeam,
      color: const Color(0xFF1976D2),
    );
  }
}

class EmptyMatchesWidget extends StatelessWidget {
  final VoidCallback onCreateMatch;

  const EmptyMatchesWidget({super.key, required this.onCreateMatch});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.sports_soccer,
      title: '¡Programa tu primer partido!',
      description:
          'No tienes partidos programados.\nDesafía a otros equipos y demuestra tu habilidad en la cancha.',
      actionText: 'Programar Partido',
      onAction: onCreateMatch,
      color: const Color(0xFFFF6F00),
    );
  }
}

class EmptySearchWidget extends StatelessWidget {
  final String searchTerm;

  const EmptySearchWidget({super.key, required this.searchTerm});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'Sin resultados',
      description:
          'No encontramos resultados para "$searchTerm".\nIntenta con otros términos de búsqueda.',
      color: Colors.grey[600],
    );
  }
}
