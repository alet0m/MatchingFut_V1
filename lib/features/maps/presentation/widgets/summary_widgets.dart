import 'package:flutter/material.dart';
import '../services/ranking_service.dart';

class SummaryMetrics extends StatefulWidget {
  final String? comunaId; // por ahora se muestran métricas globales
  const SummaryMetrics({super.key, required this.comunaId});

  @override
  State<SummaryMetrics> createState() => _SummaryMetricsState();
}

class _SummaryMetricsState extends State<SummaryMetrics> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = RankingService().getGlobalSummaryMetrics();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final data =
            snap.data ?? const {'total_active_teams': 0, 'avg_top10_elo': 0};
        final totalTeams = (data['total_active_teams'] as num?)?.toInt() ?? 0;
        final avgTop10 = (data['avg_top10_elo'] as num?)?.toInt() ?? 0;

        return Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.groups,
                title: 'Equipos activos',
                value: '$totalTeams',
                color: scheme.primaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                icon: Icons.trending_up,
                title: 'ELO Top 10 (prom)',
                value: '$avgTop10',
                color: scheme.secondaryContainer,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: scheme.onPrimaryContainer.withOpacity(0.1),
            child: Icon(icon, color: scheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HottestSectors extends StatefulWidget {
  final String? comunaId;
  const HottestSectors({super.key, required this.comunaId});

  @override
  State<HottestSectors> createState() => _HottestSectorsState();
}

class _HottestSectorsState extends State<HottestSectors> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    if (widget.comunaId == null || widget.comunaId!.isEmpty) {
      return [];
    }
    return RankingService().getHottestSectors(widget.comunaId!, limit: 5);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.comunaId == null) {
      return const SizedBox.shrink();
    }
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sectores más disputados',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final items = snap.data ?? const [];
            if (items.isEmpty) {
              return Text(
                'No hay datos disponibles para esta comuna todavía.',
                style: TextStyle(color: scheme.onSurfaceVariant),
              );
            }
            return Column(children: items.map((e) => _SectorRow(e)).toList());
          },
        ),
      ],
    );
  }
}

class _SectorRow extends StatelessWidget {
  final Map<String, dynamic> data;
  const _SectorRow(this.data);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sectorName = (data['name'] ?? '') as String;
    final totalMatches = (data['total_matches'] as num?)?.toInt() ?? 0;
    final controlChanges = (data['control_changes'] as num?)?.toInt() ?? 0;
    final controlling = data['controlling_team'] as Map<String, dynamic>?;
    final controllerName =
        controlling != null
            ? (controlling['name'] ?? '') as String
            : 'Sin controlador';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          child: const Icon(
            Icons.local_fire_department,
            color: Colors.redAccent,
          ),
        ),
        title: Text(sectorName, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          'Partidos: $totalMatches  •  Cambios de control: $controlChanges\nControl: $controllerName',
        ),
        isThreeLine: true,
      ),
    );
  }
}
