// ignore_for_file: deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../data/matches_service.dart';
import '../../../../shared/models/match_model.dart';

class MatchesPage extends ConsumerWidget {
  const MatchesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userMatches = ref.watch(userMatchesProvider);
    final upcomingMatches = ref.watch(upcomingMatchesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        title: const Text(
          'Partidos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              context.go('/matches/create');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userMatchesProvider);
          ref.invalidate(upcomingMatchesProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mis Partidos
              Text(
                'Mis Partidos',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ).animate().fadeIn(),

              const SizedBox(height: 16),

              userMatches.when(
                data:
                    (matches) =>
                        matches.isEmpty
                            ? _buildEmptyState(
                              'Sin partidos programados',
                              'Aún no tienes partidos programados.\n¡Crea tu primer partido!',
                              Icons.sports_soccer,
                            )
                            : _buildMatchesList(matches),
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (error, stackTrace) => _buildErrorState(
                      'Error al cargar partidos',
                      error.toString(),
                    ),
              ),

              const SizedBox(height: 30),

              // Próximos Partidos
              Text(
                'Próximos Partidos',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 16),

              upcomingMatches.when(
                data:
                    (matches) =>
                        matches.isEmpty
                            ? _buildEmptyState(
                              'No hay partidos próximos',
                              'No hay partidos programados próximamente',
                              Icons.schedule,
                            )
                            : _buildMatchesList(matches),
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (error, stackTrace) => _buildErrorState(
                      'Error al cargar partidos',
                      error.toString(),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchesList(List<MatchModel> matches) {
    return Column(
      children: matches.map((match) => _buildEnhancedMatchCard(match)).toList(),
    );
  }

  Widget _buildEnhancedMatchCard(MatchModel match) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        onTap: () => _showMatchDetails(match),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(match.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(match.status).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(match.status),
                          size: 14,
                          color: _getStatusColor(match.status),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getStatusText(match.status),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(match.status),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Fecha
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatDate(match.matchDate ?? DateTime.now()),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        _formatTime(match.matchDate ?? DateTime.now()),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Equipos
              Row(
                children: [
                  // Equipo Local
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: const Color(0xFF2E7D32).withOpacity(0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.home,
                            color: Color(0xFF2E7D32),
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'LOCAL',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getTeamName(match.homeTeamId ?? ''),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // VS / Marcador
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        if (match.status == 'finished')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF2E7D32).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              '${match.homeScore} - ${match.awayScore}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'VS',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Equipo Visitante
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.flight_takeoff,
                            color: Colors.orange,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'VISITANTE',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getTeamName(match.awayTeamId ?? ''),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Info adicional
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getMatchDescription(match),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().scale();
  }

  String _getTeamName(String teamId) {
    if (teamId.isEmpty) return 'Sin Equipo';

    // Generar nombre más descriptivo basado en el ID
    final shortId =
        teamId.length >= 6
            ? teamId.substring(0, 6).toUpperCase()
            : teamId.toUpperCase();
    final teamNames = [
      'Los Tigres $shortId',
      'Las Águilas $shortId',
      'FC $shortId',
      'Unidos $shortId',
      'Estrella $shortId',
    ];
    final index = teamId.hashCode % teamNames.length;
    return teamNames[index];
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'HOY';
    } else if (difference == 1) {
      return 'MAÑANA';
    } else if (difference == -1) {
      return 'AYER';
    } else {
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
      return '${date.day} ${months[date.month - 1]}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getMatchDescription(MatchModel match) {
    switch (match.status) {
      case 'scheduled':
        return 'Partido programado - Toca para ver detalles';
      case 'in_progress':
        return 'Partido en curso - Seguir marcador';
      case 'finished':
        return 'Partido finalizado - Ver estadísticas';
      case 'cancelled':
        return 'Partido cancelado';
      default:
        return 'Toca para más información';
    }
  }

  void _showMatchDetails(MatchModel match) {
    // TODO: Implementar modal con detalles completos
    print('Mostrar detalles del partido: ${match.id}');
  }

  Widget _buildEmptyState(String title, String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildErrorState(String title, String error) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'scheduled':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'finished':
        return const Color(0xFF2E7D32);
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'scheduled':
        return Icons.schedule;
      case 'in_progress':
        return Icons.play_circle_fill;
      case 'finished':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'scheduled':
        return 'Programado';
      case 'in_progress':
        return 'En Progreso';
      case 'finished':
        return 'Finalizado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return 'Desconocido';
    }
  }
}
