// ignore_for_file: avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/matches_service.dart';
import '../../../teams/data/teams_service.dart';
import '../../../../shared/models/team_model.dart';

class CreateMatchPage extends ConsumerStatefulWidget {
  const CreateMatchPage({super.key});

  @override
  ConsumerState<CreateMatchPage> createState() => _CreateMatchPageState();
}

class _CreateMatchPageState extends ConsumerState<CreateMatchPage> {
  final _formKey = GlobalKey<FormState>();
  final _opponentSearchController = TextEditingController();
  TeamModel? _selectedHomeTeam;
  TeamModel? _selectedAwayTeam;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;
  bool _showOpponentSearch = false;
  List<TeamModel> _opponentSearchResults = [];

  @override
  void dispose() {
    _opponentSearchController.dispose();
    super.dispose();
  }

  void _searchOpponentTeams(String query, List<TeamModel> allTeams) {
    if (query.isEmpty) {
      setState(() {
        _opponentSearchResults = [];
        _showOpponentSearch = false;
      });
      return;
    }

    final results =
        allTeams
            .where((team) {
              if (team.id == _selectedHomeTeam?.id) return false;
              final nameMatch = team.name.toLowerCase().contains(
                query.toLowerCase(),
              );
              final tagMatch =
                  team.tag?.toLowerCase().contains(query.toLowerCase()) ??
                  false;
              return nameMatch || tagMatch;
            })
            .take(5)
            .toList();

    setState(() {
      _opponentSearchResults = results;
      _showOpponentSearch = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userTeams = ref.watch(userTeamsProvider);
    final allTeams = ref.watch(topTeamsProvider);

    return Container(
      child: Column(
        children: [
          // Header simple
          Container(
            color: const Color(0xFF2E7D32),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Text(
                      'Crear Partido',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Contenido
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Equipo local
                      const Text(
                        'Tu Equipo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildHomeTeamSelector(userTeams),

                      const SizedBox(height: 32),

                      // Equipo rival
                      const Text(
                        'Equipo Rival',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildOpponentSearch(allTeams),

                      const SizedBox(height: 32),

                      // Fecha y hora
                      const Text(
                        'Fecha & Hora',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDateTimeSelector(),

                      const SizedBox(height: 40),

                      // Botón crear
                      _buildCreateButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTeamSelector(AsyncValue<List<TeamModel>> userTeams) {
    return userTeams.when(
      data: (teams) {
        if (teams.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('Primero debes crear un equipo'),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<TeamModel>(
            value: _selectedHomeTeam,
            hint: const Text('Selecciona tu equipo'),
            items:
                teams
                    .map(
                      (team) =>
                          DropdownMenuItem(value: team, child: Text(team.name)),
                    )
                    .toList(),
            onChanged: (team) {
              setState(() {
                _selectedHomeTeam = team;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Debes seleccionar un equipo';
              }
              return null;
            },
          ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }

  Widget _buildOpponentSearch(AsyncValue<List<TeamModel>> allTeams) {
    return allTeams.when(
      data:
          (teams) => Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: _opponentSearchController,
                  onChanged: (value) => _searchOpponentTeams(value, teams),
                  decoration: const InputDecoration(
                    hintText: 'Buscar equipo rival...',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),

              if (_showOpponentSearch && _opponentSearchResults.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _opponentSearchResults.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final team = _opponentSearchResults[index];
                      return ListTile(
                        title: Text(team.name),
                        subtitle:
                            team.tag != null ? Text('#${team.tag}') : null,
                        onTap: () {
                          setState(() {
                            _selectedAwayTeam = team;
                            _opponentSearchController.text = team.name;
                            _showOpponentSearch = false;
                          });
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }

  Widget _buildDateTimeSelector() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedDate != null
                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                    : 'Seleccionar fecha',
                style: const TextStyle(fontSize: 16),
              ),
              TextButton(
                onPressed: _selectDate,
                child: const Text('Cambiar fecha'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedTime != null
                    ? '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                    : 'Seleccionar hora',
                style: const TextStyle(fontSize: 16),
              ),
              TextButton(
                onPressed: _selectTime,
                child: const Text('Cambiar hora'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCreateButton() {
    final canCreate =
        _selectedHomeTeam != null &&
        _selectedAwayTeam != null &&
        _selectedDate != null &&
        _selectedTime != null;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: canCreate && !_isLoading ? _createMatch : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child:
            _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                  'Crear Partido',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
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

  Future<void> _createMatch() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      final matchDate = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final matchesService = ref.read(matchesServiceProvider);
      await matchesService.createMatch(
        homeTeamId: _selectedHomeTeam!.id,
        awayTeamId: _selectedAwayTeam!.id,
        matchDate: matchDate,
        createdBy: currentUser.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Partido creado exitosamente'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear partido: $e'),
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
}
