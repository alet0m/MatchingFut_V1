import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models.dart';
import '../data/maps_repository.dart';

/// Panel responsivo que muestra Canchas y Ranking según el tamaño de pantalla
class ResponsivePanel extends StatefulWidget {
  final String region;
  final String comuna;
  final MapsRepository repo;

  const ResponsivePanel({
    super.key,
    required this.region,
    required this.comuna,
    required this.repo,
  });

  @override
  State<ResponsivePanel> createState() => _ResponsivePanelState();
}

class _ResponsivePanelState extends State<ResponsivePanel> {
  // Eliminamos canchas: sólo ranking
  late Future<List<EquipoRank>> _rankingF;
  RealtimeChannel? _teamsChannel;

  @override
  void didUpdateWidget(covariant ResponsivePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.region != widget.region ||
        oldWidget.comuna != widget.comuna) {
      _load();
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
    _subscribeRealtime();
  }

  void _load() {
    _rankingF = widget.repo.fetchRanking(
      region: widget.region,
      comuna: widget.comuna,
    );
    setState(() {});
  }

  void _subscribeRealtime() {
    try {
      final client = Supabase.instance.client;
      _teamsChannel =
          client
              .channel('public:teams')
              .onPostgresChanges(
                event: PostgresChangeEvent.all,
                schema: 'public',
                table: 'teams',
                callback: (payload) {
                  // Cualquier cambio en equipos refresca el ranking
                  _load();
                },
              )
              .subscribe();
    } catch (_) {
      // Si Realtime no está disponible, simplemente no se subscribe
    }
  }

  @override
  void dispose() {
    try {
      if (_teamsChannel != null) {
        Supabase.instance.client.removeChannel(_teamsChannel!);
      }
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    final child =
        isWide
            ? _RankingCard(future: _rankingF, comunaName: widget.comuna)
            : _RankingCard(future: _rankingF, comunaName: widget.comuna);

    // En pantallas pequeñas o cuando el espacio vertical es limitado, permitir scroll
    return SingleChildScrollView(
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

/// Card que muestra ranking de equipos
class _RankingCard extends StatelessWidget {
  final Future<List<EquipoRank>> future;
  final String comunaName;

  const _RankingCard({required this.future, required this.comunaName});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<EquipoRank>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return _Error(message: 'No se pudo cargar el ranking.');
            }

            final data = snapshot.data ?? const <EquipoRank>[];
            if (data.isEmpty) {
              return const SizedBox(
                height: 120,
                child: Center(
                  child: Text(
                    'Sin ranking disponible.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            final visible = data.length > 15 ? data.take(15).toList() : data;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ranking',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: visible.length,
                  separatorBuilder: (_, __) => const Divider(height: 8),
                  itemBuilder: (context, index) {
                    final equipo = visible[index];
                    final isFirst = index == 0;
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading:
                          isFirst
                              ? CircleAvatar(
                                backgroundColor: Colors.amber,
                                child: const Icon(
                                  Icons.emoji_events,
                                  color: Colors.white,
                                ),
                              )
                              : CircleAvatar(
                                backgroundColor: _getRankColor(context, index),
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                      title: Text(
                        equipo.nombre,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: Text(
                        '${equipo.puntos} pts',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    );
                  },
                ),
                if (data.length > 15) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        final c = comunaName.trim();
                        if (c.isEmpty) {
                          context.push('/rankings');
                        } else {
                          final qp = Uri(queryParameters: {'comuna': c});
                          context.push('/rankings?${qp.query}');
                        }
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Ver todos'),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  /// Colores para medallas según posición
  Color _getRankColor(BuildContext context, int index) {
    switch (index) {
      case 0:
        return Colors.amber; // Oro
      case 1:
        return Colors.grey.shade400; // Plata
      case 2:
        return Colors.brown; // Bronce
      default:
        return Theme.of(context).colorScheme.primary; // Color del tema
    }
  }
}

/// Widget para mostrar errores con estilo consistente
class _Error extends StatelessWidget {
  final String message;

  const _Error({required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
