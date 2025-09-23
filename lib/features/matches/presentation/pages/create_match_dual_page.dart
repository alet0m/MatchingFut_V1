import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/team_model.dart';
import '../../../../shared/models/comuna_model.dart';
import '../../data/providers/team_search_provider.dart';
import '../../data/providers/direct_matches_provider.dart';
import '../../data/providers/public_matches_provider.dart';

class CreateMatchDualPage extends ConsumerStatefulWidget {
  const CreateMatchDualPage({super.key});

  @override
  ConsumerState<CreateMatchDualPage> createState() =>
      _CreateMatchDualPageState();
}

class _CreateMatchDualPageState extends ConsumerState<CreateMatchDualPage> {
  // Estado de la página
  int _selectedOption = 0; // 0 = Desafío, 1 = Publicación
  TeamModel? _selectedRival;
  ComunaModel? _selectedComuna;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  // Controladores de formulario
  final _descriptionController = TextEditingController();
  final _teamSearchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _descriptionController.dispose();
    _teamSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [_buildHeader(), Expanded(child: _buildContent())],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Crear Partido',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Elige tu modalidad preferida',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildToggleButtons(),
              const SizedBox(height: 24),
              _buildEloInfo(),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child:
                      _selectedOption == 0
                          ? _buildDirectChallengeForm()
                          : _buildPublicMatchForm(),
                ),
              ),
              const SizedBox(height: 24),
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedOption = 0),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color:
                      _selectedOption == 0 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow:
                      _selectedOption == 0
                          ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : null,
                ),
                child: const Center(
                  child: Text(
                    '⚡ Desafío Directo',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedOption = 1),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color:
                      _selectedOption == 1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow:
                      _selectedOption == 1
                          ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : null,
                ),
                child: const Center(
                  child: Text(
                    '🏆 Partido Público',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEloInfo() {
    final multiplier = _selectedOption == 0 ? 0.8 : 1.0;
    final bonus = _selectedOption == 1 ? '+20%' : '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              _selectedOption == 0
                  ? [Colors.orange.shade100, Colors.orange.shade50]
                  : [Colors.green.shade100, Colors.green.shade50],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  _selectedOption == 0
                      ? Colors.orange.shade200
                      : Colors.green.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _selectedOption == 0 ? Icons.flash_on : Icons.emoji_events,
              color:
                  _selectedOption == 0
                      ? Colors.orange.shade700
                      : Colors.green.shade700,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedOption == 0
                      ? '⚡ ELO Reducido (${multiplier}x)'
                      : '🏆 ELO Completo + Bonus $bonus',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color:
                        _selectedOption == 0
                            ? Colors.orange.shade700
                            : Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _selectedOption == 0
                      ? 'Menos puntos pero más control'
                      : 'Más puntos jugando contra cualquiera',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        _selectedOption == 0
                            ? Colors.orange.shade600
                            : Colors.green.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectChallengeForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Buscar Equipo Rival',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _teamSearchController,
          decoration: InputDecoration(
            labelText: 'Nombre o tag del equipo',
            hintText: 'ej: Los Tigres, #TIG001',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
            ),
          ),
          onChanged: (value) {
            // Búsqueda en tiempo real con debounce
            if (value.length >= 2) {
              Future.delayed(const Duration(milliseconds: 300), () {
                if (_teamSearchController.text == value) {
                  ref.read(teamSearchProvider.notifier).searchTeams(value);
                }
              });
            } else {
              ref.read(teamSearchProvider.notifier).clearResults();
            }
          },
        ),
        const SizedBox(height: 16),
        _buildTeamSearchResults(),
        const SizedBox(height: 24),
        _buildDateTimeSelectors(),
        const SizedBox(height: 24),
        _buildDescriptionField(),
      ],
    );
  }

  Widget _buildTeamSearchResults() {
    final searchResults = ref.watch(teamSearchProvider);

    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: searchResults.when(
        data: (teams) {
          if (teams.isEmpty && _teamSearchController.text.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'Busca un equipo rival',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          if (teams.isEmpty && _teamSearchController.text.isNotEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sports_soccer, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'No se encontraron equipos',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: teams.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final team = teams[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(
                    0xFF2E7D32,
                  ).withValues(alpha: 0.1),
                  child: Text(
                    team.tag ?? team.name.substring(0, 1),
                    style: const TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(team.name),
                subtitle:
                    team.tag != null
                        ? Text('TAG: ${team.tag}')
                        : Text(team.comuna.toUpperCase()),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  setState(() {
                    _selectedRival = team;
                    _teamSearchController.text = team.name;
                  });
                  ref.read(teamSearchProvider.notifier).clearResults();
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Text(
                    'Error al buscar equipos',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildPublicMatchForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Publicar Partido',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 16),

        // Selector de Comuna
        Consumer(
          builder: (context, ref, child) {
            final comunasAsync = ref.watch(availableComunasProvider);

            return comunasAsync.when(
              data:
                  (comunas) => DropdownButtonFormField<ComunaModel>(
                    value: _selectedComuna,
                    decoration: InputDecoration(
                      labelText: 'Comuna',
                      prefixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF2E7D32),
                          width: 2,
                        ),
                      ),
                    ),
                    items:
                        comunas.map((comunaName) {
                          final comuna = ComunaModel(
                            id: comunaName.hashCode.toString(),
                            name: comunaName,
                            regionId: '1',
                            createdAt: DateTime.now(),
                          );
                          return DropdownMenuItem<ComunaModel>(
                            value: comuna,
                            child: Text(comunaName),
                          );
                        }).toList(),
                    onChanged: (comuna) {
                      setState(() {
                        _selectedComuna = comuna;
                      });
                    },
                    validator:
                        (value) =>
                            value == null ? 'Selecciona una comuna' : null,
                  ),
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('Error cargando comunas: $error'),
            );
          },
        ),
        const SizedBox(height: 24),
        _buildDateTimeSelectors(),
        const SizedBox(height: 24),
        _buildDescriptionField(),
      ],
    );
  }

  Widget _buildDateTimeSelectors() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fecha',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Seleccionar fecha',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: _selectTime,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hora',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedTime != null
                        ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                        : 'Seleccionar hora',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Mensaje personalizado (opcional)',
        hintText:
            _selectedOption == 0
                ? 'Ej: ¿Listos para el partido? Nos vemos en la cancha.'
                : 'Ej: Partido amistoso nivel intermedio. Cancha sintética.',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child:
            _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                  _selectedOption == 0 ? 'Enviar Desafío' : 'Publicar Partido',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
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
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_selectedOption == 0) {
        // Validaciones para desafío directo
        if (_selectedRival == null) {
          throw Exception('Debes seleccionar un equipo rival');
        }
        await _createDirectChallenge();
      } else {
        // Validaciones para partido público
        if (_selectedComuna == null) {
          throw Exception('Debes seleccionar una comuna');
        }
        await _createPublicMatch();
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _selectedOption == 0
                  ? 'Desafío enviado correctamente'
                  : 'Partido publicado correctamente',
            ),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
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

  Future<void> _createDirectChallenge() async {
    final userTeam = await ref.read(currentUserTeamProvider.future);

    if (userTeam == null) {
      throw Exception('No tienes un equipo asignado');
    }

    if (_selectedDate == null || _selectedTime == null) {
      throw Exception('Debes seleccionar fecha y hora');
    }

    final matchDate = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final success = await ref
        .read(directMatchesProvider.notifier)
        .createDirectChallenge(
          homeTeamId: userTeam.id,
          awayTeamId: _selectedRival!.id,
          matchDate: matchDate,
          message:
              _descriptionController.text.isNotEmpty
                  ? _descriptionController.text
                  : null,
        );

    if (!success) {
      throw Exception('Error al crear el desafío');
    }
  }

  Future<void> _createPublicMatch() async {
    final userTeam = await ref.read(currentUserTeamProvider.future);

    if (userTeam == null) {
      throw Exception('No tienes un equipo asignado');
    }

    if (_selectedDate == null || _selectedTime == null) {
      throw Exception('Debes seleccionar fecha y hora');
    }

    final matchDate = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // Obtener estadísticas ELO para definir el rango
    final teamStats = await ref.read(teamEloStatsProvider(userTeam.id).future);
    final teamElo = teamStats['elo'] ?? 1200;

    final success = await ref
        .read(directMatchesProvider.notifier)
        .createPublicMatch(
          hostTeamId: userTeam.id,
          title: 'Partido vs ${userTeam.name}',
          description:
              _descriptionController.text.isNotEmpty
                  ? _descriptionController.text
                  : 'Partido amistoso nivel intermedio',
          matchDate: matchDate,
          comuna: _selectedComuna!.name,
          minEloRange: (teamElo - 200).clamp(800, 2000),
          maxEloRange: (teamElo + 200).clamp(800, 2000),
        );

    if (!success) {
      throw Exception('Error al publicar el partido');
    }
  }
}
