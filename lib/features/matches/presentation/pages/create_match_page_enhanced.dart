import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../teams/data/teams_service.dart';
import '../../providers/matches_providers.dart';
import '../../../../shared/models/team_model.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/ui/app_snack.dart';

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Crear Partido',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
                    _buildMatchVisibilitySelector(),
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

  Widget _buildMatchVisibilitySelector() {
    final isNarrow = MediaQuery.of(context).size.width < 420;
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
            if (!isNarrow)
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Público'),
                      subtitle: const Text('Cualquier equipo puede unirse'),
                      value: true,
                      groupValue: _isPublicMatch,
                      onChanged:
                          (value) =>
                              setState(() => _isPublicMatch = value ?? true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Privado'),
                      subtitle: const Text('Invitar a un equipo específico'),
                      value: false,
                      groupValue: _isPublicMatch,
                      onChanged:
                          (value) =>
                              setState(() => _isPublicMatch = value ?? false),
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  RadioListTile<bool>(
                    title: const Text('Público'),
                    subtitle: const Text('Cualquier equipo puede unirse'),
                    value: true,
                    groupValue: _isPublicMatch,
                    onChanged:
                        (value) =>
                            setState(() => _isPublicMatch = value ?? true),
                  ),
                  const Divider(height: 0),
                  RadioListTile<bool>(
                    title: const Text('Privado'),
                    subtitle: const Text('Invitar a un equipo específico'),
                    value: false,
                    groupValue: _isPublicMatch,
                    onChanged:
                        (value) =>
                            setState(() => _isPublicMatch = value ?? false),
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
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => setState(() => _matchType = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? scheme.primary.withValues(alpha: 0.08)
                  : Theme.of(context).colorScheme.surface,
          border: Border.all(
            color:
                isSelected
                    ? scheme.primary
                    : Theme.of(context).colorScheme.outlineVariant,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? scheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color:
                    isSelected
                        ? scheme.primary
                        : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              players,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              duration,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSelector() {
    final isNarrow = MediaQuery.of(context).size.width < 420;
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
            if (!isNarrow)
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
              )
            else
              Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      _selectedDate == null
                          ? 'Seleccionar fecha'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    ),
                    onTap: _selectDate,
                  ),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(
                      _selectedTime == null
                          ? 'Seleccionar hora'
                          : _selectedTime!.format(context),
                    ),
                    onTap: _selectTime,
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
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.08),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
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
    final scheme = Theme.of(context).colorScheme;
    return FloatingActionButton.extended(
      onPressed: _isLoading ? null : _createMatch,
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      icon:
          _isLoading
              ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: scheme.onPrimary,
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
        final msg =
            _isPublicMatch
                ? 'Partido público creado exitosamente'
                : 'Invitación enviada al equipo oponente';
        AppSnack.success(context, msg);
        context.go('/matches');
      }
    } catch (e) {
      if (mounted) AppSnack.error(context, 'Error al crear el partido: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    AppSnack.error(context, message);
  }
}
