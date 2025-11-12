import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/public_match_model.dart';
import '../providers/public_matches_providers.dart';

class ExplorePublicMatchesPage extends ConsumerWidget {
  const ExplorePublicMatchesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Explorar Partidos')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _FiltersBar(),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer(
                builder: (context, ref, _) {
                  final async = ref.watch(publicMatchesFeedProvider);
                  return async.when(
                    data:
                        (rows) =>
                            rows.isEmpty
                                ? _EmptyState(
                                  onCreateTap:
                                      () =>
                                          context.push('/create-public-match'),
                                )
                                : ListView.separated(
                                  itemCount: rows.length,
                                  separatorBuilder:
                                      (_, __) => const SizedBox(height: 12),
                                  itemBuilder:
                                      (context, i) =>
                                          _MatchCard(match: rows[i]),
                                ),
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error:
                        (e, st) => Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No se pudieron cargar los partidos',
                                style: theme.textTheme.bodyMedium,
                              ),
                              Text(
                                '${e}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: color.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FiltersBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final comunas = ref.watch(comunasListProvider);
    final selectedId = ref.watch(selectedComunaIdProvider);
    final byLevel = ref.watch(filterByMyLevelProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Buscar por Comuna',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            comunas.when(
              data: (rows) {
                return DropdownButtonFormField<String>(
                  value: selectedId,
                  isExpanded: true,
                  items:
                      rows
                          .map(
                            (c) => DropdownMenuItem<String>(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          )
                          .toList(),
                  onChanged:
                      (val) =>
                          ref.read(selectedComunaIdProvider.notifier).state =
                              val,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.map),
                  ),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error:
                  (e, _) => Text(
                    'Error cargando comunas: $e',
                    style: theme.textTheme.bodySmall,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.filter_alt_outlined),
                const SizedBox(width: 8),
                Text('Nivel', style: theme.textTheme.titleSmall),
                const SizedBox(width: 12),
                SegmentedButton<bool>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: false, label: Text('Todos')),
                    ButtonSegment(value: true, label: Text('Mi nivel')),
                  ],
                  selected: {byLevel},
                  onSelectionChanged:
                      (s) =>
                          ref.read(filterByMyLevelProvider.notifier).state =
                              s.first,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchCard extends ConsumerWidget {
  final PublicMatchModel match;
  const _MatchCard({required this.match});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final date = match.matchDate;

    String subtitle = '';
    if (date != null) {
      final d =
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
      final t =
          '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      subtitle = '$d • $t';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
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
                        match.hostTeamName ?? 'Equipo anfitrión',
                        style: theme.textTheme.titleMedium,
                      ),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                    ],
                  ),
                ),
                if (match.minEloRange != null && match.maxEloRange != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.secondaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${match.minEloRange}-${match.maxEloRange} ELO',
                      style: TextStyle(
                        color: color.onSecondaryContainer,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (match.description != null && match.description!.isNotEmpty)
              Text(
                match.description!.length > 100
                    ? '${match.description!.substring(0, 100)}…'
                    : match.description!,
                style: theme.textTheme.bodyMedium,
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (match.minPlayers != null || match.maxPlayers != null)
                  _SmallChip(
                    icon: Icons.people_alt,
                    label: _playersText(match),
                  ),
                const SizedBox(width: 8),
                if (match.modalityType != null)
                  _SmallChip(
                    icon: Icons.sports_soccer,
                    label: _modalityText(match.modalityType!),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push('/public-match/${match.id}'),
                  child: const Text('Ver partido'),
                ),
              ],
            ),
          ],
        ),
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

class _SmallChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SmallChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreateTap;
  const _EmptyState({required this.onCreateTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sports_soccer, size: 64),
          const SizedBox(height: 12),
          const Text('No hay partidos públicos en esta comuna todavía.'),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onCreateTap,
            child: const Text('Crear partido'),
          ),
        ],
      ),
    );
  }
}
