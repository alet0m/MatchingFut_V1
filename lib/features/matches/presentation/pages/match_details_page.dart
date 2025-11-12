import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/matches_providers.dart';
import '../../../../shared/ui/app_snack.dart';

class MatchDetailsPage extends ConsumerWidget {
  final String matchId;
  const MatchDetailsPage({super.key, required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMatch = ref.watch(matchProvider(matchId));
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del partido'),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      body: asyncMatch.when(
        data: (match) {
          if (match == null) {
            return _buildEmpty(
              context,
              'No se encontró el partido o no tienes permisos.',
            );
          }

          final isChallenge = match.isPublic && match.guestTeamId == null;
          final date = match.scheduledDate;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(
                          context,
                          match.status,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _statusLabel(match.status),
                        style: TextStyle(
                          color: _statusColor(context, match.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (match.isPublic)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isChallenge ? 'DESAFÍO' : 'PÚBLICO',
                          style: TextStyle(
                            color: scheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Local',
                                style: TextStyle(color: Colors.grey),
                              ),
                              Text(
                                match.hostTeamName ?? 'Equipo Local',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            if (match.hostTeamScore != null &&
                                match.guestTeamScore != null)
                              Text(
                                '${match.hostTeamScore} - ${match.guestTeamScore}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: scheme.primary,
                                ),
                              )
                            else
                              const Text(
                                'VS',
                                style: TextStyle(color: Colors.grey),
                              ),
                          ],
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Visitante',
                                style: TextStyle(color: Colors.grey),
                              ),
                              Text(
                                match.guestTeamName ?? 'Por definir…',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_month, color: scheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              _formatDate(date),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.schedule, color: scheme.primary),
                            const SizedBox(width: 8),
                            Text(_formatTime(date)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(child: Text(match.location)),
                          ],
                        ),
                        if ((match.description ?? '').trim().isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(match.description!.trim()),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (isChallenge)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await ref
                              .read(matchesServiceProvider)
                              .joinPublicMatch(match.id);
                          if (context.mounted) {
                            AppSnack.success(context, 'Te uniste al desafío');
                            // Volver a la lista o refrescar
                            ref.invalidate(matchProvider(match.id));
                            context.pop();
                          }
                        } catch (e) {
                          if (context.mounted) {
                            AppSnack.error(context, 'No se pudo unir: $e');
                          }
                        }
                      },
                      icon: const Icon(Icons.group_add),
                      label: const Text('Aceptar desafío'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _buildEmpty(context, 'Error: $e'),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sports_soccer,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(msg, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
  String _formatTime(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  String _statusLabel(String status) {
    switch (status) {
      case 'scheduled':
      case 'pending':
        return 'PROGRAMADO';
      case 'active':
      case 'live':
        return 'EN VIVO';
      case 'finished':
        return 'FINALIZADO';
      case 'cancelled':
        return 'CANCELADO';
      default:
        return status.toUpperCase();
    }
  }

  Color _statusColor(BuildContext context, String status) {
    final scheme = Theme.of(context).colorScheme;
    switch (status) {
      case 'scheduled':
      case 'pending':
        return scheme.secondary;
      case 'active':
      case 'live':
        return Colors.red;
      case 'finished':
        return scheme.primary;
      case 'cancelled':
        return scheme.surfaceContainerHighest;
      default:
        return scheme.surfaceContainerHighest;
    }
  }
}
