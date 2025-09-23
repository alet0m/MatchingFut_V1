// ignore_for_file: unused_element, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../auth/data/auth_service.dart';
import '../../data/onboarding_provider.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: Semantics(
              label: 'Barra de progreso de onboarding',
              child: Container(
                height: 8,
                margin: EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color:
                      isActive
                          ? Color(0xFFFF6F00)
                          : Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow:
                      isActive
                          ? [
                            BoxShadow(
                              color: Color(0xFFFF6F00).withOpacity(0.3),
                              blurRadius: 4,
                            ),
                          ]
                          : [],
                ),
              ).animate(target: isActive ? 1 : 0).fade(duration: 400.ms),
            ),
          );
        }),
      ),
    );
  }

  // Variables de estado necesarias para el flujo de onboarding
  int _selectedHeight = 170;
  int _selectedWeight = 70;
  String _selectedFoot = 'Derecho';
  final List<String> _selectedGoals = [];
  int _currentStep = 0;
  final int _totalSteps = 5;
  String? _selectedNacionalidad;
  String? _selectedGenero;
  String? _selectedComuna;
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  int _selectedExperience = 0;
  String _selectedPosition = 'Mediocampo Central';
  String _selectedLevel = 'Intermedio';
  String _selectedGameType = 'Fútbol 7';
  final List<String> _selectedDays = [];
  TimeOfDay _selectedTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  Widget build(BuildContext context) {
    final List<Widget> steps = [
      _buildDatosPersonalesStep(),
      _buildComunaGeneroNacionalidadStep(),
      _buildCaracteristicasFisicasStep(),
      _buildExperienciaStep(),
      _buildObjetivosStep(),
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              _buildProgressBar(),
              Expanded(
                child: AnimatedSwitcher(
                  duration: 500.ms,
                  transitionBuilder:
                      (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                  child: steps[_currentStep],
                ),
              ),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatosPersonalesStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Datos personales',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              semanticsLabel: 'Título: Datos personales',
            ).animate().fadeIn(duration: 800.ms),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _nicknameController,
                    decoration: const InputDecoration(
                      labelText: 'Apodo',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Edad',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComunaGeneroNacionalidadStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comuna, Género y Nacionalidad',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate().fadeIn(duration: 800.ms),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedComuna,
                    decoration: const InputDecoration(
                      labelText: 'Comuna',
                      border: OutlineInputBorder(),
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
                              (comuna) => DropdownMenuItem(
                                value: comuna,
                                child: Text(comuna),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedComuna = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedGenero,
                    decoration: const InputDecoration(
                      labelText: 'Género',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        ['Masculino', 'Femenino', 'Otro']
                            .map(
                              (genero) => DropdownMenuItem(
                                value: genero,
                                child: Text(genero),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGenero = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedNacionalidad,
                    decoration: const InputDecoration(
                      labelText: 'Nacionalidad',
                      border: OutlineInputBorder(),
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
                            .map(
                              (nac) => DropdownMenuItem(
                                value: nac,
                                child: Text(nac),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedNacionalidad = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienciaStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Experiencia y Preferencias',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate().fadeIn(duration: 800.ms),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    'Años jugando:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Slider(
                    value: _selectedExperience.toDouble(),
                    min: 0,
                    max: 30,
                    divisions: 30,
                    label: '$_selectedExperience',
                    activeColor: const Color(0xFF2E7D32),
                    onChanged: (value) {
                      setState(() {
                        _selectedExperience = value.round();
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedPosition,
                    decoration: const InputDecoration(
                      labelText: 'Posición preferida',
                      border: OutlineInputBorder(),
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
                            .map(
                              (pos) => DropdownMenuItem(
                                value: pos,
                                child: Text(pos),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPosition = value ?? 'Mediocampo Central';
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedLevel,
                    decoration: const InputDecoration(
                      labelText: 'Nivel de habilidad',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        ['Principiante', 'Intermedio', 'Avanzado']
                            .map(
                              (lvl) => DropdownMenuItem(
                                value: lvl,
                                child: Text(lvl),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLevel = value ?? 'Intermedio';
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedGameType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de juego',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        ['Fútbol 5', 'Fútbol 7', 'Fútbol 11']
                            .map(
                              (tipo) => DropdownMenuItem(
                                value: tipo,
                                child: Text(tipo),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGameType = value ?? 'Fútbol 7';
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Días disponibles:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
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
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text(
                        'Horario preferido:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime,
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedTime = picked;
                            });
                          }
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _mapPosition(String position) {
    // Mantener las posiciones en español en la base de datos
    return position.isNotEmpty ? position : 'Mediocampo Central';
  }

  String _mapFoot(String foot) => foot;
  String _mapSkillLevel(String level) => level;
  String _mapGameType(String type) => type;

  Widget _buildCaracteristicasFisicasStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Características Físicas',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate().fadeIn(duration: 800.ms),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    'Altura: $_selectedHeight cm',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Slider(
                    value: _selectedHeight.toDouble(),
                    min: 150,
                    max: 200,
                    divisions: 50,
                    activeColor: const Color(0xFF2E7D32),
                    onChanged: (value) {
                      setState(() {
                        _selectedHeight = value.round();
                      });
                    },
                  ).animate().fadeIn(duration: 800.ms, delay: 400.ms),
                  const SizedBox(height: 20),
                  Text(
                    'Peso: $_selectedWeight kg',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Slider(
                    value: _selectedWeight.toDouble(),
                    min: 50,
                    max: 120,
                    divisions: 70,
                    activeColor: const Color(0xFF2E7D32),
                    onChanged: (value) {
                      setState(() {
                        _selectedWeight = value.round();
                      });
                    },
                  ).animate().fadeIn(duration: 800.ms, delay: 600.ms),
                  const SizedBox(height: 30),
                  const Text(
                    'Pie hábil:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children:
                        ['Derecho', 'Izquierdo', 'Ambos']
                            .map(
                              (foot) => ChoiceChip(
                                label: Text(foot),
                                selected: _selectedFoot == foot,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedFoot = selected ? foot : '';
                                  });
                                },
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
                  ).animate().fadeIn(duration: 800.ms, delay: 800.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameTypeCard({
    required String title,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
    required String description,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: selected ? color : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObjetivosStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¡Casi listo!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate().fadeIn(duration: 800.ms),
            const Text(
              '¿Qué buscas en la app?',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ).animate().fadeIn(duration: 800.ms, delay: 200.ms),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    'Selecciona tus objetivos (puedes elegir varios):',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ).animate().fadeIn(duration: 800.ms, delay: 400.ms),
                  const SizedBox(height: 20),
                  Column(
                    children: [
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
                            if (selected == true) {
                              _selectedGoals.add(goal);
                            } else {
                              _selectedGoals.remove(goal);
                            }
                            if (mounted) setState(() {});
                          },
                          activeColor: const Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 800.ms, delay: 600.ms),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '🎯 ¡Perfecto! Con esta información podremos conectarte con los mejores partidos y jugadores que coincidan con tu perfil.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2E7D32),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ).animate().fadeIn(duration: 800.ms, delay: 800.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _currentStep--;
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Anterior'),
            )
          else
            const SizedBox.shrink(),
          ElevatedButton(
            onPressed:
                _currentStep == _totalSteps - 1
                    ? () => _completeOnboarding()
                    : () => _nextStep(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6F00),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _currentStep == _totalSteps - 1 ? '¡COMENZAR!' : 'Siguiente',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  void _nextStep() {
    // Validación básica antes de avanzar
    if (_currentStep == 0) {
      if (_nicknameController.text.trim().isEmpty ||
          _ageController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Completa tu apodo y edad para continuar'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    if (_currentStep == 1) {
      if (_selectedComuna == null ||
          _selectedGenero == null ||
          _selectedNacionalidad == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Completa comuna, género y nacionalidad para continuar',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  Future<void> _completeOnboarding() async {
    if (_selectedNacionalidad == null || _selectedNacionalidad!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar tu nacionalidad.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_selectedGenero == null || _selectedGenero!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar tu género.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_selectedComuna == null || _selectedComuna!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar una comuna.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      final authService = ref.read(authServiceProvider);
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario no autenticado'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      // Generar tag único de 4 dígitos para el usuario
      String tag =
          (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();

      // Construir bio como JSON con los datos adicionales
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

      // Guardar los datos del onboarding en el provider global
      ref.read(onboardingProvider.notifier).state = {
        'display_name': _nicknameController.text.trim(),
        'full_name': _nicknameController.text.trim(),
        'first_name': _nicknameController.text.trim().split(' ').first,
        'last_name':
            _nicknameController.text.trim().split(' ').length > 1
                ? _nicknameController.text.trim().split(' ').last
                : '',
        'photo_url': '', // Puedes agregar lógica para foto si tienes
        'bio': bioJson,
        'position': _mapPosition(_selectedPosition),
        'preferred_foot': _mapFoot(_selectedFoot),
        'date_of_birth':
            _ageController.text.isNotEmpty
                ? DateTime(
                  DateTime.now().year - int.parse(_ageController.text),
                  1,
                  1,
                ).toIso8601String()
                : null,
        'comuna': _selectedComuna,
        'skill_level': _mapSkillLevel(_selectedLevel),
        'tag': tag,
        'is_active': true,
        'nacionalidad': _selectedNacionalidad,
        'genero': _selectedGenero,
        'altura': _selectedHeight,
        'peso': _selectedWeight,
        'experiencia': _selectedExperience,
        'tipo_juego': _selectedGameType,
        'dias_disponibles': _selectedDays,
        'horario_preferido': _selectedTime.format(context),
        'objetivos': _selectedGoals,
      };

      await authService.updateUserProfile(
        userId: currentUser.id,
        data: {
          'display_name': _nicknameController.text.trim(),
          'date_of_birth':
              _ageController.text.isNotEmpty
                  ? DateTime(
                    DateTime.now().year - int.parse(_ageController.text),
                    1,
                    1,
                  ).toIso8601String()
                  : null,
          'position': _mapPosition(_selectedPosition),
          'preferred_foot': _mapFoot(_selectedFoot),
          'skill_level': _mapSkillLevel(_selectedLevel),
          'comuna': _selectedComuna,
          'bio': bioJson.toString(),
          'tag': tag,
          'is_active': true,
          'has_completed_onboarding': true, // ✅ CRÍTICO: Marcar como completado
        },
      );
      if (mounted) {
        _nicknameController.clear();
        _ageController.clear();
        _showSuccessDialog();
      }
    } catch (e) {
      print('Error en onboarding: $e'); // Para debugging
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar el perfil: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Reintentar',
              textColor: Colors.white,
              onPressed: () => _completeOnboarding(),
            ),
          ),
        );
      }
      // No navegar si hay error
      return;
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF2E7D32),
                    size: 80,
                  ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 20),
                  const Text(
                    '¡Perfil Completado!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ).animate().fadeIn(duration: 800.ms, delay: 400.ms),
                  const SizedBox(height: 10),
                  const Text(
                    'Tu perfil de jugador está listo.\n¡Comencemos a jugar!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ).animate().fadeIn(duration: 800.ms, delay: 600.ms),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go('/dashboard');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Ir al Dashboard'),
                  ).animate().fadeIn(duration: 800.ms, delay: 800.ms),
                ],
              ),
            ),
          ),
    );
  }
}
