import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/supabase_config.dart';
import '../../data/teams_service.dart';
import '../../../../shared/ui/app_snack.dart';

// Modelos simples para esta pantalla (evitamos dependencias externas)
class _ComunaItem {
  final String id; // UUID
  final String name;
  final String code; // Ej: QUILIC
  const _ComunaItem({required this.id, required this.name, required this.code});
}

class _ModalityItem {
  final int id; // PK en DB
  final String name; // Fútbol 7, etc.
  final String code; // futbolito, futbol11, baby_futbol
  final String colorHex;
  const _ModalityItem({
    required this.id,
    required this.name,
    required this.code,
    required this.colorHex,
  });
}

final _activeComunasProvider = FutureProvider<List<_ComunaItem>>((ref) async {
  final supabase = ref.read(supabaseProvider);
  final rows = await supabase
      .from('comunas')
      .select('id,name,code')
      .eq('is_active', true)
      .order('name');
  return (rows as List)
      .map(
        (e) => _ComunaItem(
          id: (e['id'] ?? '').toString(),
          name: (e['name'] ?? '').toString(),
          code: (e['code'] ?? '').toString(),
        ),
      )
      .toList();
});

final _modalitiesProvider = FutureProvider<List<_ModalityItem>>((ref) async {
  final supabase = ref.read(supabaseProvider);
  final rows = await supabase
      .from('football_modalities')
      .select('id,name,code,color_hex')
      .order('id');
  return (rows as List)
      .map(
        (e) => _ModalityItem(
          id: e['id'] as int,
          name: (e['name'] ?? '').toString(),
          code: (e['code'] ?? '').toString(),
          colorHex: (e['color_hex'] ?? '#2E7D32').toString(),
        ),
      )
      .toList();
});

class CreateTeamPageNew extends ConsumerStatefulWidget {
  const CreateTeamPageNew({super.key});

  @override
  ConsumerState<CreateTeamPageNew> createState() => _CreateTeamPageNewState();
}

class _CreateTeamPageNewState extends ConsumerState<CreateTeamPageNew> {
  final _formKeyBasics = GlobalKey<FormState>();
  final _formKeyDetails = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _logoCtrl = TextEditingController();
  final _homeColorCtrl = TextEditingController(text: '#2E7D32');
  final _awayColorCtrl = TextEditingController(text: '#FFFFFF');

  int _currentStep = 0;
  bool _autoTag = true;
  bool _isSubmitting = false;

  // Selecciones
  String? _selectedComunaId; // UUID
  int? _selectedModalityId; // int

  @override
  void dispose() {
    _nameCtrl.dispose();
    _tagCtrl.dispose();
    _descCtrl.dispose();
    _logoCtrl.dispose();
    _homeColorCtrl.dispose();
    _awayColorCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Validación final de todos los pasos
    final basicsOk = _formKeyBasics.currentState?.validate() ?? false;
    final detailsOk = _formKeyDetails.currentState?.validate() ?? false;
    if (!basicsOk ||
        !detailsOk ||
        _selectedComunaId == null ||
        _selectedModalityId == null) {
      setState(() {
        _currentStep =
            !basicsOk
                ? 0
                : (_selectedComunaId == null || _selectedModalityId == null)
                ? 1
                : 2;
      });
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final client = ref.read(supabaseProvider);
      final user = client.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final teamsService = ref.read(teamsServiceProvider);
      await teamsService.createTeam(
        name: _nameCtrl.text.trim(),
        tag:
            _autoTag
                ? null
                : _tagCtrl.text.trim().isEmpty
                ? null
                : _tagCtrl.text.trim(),
        captainId: user.id,
        comunaId: _selectedComunaId,
        modalityId: _selectedModalityId,
        description:
            _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        logoUrl: _logoCtrl.text.trim().isEmpty ? null : _logoCtrl.text.trim(),
        homeColor: _homeColorCtrl.text.trim(),
        awayColor: _awayColorCtrl.text.trim(),
      );

      // Refrescar listas comunes
      ref.invalidate(userTeamsProvider);
      ref.invalidate(topTeamsProvider);

      if (!mounted) return;
      AppSnack.success(context, '¡Equipo creado exitosamente!');
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      AppSnack.error(context, 'Error al crear equipo: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final comunasAsync = ref.watch(_activeComunasProvider);
    final modalitiesAsync = ref.watch(_modalitiesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        title: Text(
          'Crear equipo',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: comunasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => _errorState('No se pudieron cargar las comunas: $e'),
        data: (comunas) {
          return modalitiesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (e, st) =>
                    _errorState('No se pudieron cargar las modalidades: $e'),
            data: (modalities) {
              // Prefijar selección por defecto
              _selectedComunaId ??=
                  comunas.isNotEmpty ? comunas.first.id : null;
              _selectedModalityId ??=
                  modalities.isNotEmpty ? modalities.first.id : null;

              return Stepper(
                currentStep: _currentStep,
                onStepContinue: () {
                  if (_currentStep == 0) {
                    if (_formKeyBasics.currentState?.validate() ?? false) {
                      setState(() => _currentStep = 1);
                    }
                  } else if (_currentStep == 1) {
                    if (_selectedComunaId != null &&
                        _selectedModalityId != null) {
                      setState(() => _currentStep = 2);
                    }
                  } else {
                    _submit();
                  }
                },
                onStepCancel: () {
                  if (_currentStep == 0) {
                    Navigator.of(context).maybePop();
                  } else {
                    setState(() => _currentStep -= 1);
                  }
                },
                controlsBuilder: (context, details) {
                  final isLast = _currentStep == 2;
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed:
                              _isSubmitting ? null : details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                          ),
                          child:
                              _isSubmitting
                                  ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : Text(isLast ? 'Crear equipo' : 'Siguiente'),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed:
                              _isSubmitting ? null : details.onStepCancel,
                          child: Text(_currentStep == 0 ? 'Cancelar' : 'Atrás'),
                        ),
                      ],
                    ),
                  );
                },
                steps: [
                  Step(
                    title: const Text('Básicos'),
                    isActive: _currentStep >= 0,
                    state:
                        _currentStep > 0
                            ? StepState.complete
                            : StepState.indexed,
                    content: _buildBasicsForm(),
                  ),
                  Step(
                    title: const Text('Comuna y modalidad'),
                    isActive: _currentStep >= 1,
                    state:
                        _currentStep > 1
                            ? StepState.complete
                            : StepState.indexed,
                    content: _buildLocationAndModality(comunas, modalities),
                  ),
                  Step(
                    title: const Text('Detalles'),
                    isActive: _currentStep >= 2,
                    state:
                        _currentStep == 2
                            ? StepState.editing
                            : StepState.indexed,
                    content: _buildDetailsForm(),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _errorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 32),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicsForm() {
    return Form(
      key: _formKeyBasics,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nameCtrl,
            decoration: _inputDecoration(
              'Nombre del equipo',
              icon: Icons.sports_soccer,
            ),
            validator: (v) {
              final t = v?.trim() ?? '';
              if (t.isEmpty) return 'Ingresa un nombre';
              if (t.length < 3) return 'Mínimo 3 caracteres';
              if (t.length > 30) return 'Máximo 30 caracteres';
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Switch(
                value: _autoTag,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (v) => setState(() => _autoTag = v),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Generar tag automáticamente',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _tagCtrl,
            enabled: !_autoTag,
            decoration: _inputDecoration(
              'Tag del equipo (opcional si se genera)',
              icon: Icons.tag,
            ).copyWith(
              prefixText: '#',
              prefixStyle: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            validator: (v) {
              if (_autoTag) return null;
              final t = v?.trim() ?? '';
              if (t.isEmpty) {
                return 'Ingresa un tag o activa generación automática';
              }
              if (t.length < 3) return 'Mínimo 3 caracteres';
              if (t.length > 20) return 'Máximo 20 caracteres';
              if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(t)) {
                return 'Usa solo letras, números, _ y -';
              }
              return null;
            },
            onChanged: (value) {
              final clean = value.toLowerCase().replaceAll(' ', '');
              if (clean != value) {
                _tagCtrl.value = _tagCtrl.value.copyWith(
                  text: clean,
                  selection: TextSelection.collapsed(offset: clean.length),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocationAndModality(
    List<_ComunaItem> comunas,
    List<_ModalityItem> modalities,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comuna',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedComunaId,
          items:
              comunas
                  .map(
                    (c) => DropdownMenuItem<String>(
                      value: c.id,
                      child: Text(c.name),
                    ),
                  )
                  .toList(),
          onChanged: (v) => setState(() => _selectedComunaId = v),
          decoration: _inputDecoration(
            'Selecciona tu comuna',
            icon: Icons.location_on,
          ),
          validator: (v) => v == null ? 'Selecciona una comuna' : null,
        ),
        const SizedBox(height: 16),
        Text(
          'Modalidad',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _selectedModalityId,
          items:
              modalities
                  .map(
                    (m) =>
                        DropdownMenuItem<int>(value: m.id, child: Text(m.name)),
                  )
                  .toList(),
          onChanged: (v) => setState(() => _selectedModalityId = v),
          decoration: _inputDecoration(
            'Selecciona modalidad',
            icon: Icons.sports,
          ),
          validator: (v) => v == null ? 'Selecciona una modalidad' : null,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'La comuna define dónde compites y cómo puntúas en el ranking local.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsForm() {
    return Form(
      key: _formKeyDetails,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _logoCtrl,
            decoration: _inputDecoration(
              'Logo (URL opcional)',
              icon: Icons.image,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descCtrl,
            maxLines: 3,
            decoration: _inputDecoration(
              'Descripción (opcional)',
              icon: Icons.description,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _homeColorCtrl,
                  decoration: _inputDecoration(
                    'Color local (hex)',
                    icon: Icons.palette,
                  ),
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.isEmpty) return 'Requerido';
                    final value = t.startsWith('#') ? t : '#$t';
                    if (!RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(value)) {
                      return 'Formato #RRGGBB';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _awayColorCtrl,
                  decoration: _inputDecoration(
                    'Color visita (hex)',
                    icon: Icons.palette_outlined,
                  ),
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.isEmpty) return 'Requerido';
                    final value = t.startsWith('#') ? t : '#$t';
                    if (!RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(value)) {
                      return 'Formato #RRGGBB';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Puedes cambiar colores y logo después desde los ajustes del equipo.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon:
          icon != null
              ? Icon(icon, color: Theme.of(context).colorScheme.primary)
              : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
    );
  }
}
