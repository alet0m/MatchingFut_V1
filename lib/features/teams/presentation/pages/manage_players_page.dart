import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../teams/data/players_service.dart';
import '../../../../shared/models/player_model.dart';

class ManagePlayersPage extends ConsumerStatefulWidget {
  final String teamId;
  final String teamName;
  final bool isCaptain;
  const ManagePlayersPage({
    super.key,
    required this.teamId,
    required this.teamName,
    required this.isCaptain,
  });

  @override
  ConsumerState<ManagePlayersPage> createState() => _ManagePlayersPageState();
}

class _ManagePlayersPageState extends ConsumerState<ManagePlayersPage> {
  Future<void> _changePosition(PlayerModel p) async {
    final positions = <String>[
      'Portero',
      'Defensa',
      'Mediocampo',
      'Delantero',
      'Polivalente',
    ];
    String? selected = p.position ?? 'Polivalente';

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cambiar posición'),
          content: DropdownButtonFormField<String>(
            value: selected,
            items:
                positions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
            onChanged: (v) => selected = v,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selected != null) {
                  try {
                    await ref
                        .read(playersServiceProvider)
                        .updatePlayerPosition(
                          teamId: widget.teamId,
                          userId: p.userId,
                          position: selected!,
                        );
                    if (mounted) Navigator.pop(context);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Posición actualizada'),
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                        ),
                      );
                    }
                    setState(() {});
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _remove(PlayerModel p) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remover jugador'),
            content: Text('¿Remover a ${p.name} del equipo?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Remover'),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      try {
        await ref
            .read(playersServiceProvider)
            .removePlayerFromTeam(teamId: widget.teamId, userId: p.userId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Jugador removido'),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
          );
        }
        setState(() {});
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final playersAsync = ref.watch(teamPlayersProvider(widget.teamId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Jugadores - ${widget.teamName}'),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      floatingActionButton:
          widget.isCaptain
              ? FloatingActionButton.extended(
                onPressed: () {
                  // Por ahora redirigimos al módulo de Amigos para invitar.
                  context.push('/friends');
                },
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                icon: const Icon(Icons.person_add),
                label: const Text('Invitar amigo'),
              )
              : null,
      body: playersAsync.when(
        data: (players) {
          if (players.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.group_outlined,
                      size: 64,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Aún no hay jugadores',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.isCaptain
                          ? 'Usa el botón "Invitar amigo" para sumar jugadores.'
                          : 'Pídele al capitán que invite jugadores.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: players.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final p = players[i];
              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: scheme.primary,
                    child: Text(
                      p.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(child: Text(p.name)),
                      if (p.isCaptain)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'CAPITÁN',
                            style: TextStyle(
                              color: scheme.secondary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(
                    '${p.position ?? 'Sin posición'} • ELO ${p.elo}',
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                  trailing:
                      widget.isCaptain && !p.isCaptain
                          ? PopupMenuButton<String>(
                            onSelected: (v) async {
                              switch (v) {
                                case 'position':
                                  await _changePosition(p);
                                  break;
                                case 'remove':
                                  await _remove(p);
                                  break;
                              }
                            },
                            itemBuilder:
                                (context) => const [
                                  PopupMenuItem(
                                    value: 'position',
                                    child: Text('Cambiar posición'),
                                  ),
                                  PopupMenuItem(
                                    value: 'remove',
                                    child: Text('Remover del equipo'),
                                  ),
                                ],
                          )
                          : null,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
