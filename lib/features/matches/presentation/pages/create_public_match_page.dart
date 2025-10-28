import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/matches_service.dart';
import '../../../teams/data/teams_service.dart';
import '../../../teams/data/players_service.dart';
import '../../../../shared/models/team_model.dart';

class CreatePublicMatchPage extends ConsumerStatefulWidget {
  const CreatePublicMatchPage({super.key});

  @override
  ConsumerState<CreatePublicMatchPage> createState() =>
      _CreatePublicMatchPageState();
}

class _CreatePublicMatchPageState extends ConsumerState<CreatePublicMatchPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  TeamModel? _selectedHomeTeam;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedComuna;
  int? _minEloRange;
  int? _maxEloRange;
  bool _isLoading = false;

  final List<String> _comunas = [
    'Quilicura',
    'Las Condes',
    'Providencia',
    'Santiago Centro',
    'Ñuñoa',
    'La Florida',
    'Maipú',
    'Puente Alto',
    'San Miguel',
    'Independencia',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar Partido'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createPublicMatch,
            child:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : const Text(
                      'Publicar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información del equipo anfitrión
              _buildSectionTitle('Tu equipo'),
              _buildHostTeamSelector(),

              const SizedBox(height: 24),

              // Información básica del partido
              _buildSectionTitle('Información del partido'),
              _buildMatchInfo(),

              const SizedBox(height: 24),

              // Fecha y hora
              _buildSectionTitle('Fecha y hora'),
              _buildDateTimeSelector(),

              const SizedBox(height: 24),

              // Ubicación y filtros
              _buildSectionTitle('Ubicación y filtros'),
              _buildLocationAndFilters(),

              const SizedBox(height: 32),

              // Botón crear
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createPublicMatch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Publicar Partido',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A1A),
        ),
      ),
    );
  }

  Widget _buildHostTeamSelector() {
    return FutureBuilder<List<TeamModel>>(
      future: _getUserTeams(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.red.shade600),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'No tienes equipos disponibles. Necesitas ser miembro de un equipo para crear partidos.',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        }

        final teams = snapshot.data!;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<TeamModel>(
            value: _selectedHomeTeam,
            decoration: const InputDecoration(
              labelText: 'Selecciona tu equipo',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.sports_soccer),
            ),
            items:
                teams.map((team) {
                  return DropdownMenuItem<TeamModel>(
                    value: team,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(
                            0xFF1976D2,
                          ).withValues(alpha: 0.1),
                          child: Text(
                            team.tag ?? team.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF1976D2),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(team.name)),
                      ],
                    ),
                  );
                }).toList(),
            onChanged: (team) {
              setState(() {
                _selectedHomeTeam = team;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Por favor selecciona un equipo';
              }
              return null;
            },
          ),
        );
      },
    );
  }

  Widget _buildMatchInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Título del partido',
              hintText: 'Ej: Busco rival para partido amistoso',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa un título';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              hintText: 'Describe el partido, nivel esperado, etc.',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa una descripción';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _selectedDate != null
                              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                              : 'Seleccionar fecha',
                          style: TextStyle(
                            color:
                                _selectedDate != null
                                    ? Colors.black
                                    : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: _selectTime,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _selectedTime != null
                              ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                              : 'Seleccionar hora',
                          style: TextStyle(
                            color:
                                _selectedTime != null
                                    ? Colors.black
                                    : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationAndFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _selectedComuna,
            decoration: const InputDecoration(
              labelText: 'Comuna',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
            ),
            items:
                _comunas.map((comuna) {
                  return DropdownMenuItem(value: comuna, child: Text(comuna));
                }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedComuna = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Por favor selecciona una comuna';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Ubicación específica',
              hintText: 'Ej: Cancha Municipal de Quilicura',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.place),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'ELO Mínimo',
                    hintText: '1200',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _minEloRange = int.tryParse(value);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'ELO Máximo',
                    hintText: '1400',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _maxEloRange = int.tryParse(value);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<List<TeamModel>> _getUserTeams() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return [];

      final teamsService = TeamsService(Supabase.instance.client);
      return await teamsService.getUserTeams(user.id);
    } catch (e) {
      return [];
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  Future<void> _createPublicMatch() async {
    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos requeridos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      final matchDate = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final supabase = Supabase.instance.client;
      final playersService = PlayersService(supabase);
      final matchesService = MatchesService(supabase, playersService);
      await matchesService.createPublicMatch(
        hostTeamId: _selectedHomeTeam!.id,
        title: _titleController.text,
        description: _descriptionController.text,
        matchDate: matchDate,
        comuna: _selectedComuna!,
        location:
            _locationController.text.isNotEmpty
                ? _locationController.text
                : null,
        minEloRange: _minEloRange,
        maxEloRange: _maxEloRange,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Partido publicado exitosamente'),
            backgroundColor: Color(0xFF1976D2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al publicar partido: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
