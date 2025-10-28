import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../teams/data/teams_service.dart';
import '../../providers/matches_providers.dart';
import '../../../../shared/models/team_model.dart';
import '../../../../shared/widgets/loading_widget.dart';

class CreateMatchPageEnhanced extends ConsumerStatefulWidget {
  final String? teamId;

  const CreateMatchPageEnhanced({super.key, this.teamId});

  @override
  ConsumerState<CreateMatchPageEnhanced> createState() =>
      _CreateMatchPageEnhancedState();
}

class _CreateMatchPageEnhancedState
    extends ConsumerState<CreateMatchPageEnhanced> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  TeamModel? _selectedTeam;
  TeamModel? _opponentTeam;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _matchType = 'futbolito';
  bool _isPublicMatch = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserTeams();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadUserTeams() async {
    try {
      final userTeamsAsync = ref.read(userTeamsProvider);
      final userTeams = userTeamsAsync.when(
        data: (teams) => teams,
        loading: () => <TeamModel>[],
        error: (_, __) => <TeamModel>[],
      );

      if (userTeams.isNotEmpty) {
        setState(() {
          _selectedTeam =
              widget.teamId != null
                  ? userTeams.firstWhere(
                    (team) => team.id == widget.teamId,
                    orElse: () => userTeams.first,
                  )
                  : userTeams.first;
        });
      }
    } catch (e) {
      print('Error cargando equipos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Crear Partido',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMatchTypeSelector(),
                    const SizedBox(height: 20),
                    _buildTeamSelector(),
                    const SizedBox(height: 20),
                    _buildMatchTypeCard(),
                    const SizedBox(height: 20),
                    _buildDateTimeSelector(),
                    const SizedBox(height: 20),
                    _buildLocationInput(),
                    const SizedBox(height: 20),
                    if (!_isPublicMatch) _buildOpponentSelector(),
                    if (!_isPublicMatch) const SizedBox(height: 20),
                    _buildDescriptionInput(),
                    const SizedBox(
                      height: 80,
                    ), // Espacio para el botón flotante
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildCreateButton(),
    );
  }

  Widget _buildMatchTypeSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tipo de Partido',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Público'),
                    subtitle: const Text('Cualquier equipo puede unirse'),
                    value: true,
                    groupValue: _isPublicMatch,
                    onChanged:
                        (value) => setState(() => _isPublicMatch = value!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Privado'),
                    subtitle: const Text('Invitar a un equipo específico'),
                    value: false,
                    groupValue: _isPublicMatch,
                    onChanged:
                        (value) => setState(() => _isPublicMatch = value!),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSelector() {
    final userTeamsAsync = ref.watch(userTeamsProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mi Equipo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            userTeamsAsync.when(
              data: (teams) {
                if (teams.isEmpty) {
                  return const Text(
                    'No tienes equipos. Crea o únete a un equipo primero.',
                    style: TextStyle(color: Colors.grey),
                  );
                }

                return DropdownButtonFormField<TeamModel>(
                  value: _selectedTeam,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.sports_soccer),
                  ),
                  items:
                      teams.map((team) {
                        return DropdownMenuItem(
                          value: team,
                          child: Text(team.name),
                        );
                      }).toList(),
                  onChanged: (team) => setState(() => _selectedTeam = team),
                  validator:
                      (value) => value == null ? 'Selecciona un equipo' : null,
                );
              },
              loading: () => const LoadingWidget(),
              error: (error, stackTrace) => Text('Error: $error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchTypeCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Modalidad',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildModalityCard(
                    'futbolito',
                    'Futbolito',
                    '6 vs 6',
                    '60 min',
                    Icons.sports_soccer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildModalityCard(
                    'futbol',
                    'Fútbol 11',
                    '11 vs 11',
                    '90 min',
                    Icons.stadium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalityCard(
    String value,
    String title,
    String players,
    String duration,
    IconData icon,
  ) {
    final isSelected = _matchType == value;

    return GestureDetector(
      onTap: () => setState(() => _matchType = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFF2E7D32).withOpacity(0.1)
                  : Colors.grey[100],
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF2E7D32) : Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[700],
              ),
            ),
            Text(
              players,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              duration,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fecha y Hora',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      _selectedDate == null
                          ? 'Seleccionar fecha'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    ),
                    onTap: _selectDate,
                  ),
                ),
                Expanded(
                  child: ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(
                      _selectedTime == null
                          ? 'Seleccionar hora'
                          : _selectedTime!.format(context),
                    ),
                    onTap: _selectTime,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInput() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lugar del Partido',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'Ej: Estadio Municipal de Quilicura',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.location_on),
              ),
              validator:
                  (value) =>
                      value?.trim().isEmpty == true
                          ? 'Ingresa la ubicación'
                          : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpponentSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Equipo Oponente',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Buscar equipo oponente...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () {
                    // TODO: Implementar escáner QR para equipos
                  },
                ),
              ),
              onTap: () {
                // TODO: Implementar búsqueda de equipos
                _showTeamSearchDialog();
              },
              readOnly: true,
            ),
            if (_opponentTeam != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border.all(color: Colors.green[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Oponente: ${_opponentTeam!.name}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _opponentTeam = null),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionInput() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Descripción (Opcional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Información adicional sobre el partido...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return FloatingActionButton.extended(
      onPressed: _isLoading ? null : _createMatch,
      backgroundColor: const Color(0xFF2E7D32),
      icon:
          _isLoading
              ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
              : const Icon(Icons.add),
      label: Text(_isLoading ? 'Creando...' : 'Crear Partido'),
    );
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _showTeamSearchDialog() async {
    // TODO: Implementar diálogo de búsqueda de equipos
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Buscar Equipo'),
            content: const Text('Funcionalidad de búsqueda en desarrollo...'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  Future<void> _createMatch() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedTeam == null) {
      _showErrorSnackBar('Selecciona un equipo');
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      _showErrorSnackBar('Selecciona fecha y hora');
      return;
    }

    if (!_isPublicMatch && _opponentTeam == null) {
      _showErrorSnackBar(
        'Selecciona un equipo oponente para partidos privados',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final scheduledDate = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final matchesService = ref.read(matchesServiceProvider);
      await (_isPublicMatch
          ? matchesService.createPublicMatch(
            hostTeamId: _selectedTeam!.id,
            scheduledDate: scheduledDate,
            location: _locationController.text.trim(),
            matchType: _matchType,
            description:
                _descriptionController.text.trim().isEmpty
                    ? null
                    : _descriptionController.text.trim(),
          )
          : matchesService.createPrivateMatch(
            hostTeamId: _selectedTeam!.id,
            guestTeamId: _opponentTeam!.id,
            scheduledDate: scheduledDate,
            location: _locationController.text.trim(),
            matchType: _matchType,
            description:
                _descriptionController.text.trim().isEmpty
                    ? null
                    : _descriptionController.text.trim(),
          ));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isPublicMatch
                  ? 'Partido público creado exitosamente'
                  : 'Invitación enviada al equipo oponente',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/matches');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error al crear el partido: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
