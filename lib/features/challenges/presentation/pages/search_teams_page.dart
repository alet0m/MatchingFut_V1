// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/team_model.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../core/config/supabase_config.dart';
import '../../data/challenges_service.dart';

class SearchTeamsPage extends ConsumerStatefulWidget {
  final String currentTeamId;

  const SearchTeamsPage({super.key, required this.currentTeamId});

  @override
  ConsumerState<SearchTeamsPage> createState() => _SearchTeamsPageState();
}

class _SearchTeamsPageState extends ConsumerState<SearchTeamsPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _searchQuery;
  String? _selectedComuna;
  int? _minElo;
  int? _maxElo;
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableTeamsAsync = ref.watch(
      availableTeamsProvider((
        currentTeamId: widget.currentTeamId,
        searchQuery: _searchQuery,
        comuna: _selectedComuna,
        minElo: _minElo,
        maxElo: _maxElo,
      )),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Buscar Equipos'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barra de búsqueda y filtros
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Campo de búsqueda
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar equipos...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = null;
                              });
                            },
                          ),
                        IconButton(
                          icon: Icon(
                            _showFilters
                                ? Icons.filter_alt
                                : Icons.filter_alt_outlined,
                            color:
                                _showFilters ? const Color(0xFFFF6F00) : null,
                          ),
                          onPressed: () {
                            setState(() {
                              _showFilters = !_showFilters;
                            });
                          },
                        ),
                      ],
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim().isEmpty ? null : value.trim();
                    });
                  },
                ),

                // Panel de filtros
                if (_showFilters) ...[
                  const SizedBox(height: 16),
                  _buildFiltersPanel(),
                ],
              ],
            ),
          ),

          // Lista de equipos
          Expanded(
            child: availableTeamsAsync.when(
              data: (teams) {
                if (teams.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildTeamsList(teams);
              },
              loading: () => const LoadingWidget(),
              error:
                  (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 50, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error al cargar equipos: $error'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref.invalidate(availableTeamsProvider);
                          },
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text(
            'No se encontraron equipos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Intenta con otro término de búsqueda',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamsList(List<TeamModel> teams) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final team = teams[index];
        return _buildTeamCard(team);
      },
    );
  }

  Widget _buildTeamCard(TeamModel team) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar del equipo
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(
                team.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Información del equipo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.emoji_events, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'ELO: ${team.eloRating}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.sports_soccer,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${team.totalMatches} partidos',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_city,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Quilicura', // Por ahora solo Quilicura, pero se puede agregar team.comuna cuando esté disponible
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Indicador de nivel ELO con color
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getEloColor(team.eloRating),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _getEloLevel(team.eloRating),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Botón de desafiar
          ElevatedButton.icon(
            onPressed: () => _showChallengeDialog(team),
            icon: const Icon(Icons.flash_on, size: 18),
            label: const Text('Retar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6F00),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  void _showChallengeDialog(TeamModel team) {
    final TextEditingController messageController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Row(
                    children: [
                      const Icon(Icons.flash_on, color: Color(0xFFFF6F00)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Retar a ${team.name}',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Mensaje (opcional):'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: messageController,
                        decoration: const InputDecoration(
                          hintText: '¡Acepta el desafío si te atreves!',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      const Text('Fecha propuesta (opcional):'),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(
                              const Duration(days: 7),
                            ),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 90),
                            ),
                          );
                          if (date != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: const TimeOfDay(hour: 18, minute: 0),
                            );
                            if (time != null) {
                              setDialogState(() {
                                selectedDate = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                selectedDate != null
                                    ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} ${selectedDate!.hour}:${selectedDate!.minute.toString().padLeft(2, '0')}'
                                    : 'Seleccionar fecha',
                                style: TextStyle(
                                  color:
                                      selectedDate != null
                                          ? Colors.black
                                          : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton.icon(
                      onPressed:
                          () => _sendChallenge(
                            team,
                            messageController.text,
                            selectedDate,
                          ),
                      icon: const Icon(Icons.send, size: 18),
                      label: const Text('Enviar Desafío'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6F00),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  void _sendChallenge(
    TeamModel team,
    String message,
    DateTime? proposedDate,
  ) async {
    try {
      Navigator.pop(context); // Cerrar diálogo

      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final challengesService = ref.read(challengesServiceProvider);
      final currentUser = ref.read(supabaseProvider).auth.currentUser;

      await challengesService.createChallenge(
        challengerTeamId: widget.currentTeamId,
        challengedTeamId: team.id,
        message: message.trim().isEmpty ? null : message.trim(),
        proposedDate: proposedDate,
        createdBy: currentUser!.id,
      );

      // Cerrar loading
      if (mounted) {
        Navigator.pop(context);
      }

      // Mostrar éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Desafío enviado a ${team.name}'),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
      }

      // Volver a la página anterior con un pequeño delay
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    } catch (e) {
      // Cerrar loading si hay error
      if (mounted) {
        Navigator.pop(context);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar desafío: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildFiltersPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtros de Búsqueda',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Filtro por Comuna
          Row(
            children: [
              const Icon(Icons.location_city, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              const Text('Comuna:', style: TextStyle(color: Colors.white70)),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedComuna,
                    hint: const Text('Todas las comunas'),
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text('Todas las comunas'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'quilicura',
                        child: Text('Quilicura'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedComuna = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Filtro por ELO
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              const Text('ELO:', style: TextStyle(color: Colors.white70)),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    // ELO Mínimo
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<int>(
                          value: _minElo,
                          hint: const Text(
                            'Min',
                            style: TextStyle(fontSize: 14),
                          ),
                          isExpanded: true,
                          underline: const SizedBox.shrink(),
                          items: const [
                            DropdownMenuItem<int>(
                              value: null,
                              child: Text('Sin mín'),
                            ),
                            DropdownMenuItem<int>(
                              value: 800,
                              child: Text('800+'),
                            ),
                            DropdownMenuItem<int>(
                              value: 1000,
                              child: Text('1000+'),
                            ),
                            DropdownMenuItem<int>(
                              value: 1200,
                              child: Text('1200+'),
                            ),
                            DropdownMenuItem<int>(
                              value: 1400,
                              child: Text('1400+'),
                            ),
                            DropdownMenuItem<int>(
                              value: 1600,
                              child: Text('1600+'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _minElo = value;
                              // Si el mínimo es mayor al máximo, ajustar máximo
                              if (_maxElo != null &&
                                  value != null &&
                                  value > _maxElo!) {
                                _maxElo = null;
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // ELO Máximo
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<int>(
                          value: _maxElo,
                          hint: const Text(
                            'Max',
                            style: TextStyle(fontSize: 14),
                          ),
                          isExpanded: true,
                          underline: const SizedBox.shrink(),
                          items: const [
                            DropdownMenuItem<int>(
                              value: null,
                              child: Text('Sin máx'),
                            ),
                            DropdownMenuItem<int>(
                              value: 1200,
                              child: Text('1200-'),
                            ),
                            DropdownMenuItem<int>(
                              value: 1400,
                              child: Text('1400-'),
                            ),
                            DropdownMenuItem<int>(
                              value: 1600,
                              child: Text('1600-'),
                            ),
                            DropdownMenuItem<int>(
                              value: 1800,
                              child: Text('1800-'),
                            ),
                            DropdownMenuItem<int>(
                              value: 2000,
                              child: Text('2000-'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _maxElo = value;
                              // Si el máximo es menor al mínimo, ajustar mínimo
                              if (_minElo != null &&
                                  value != null &&
                                  _minElo! > value) {
                                _minElo = null;
                              }
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Botón para limpiar filtros
          if (_selectedComuna != null || _minElo != null || _maxElo != null)
            Center(
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedComuna = null;
                    _minElo = null;
                    _maxElo = null;
                  });
                },
                icon: const Icon(Icons.clear_all, color: Colors.white),
                label: const Text(
                  'Limpiar Filtros',
                  style: TextStyle(color: Colors.white),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6F00).withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Color(0xFFFF6F00)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getEloColor(int elo) {
    if (elo >= 1600) return const Color(0xFF4CAF50); // Verde - Experto
    if (elo >= 1400) return const Color(0xFFFF9800); // Naranja - Avanzado
    if (elo >= 1200) return const Color(0xFF2196F3); // Azul - Intermedio
    if (elo >= 1000) return const Color(0xFF9C27B0); // Púrpura - Principiante
    return const Color(0xFF757575); // Gris - Novato
  }

  String _getEloLevel(int elo) {
    if (elo >= 1600) return 'EXPERTO';
    if (elo >= 1400) return 'AVANZADO';
    if (elo >= 1200) return 'INTERMEDIO';
    if (elo >= 1000) return 'PRINCIPIANTE';
    return 'NOVATO';
  }
}
