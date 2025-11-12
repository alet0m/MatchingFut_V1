import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/public_match_model.dart';
import '../providers/public_matches_providers.dart';
import '../../data/public_matches_service.dart';
import '../../../teams/data/teams_service.dart';

class PublicMatchDetailPage extends ConsumerWidget {
  final String id;
  const PublicMatchDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(publicMatchDetailProvider(id));
    return Scaffold(
      appBar: AppBar(title: const Text('Partido público')),
      body: async.when(
        data: (m) => _DetailBody(match: m),
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (e, _) => Center(child: Text('No se pudo cargar el partido: $e')),
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  final PublicMatchModel match;
  const _DetailBody({required this.match});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final date = match.matchDate;
    final subtitle =
        date == null
            ? 'Fecha por definir'
            : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} • '
                '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.primaryContainer,
                child: Text(
                  (match.hostTeamTag ?? match.hostTeamName ?? '?')
                      .substring(0, 1)
                      .toUpperCase(),
                  style: TextStyle(color: color.onPrimaryContainer),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match.title ?? match.hostTeamName ?? 'Partido público',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (match.description != null && match.description!.isNotEmpty)
            Text(match.description!, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (match.modalityType != null)
                Chip(
                  label: Text(
                    'Modalidad: ${_modalityText(match.modalityType!)}',
                  ),
                ),
              if (match.minPlayers != null || match.maxPlayers != null)
                Chip(label: Text(_playersText(match))),
              if (match.minEloRange != null && match.maxEloRange != null)
                Chip(
                  label: Text(
                    'División: ${match.minEloRange}-${match.maxEloRange} ELO',
                  ),
                ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.push('/teams/${match.hostTeamId}');
                  },
                  child: const Text('Ver perfil del equipo'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final teams = await ref.read(userTeamsProvider.future);
                    if (teams.isEmpty) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No tienes un equipo para desafiar.'),
                          ),
                        );
                      }
                      return;
                    }
                    // For now, pick the first team. Could open a selector.
                    final myTeamId = teams.first.id;
                    try {
                      await ref
                          .read(publicMatchesServiceProvider)
                          .acceptPublicMatch(
                            publicMatchId: match.id,
                            awayTeamId: myTeamId,
                          );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Desafío enviado. Partido creado.'),
                          ),
                        );
                        context.go('/matches');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                  child: const Text('Desafiar con mi equipo'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _playersText(PublicMatchModel m) {
    final min = m.minPlayers ?? m.fieldPlayers;
    final max = m.maxPlayers ?? m.fieldPlayers;
    if (min == null && max == null) return 'Jugadores a definir';
    if (min != null && max != null && min != max) return '$min–$max por equipo';
    final v = min ?? max;
    return '$v por equipo';
  }

  String _modalityText(String key) {
    switch (key) {
      case 'futbolito':
        return 'Futbolito';
      case 'f11':
      case 'futbol11':
        return 'Fútbol 11';
      default:
        return 'Modalidad';
    }
  }
}
