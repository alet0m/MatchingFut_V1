import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../../../auth/data/auth_service.dart';

class CompleteEditProfilePage extends ConsumerStatefulWidget {
  final Map<String, dynamic> userProfile;
  const CompleteEditProfilePage({super.key, required this.userProfile});

  @override
  ConsumerState<CompleteEditProfilePage> createState() =>
      _CompleteEditProfilePageState();
}

class _CompleteEditProfilePageState
    extends ConsumerState<CompleteEditProfilePage> {
  // Controladores de texto
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  // Variables de estado del onboarding
  int _selectedHeight = 170;
  int _selectedWeight = 70;
  String _selectedFoot = 'Derecho';
  final List<String> _selectedGoals = [];
  String? _selectedNacionalidad;
  String? _selectedGenero;
  String? _selectedComuna;
  int _selectedExperience = 0;
  String _selectedPosition = 'Mediocampo';
  String _selectedLevel = 'Intermedio';
  String _selectedGameType = 'Fútbol 7';
  final List<String> _selectedDays = [];
  TimeOfDay _selectedTime = const TimeOfDay(hour: 20, minute: 0);

  bool _canEdit = false;
  int _daysUntilEdit = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
    _checkEditPermission();
  }

  void _loadCurrentData() {
    // Cargar datos actuales del perfil
    _nicknameController.text = widget.userProfile['display_name'] ?? '';

    // Extraer edad de date_of_birth si existe
    if (widget.userProfile['date_of_birth'] != null) {
      try {
        final birthDate = DateTime.parse(widget.userProfile['date_of_birth']);
        final age = DateTime.now().year - birthDate.year;
        _ageController.text = age.toString();
      } catch (_) {}
    }

    // Las posiciones ahora se guardan en español, verificar que existe en la nueva lista
    final allPositions = [
      'Portero',
      'Defensa Central',
      'Lateral Derecho',
      'Lateral Izquierdo',
      'Líbero',
      'Defensa',
      'Mediocampo Defensivo',
      'Mediocampo Central',
      'Mediocampo Ofensivo',
      'Mediocampo por Derecha',
      'Mediocampo por Izquierda',
      'Volante Mixto',
      'Mediocampo',
      'Extremo Derecho',
      'Extremo Izquierdo',
      'Media Punta',
      'Segundo Delantero',
      'Delantero Centro',
      'Delantero',
      'Polivalente',
    ];
    final currentPosition = widget.userProfile['position'] ?? 'Mediocampo';
    _selectedPosition =
        allPositions.contains(currentPosition)
            ? currentPosition
            : 'Mediocampo Central';
    // Convertir pie hábil de inglés a español si es necesario
    _selectedFoot = _convertFootToSpanish(
      widget.userProfile['preferred_foot'] ?? 'Derecho',
    );
    // Convertir nivel de inglés a español si es necesario
    _selectedLevel = _convertLevelToSpanish(
      widget.userProfile['skill_level'] ?? 'Intermedio',
    );
    _selectedComuna = widget.userProfile['comuna'];

    // Extraer datos del bio JSON
    if (widget.userProfile['bio'] != null) {
      try {
        final bioData =
            widget.userProfile['bio'] is String
                ? json.decode(widget.userProfile['bio'])
                : widget.userProfile['bio'];

        _selectedNacionalidad = bioData['nacionalidad'];
        _selectedGenero = bioData['genero'];
        _selectedHeight = bioData['altura'] ?? 170;
        _selectedWeight = bioData['peso'] ?? 70;
        _selectedExperience = bioData['experiencia'] ?? 0;
        _selectedGameType = bioData['tipo_juego'] ?? 'Fútbol 7';

        if (bioData['objetivos'] != null) {
          _selectedGoals.clear();
          _selectedGoals.addAll(List<String>.from(bioData['objetivos']));
        }

        if (bioData['dias_disponibles'] != null) {
          _selectedDays.clear();
          _selectedDays.addAll(List<String>.from(bioData['dias_disponibles']));
        }

        if (bioData['horario_preferido'] != null) {
          final timeParts = bioData['horario_preferido'].toString().split(':');
          if (timeParts.length == 2) {
            _selectedTime = TimeOfDay(
              hour: int.tryParse(timeParts[0]) ?? 20,
              minute: int.tryParse(timeParts[1]) ?? 0,
            );
          }
        }
      } catch (e) {
        print('Error parsing bio data: $e');
      }
    }
  }

  Future<void> _checkEditPermission() async {
    try {
      final supabase = ref.read(supabaseClientProvider);
      final currentUser = ref.read(currentUserProvider);

      if (currentUser != null) {
        // Verificar si puede editar
        final canEditResult = await supabase.rpc(
          'can_edit_profile',
          params: {'user_id': currentUser.id},
        );

        // Obtener días restantes
        final daysResult = await supabase.rpc(
          'days_until_next_edit',
          params: {'user_id': currentUser.id},
        );

        setState(() {
          _canEdit = canEditResult == true;
          _daysUntilEdit = daysResult ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error checking edit permission: $e');
      setState(() {
        _canEdit = true; // En caso de error, permitir editar
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Editar Perfil'),
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!_canEdit) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Editar Perfil'),
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.schedule, size: 80, color: Colors.orange[600]),
                const SizedBox(height: 20),
                Text(
                  'Solo puedes editar tu perfil completo una vez al mes',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Días restantes: $_daysUntilEdit',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.orange[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Entendido'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Editar Perfil Completo'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWarningCard(),
            const SizedBox(height: 20),
            _buildDatosPersonalesSection(),
            const SizedBox(height: 20),
            _buildComunaGeneroSection(),
            const SizedBox(height: 20),
            _buildCaracteristicasFisicasSection(),
            const SizedBox(height: 20),
            _buildExperienciaSection(),
            const SizedBox(height: 20),
            _buildObjetivosSection(),
            const SizedBox(height: 30),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        border: Border.all(color: Colors.orange[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edición limitada',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
                Text(
                  'Solo puedes editar tu perfil completo una vez cada 30 días.',
                  style: TextStyle(color: Colors.orange[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatosPersonalesSection() {
    return _buildSection(
      title: 'Datos Personales',
      children: [
        TextField(
          controller: _nicknameController,
          decoration: const InputDecoration(
            labelText: 'Apodo',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _ageController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Edad',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.cake),
          ),
        ),
      ],
    );
  }

  Widget _buildComunaGeneroSection() {
    return _buildSection(
      title: 'Ubicación y Datos Personales',
      children: [
        DropdownButtonFormField<String>(
          value: _selectedComuna,
          decoration: const InputDecoration(
            labelText: 'Comuna',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on),
          ),
          items:
              [
                    'Quilicura',
                    'Huechuraba',
                    'Renca',
                    'Conchalí',
                    'Independencia',
                    'Otra',
                  ]
                  .map(
                    (comuna) =>
                        DropdownMenuItem(value: comuna, child: Text(comuna)),
                  )
                  .toList(),
          onChanged: (value) => setState(() => _selectedComuna = value),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedGenero,
          decoration: const InputDecoration(
            labelText: 'Género',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_outline),
          ),
          items:
              ['Masculino', 'Femenino', 'Otro']
                  .map(
                    (genero) =>
                        DropdownMenuItem(value: genero, child: Text(genero)),
                  )
                  .toList(),
          onChanged: (value) => setState(() => _selectedGenero = value),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedNacionalidad,
          decoration: const InputDecoration(
            labelText: 'Nacionalidad',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.flag),
          ),
          items:
              [
                    'Chilena',
                    'Argentina',
                    'Peruana',
                    'Colombiana',
                    'Venezolana',
                    'Otra',
                  ]
                  .map((nac) => DropdownMenuItem(value: nac, child: Text(nac)))
                  .toList(),
          onChanged: (value) => setState(() => _selectedNacionalidad = value),
        ),
      ],
    );
  }

  Widget _buildCaracteristicasFisicasSection() {
    return _buildSection(
      title: 'Características Físicas',
      children: [
        Text(
          'Altura: $_selectedHeight cm',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Slider(
          value: _selectedHeight.toDouble(),
          min: 150,
          max: 200,
          divisions: 50,
          activeColor: const Color(0xFF2E7D32),
          onChanged: (value) => setState(() => _selectedHeight = value.round()),
        ),
        const SizedBox(height: 16),
        Text(
          'Peso: $_selectedWeight kg',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Slider(
          value: _selectedWeight.toDouble(),
          min: 50,
          max: 120,
          divisions: 70,
          activeColor: const Color(0xFF2E7D32),
          onChanged: (value) => setState(() => _selectedWeight = value.round()),
        ),
        const SizedBox(height: 16),
        const Text(
          'Pie hábil:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children:
              ['Derecho', 'Izquierdo', 'Ambos']
                  .map(
                    (foot) => ChoiceChip(
                      label: Text(foot),
                      selected: _selectedFoot == foot,
                      onSelected:
                          (selected) => setState(
                            () => _selectedFoot = selected ? foot : '',
                          ),
                      selectedColor: const Color(0xFF2E7D32),
                      labelStyle: TextStyle(
                        color:
                            _selectedFoot == foot
                                ? Colors.white
                                : Colors.black54,
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildExperienciaSection() {
    return _buildSection(
      title: 'Experiencia y Preferencias',
      children: [
        Text(
          'Años jugando: $_selectedExperience',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Slider(
          value: _selectedExperience.toDouble(),
          min: 0,
          max: 30,
          divisions: 30,
          label: '$_selectedExperience',
          activeColor: const Color(0xFF2E7D32),
          onChanged:
              (value) => setState(() => _selectedExperience = value.round()),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedPosition,
          decoration: const InputDecoration(
            labelText: 'Posición preferida',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.sports_soccer),
          ),
          items:
              [
                    // Portero
                    'Portero',
                    // Defensas
                    'Defensa Central',
                    'Lateral Derecho',
                    'Lateral Izquierdo',
                    'Líbero',
                    'Defensa',
                    // Mediocampo
                    'Mediocampo Defensivo',
                    'Mediocampo Central',
                    'Mediocampo Ofensivo',
                    'Mediocampo por Derecha',
                    'Mediocampo por Izquierda',
                    'Volante Mixto',
                    'Mediocampo',
                    // Delanteros
                    'Extremo Derecho',
                    'Extremo Izquierdo',
                    'Media Punta',
                    'Segundo Delantero',
                    'Delantero Centro',
                    'Delantero',
                    // Posiciones versátiles
                    'Polivalente',
                  ]
                  .map((pos) => DropdownMenuItem(value: pos, child: Text(pos)))
                  .toList(),
          onChanged:
              (value) => setState(
                () => _selectedPosition = value ?? 'Mediocampo Central',
              ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedLevel,
          decoration: const InputDecoration(
            labelText: 'Nivel de habilidad',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.star),
          ),
          items:
              ['Principiante', 'Intermedio', 'Avanzado']
                  .map((lvl) => DropdownMenuItem(value: lvl, child: Text(lvl)))
                  .toList(),
          onChanged:
              (value) => setState(() => _selectedLevel = value ?? 'Intermedio'),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedGameType,
          decoration: const InputDecoration(
            labelText: 'Tipo de juego',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.sports),
          ),
          items:
              ['Fútbol 5', 'Fútbol 7', 'Fútbol 11']
                  .map(
                    (tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)),
                  )
                  .toList(),
          onChanged:
              (value) =>
                  setState(() => _selectedGameType = value ?? 'Fútbol 7'),
        ),
        const SizedBox(height: 16),
        const Text(
          'Días disponibles:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children:
              [
                    'Lunes',
                    'Martes',
                    'Miércoles',
                    'Jueves',
                    'Viernes',
                    'Sábado',
                    'Domingo',
                  ]
                  .map(
                    (dia) => FilterChip(
                      label: Text(dia),
                      selected: _selectedDays.contains(dia),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedDays.add(dia);
                          } else {
                            _selectedDays.remove(dia);
                          }
                        });
                      },
                      selectedColor: const Color(0xFF2E7D32),
                      labelStyle: TextStyle(
                        color:
                            _selectedDays.contains(dia)
                                ? Colors.white
                                : Colors.black54,
                      ),
                    ),
                  )
                  .toList(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text(
              'Horario preferido:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (picked != null) setState(() => _selectedTime = picked);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
              ),
              child: Text(_selectedTime.format(context)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildObjetivosSection() {
    return _buildSection(
      title: 'Objetivos en la App',
      children: [
        const Text(
          'Selecciona tus objetivos:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        ...[
          'Competir y ganar',
          'Diversión y relajación',
          'Hacer nuevos amigos',
          'Mejorar mi técnica',
          'Dominar territorios',
          'Subir en el ranking',
        ].map(
          (goal) => CheckboxListTile(
            title: Text(goal),
            value: _selectedGoals.contains(goal),
            onChanged: (selected) {
              setState(() {
                if (selected == true) {
                  _selectedGoals.add(goal);
                } else {
                  _selectedGoals.remove(goal);
                }
              });
            },
            activeColor: const Color(0xFF2E7D32),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon:
            _isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : const Icon(Icons.save),
        label: Text(_isLoading ? 'Guardando...' : 'Guardar Cambios Completos'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onPressed: _isLoading ? null : _saveCompleteProfile,
      ),
    );
  }

  String _mapPosition(String position) {
    // Mantener las posiciones en español en la base de datos
    return position.isNotEmpty ? position : 'Mediocampo Central';
  }

  String _convertFootToSpanish(String foot) {
    // En este caso, probablemente ya esté en español, pero por seguridad
    switch (foot) {
      case 'right':
        return 'Derecho';
      case 'left':
        return 'Izquierdo';
      case 'both':
        return 'Ambos';
      default:
        return foot.isNotEmpty
            ? foot
            : 'Derecho'; // Mantener el valor si ya está en español
    }
  }

  String _convertLevelToSpanish(String level) {
    // Similar para el nivel
    switch (level) {
      case 'beginner':
        return 'Principiante';
      case 'intermediate':
        return 'Intermedio';
      case 'advanced':
        return 'Avanzado';
      default:
        return level.isNotEmpty
            ? level
            : 'Intermedio'; // Mantener el valor si ya está en español
    }
  }

  Future<void> _saveCompleteProfile() async {
    // Evitar múltiples llamadas
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = ref.read(supabaseClientProvider);
      final currentUser = ref.read(currentUserProvider);

      if (currentUser == null) {
        _showError('Usuario no autenticado');
        return;
      }

      // Construir bio como JSON con todos los datos
      final bioJson = {
        'nacionalidad': _selectedNacionalidad,
        'genero': _selectedGenero,
        'objetivos': _selectedGoals.toSet().toList(),
        'dias_disponibles': _selectedDays.toSet().toList(),
        'horario_preferido':
            '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
        'tipo_juego': _selectedGameType,
        'experiencia': _selectedExperience,
        'altura': _selectedHeight,
        'peso': _selectedWeight,
      };

      // Preparar datos de actualización
      final updateData = {
        'display_name': _nicknameController.text.trim(),
        'full_name': _nicknameController.text.trim(),
        'first_name': _nicknameController.text.trim().split(' ').first,
        'last_name':
            _nicknameController.text.trim().split(' ').length > 1
                ? _nicknameController.text.trim().split(' ').last
                : '',
        'bio': json.encode(bioJson),
        'position': _mapPosition(_selectedPosition),
        'preferred_foot': _selectedFoot,
        'comuna': _selectedComuna,
        'skill_level': _selectedLevel,
        'updated_at': DateTime.now().toIso8601String(),
        'last_profile_edit':
            DateTime.now().toIso8601String(), // ✅ Marcar última edición
        'is_active': true,
      };

      // Agregar date_of_birth solo si no está vacío
      if (_ageController.text.isNotEmpty) {
        updateData['date_of_birth'] =
            DateTime(
              DateTime.now().year - int.parse(_ageController.text),
              1,
              1,
            ).toIso8601String();
      }

      await supabase
          .from('profiles')
          .update(updateData)
          .eq('id', currentUser.id);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSuccess();
      }
    } catch (e) {
      print('Error saving profile: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showError('Error al guardar el perfil: ${e.toString()}');
      }
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            icon: const Icon(
              Icons.check_circle,
              color: Color(0xFF2E7D32),
              size: 60,
            ),
            title: const Text('¡Perfil Actualizado!'),
            content: const Text(
              'Tu perfil se ha actualizado correctamente.\nPodrás editarlo nuevamente en 30 días.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  // Solo cerrar diálogo, no navegar hacia atrás
                  Navigator.of(context).pop();
                  // El usuario puede usar el botón de atrás si desea volver
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                ),
                child: const Text(
                  'Entendido',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _ageController.dispose();
    super.dispose();
  }
}
