import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/players_service.dart';
import '../../../../shared/models/team_model.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

class ManagePlayersPage extends ConsumerStatefulWidget {
  final TeamModel team;

  const ManagePlayersPage({super.key, required this.team});

  @override
  ConsumerState<ManagePlayersPage> createState() => _ManagePlayersPageState();
}

class _ManagePlayersPageState extends ConsumerState<ManagePlayersPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedPosition = 'Delantero';
  bool _isLoading = false;

  final List<String> _positions = [
    'Portero',
    'Defensa',
    'Mediocampo',
    'Delantero',
  ];

  final Map<String, IconData> _positionIcons = {
    'Portero': Icons.sports_handball,
    'Defensa': Icons.shield,
    'Mediocampo': Icons.swap_horiz,
    'Delantero': Icons.sports_soccer,
  };

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _addPlayer() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa el nombre del jugador'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      final playersService = ref.read(playersServiceProvider);
      await playersService.addPlayerToTeam(
        teamId: widget.team.id,
        userId: currentUser.id, // Por ahora usamos el usuario actual
        name: _nameController.text.trim(),
        email:
            _emailController.text.trim().isNotEmpty
                ? _emailController.text.trim()
                : null,
        position: _selectedPosition,
      );

      // Limpiar formulario
      _nameController.clear();
      _emailController.clear();
      setState(() {
        _selectedPosition = 'Delantero';
      });

      // Refrescar lista
      ref.invalidate(teamPlayersProvider(widget.team.id));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Jugador agregado exitosamente!'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al agregar jugador: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final playersAsync = ref.watch(teamPlayersProvider(widget.team.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        title: Text(
          'Jugadores - ${widget.team.name}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(teamPlayersProvider(widget.team.id));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Formulario para agregar jugador
              Container(
                padding: const EdgeInsets.all(20),
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.person_add,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Agregar Nuevo Jugador',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Nombre del jugador
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre del jugador',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email (opcional)
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email (opcional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Selector de posición
                    DropdownButtonFormField<String>(
                      value: _selectedPosition,
                      decoration: InputDecoration(
                        labelText: 'Posición',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(_positionIcons[_selectedPosition]),
                      ),
                      items:
                          _positions.map((position) {
                            return DropdownMenuItem(
                              value: position,
                              child: Row(
                                children: [
                                  Icon(_positionIcons[position]),
                                  const SizedBox(width: 8),
                                  Text(position),
                                ],
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedPosition = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // Botón agregar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _addPlayer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text(
                                  'Agregar Jugador',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Lista de jugadores
              Container(
                padding: const EdgeInsets.all(20),
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.group,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Jugadores del Equipo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Lista de jugadores
                    playersAsync.when(
                      data: (players) {
                        if (players.isEmpty) {
                          return const EmptyStateWidget(
                            icon: Icons.group_add,
                            title: 'Sin jugadores',
                            description:
                                'Este equipo no tiene jugadores aún.\nAgrega el primer jugador para comenzar.',
                          );
                        }

                        return Column(
                          children: [
                            // Contador de jugadores
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    players.length >= 7
                                        ? const Color(
                                          0xFF2E7D32,
                                        ).withOpacity(0.1)
                                        : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    players.length >= 7
                                        ? Icons.check_circle
                                        : Icons.warning,
                                    color:
                                        players.length >= 7
                                            ? const Color(0xFF2E7D32)
                                            : Colors.orange,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${players.length} jugadores',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          players.length >= 7
                                              ? const Color(0xFF2E7D32)
                                              : Colors.orange,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    players.length >= 7
                                        ? '(Listo para partidos)'
                                        : '(Mínimo 7 para partidos)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          players.length >= 7
                                              ? const Color(0xFF2E7D32)
                                              : Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Lista de jugadores
                            ...players.map(
                              (player) => Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    // Icono de posición
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF2E7D32,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        _positionIcons[player.position] ??
                                            Icons.person,
                                        color: const Color(0xFF2E7D32),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Información del jugador
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                player.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              if (player.isCaptain) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFFFF6F00,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: const Text(
                                                    'CAPITÁN',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          Text(
                                            '${player.position} • ELO: ${player.elo}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                          if (player.email != null)
                                            Text(
                                              player.email!,
                                              style: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: 12,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),

                                    // Estadísticas rápidas
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        children: [
                                          Text(
                                            '${player.goalsScored}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2E7D32),
                                            ),
                                          ),
                                          const Text(
                                            'goles',
                                            style: TextStyle(fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const LoadingWidget(),
                      error:
                          (error, stack) => Center(
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),
                                Text('Error: $error'),
                              ],
                            ),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
