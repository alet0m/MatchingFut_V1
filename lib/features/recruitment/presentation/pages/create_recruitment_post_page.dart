import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/recruitment_models.dart';
import '../../data/providers/recruitment_provider.dart';

class CreateRecruitmentPostPage extends ConsumerStatefulWidget {
  const CreateRecruitmentPostPage({super.key});

  @override
  ConsumerState<CreateRecruitmentPostPage> createState() =>
      _CreateRecruitmentPostPageState();
}

class _CreateRecruitmentPostPageState
    extends ConsumerState<CreateRecruitmentPostPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _trainingScheduleController = TextEditingController();
  final _availabilityController = TextEditingController();
  final _contactInfoController = TextEditingController();

  String _postType = 'team_seeking_player';
  String? _selectedComuna;
  String? _selectedPosition;
  String? _selectedExperience;
  int? _ageRangeMin;
  int? _ageRangeMax;
  String? _selectedContactMethod = 'app';
  bool _isLoading = false;

  final List<String> _comunas = [
    'Las Condes',
    'Providencia',
    'Ñuñoa',
    'Santiago',
    'Quilicura',
    'Maipú',
    'Puente Alto',
    'La Florida',
    'San Miguel',
    'Independencia',
  ];

  final List<String> _positions = [
    'Arquero',
    'Defensa',
    'Mediocampo',
    'Delantero',
    'Cualquier posición',
  ];

  final List<String> _experienceLevels = [
    'Principiante',
    'Intermedio',
    'Avanzado',
    'Cualquier nivel',
  ];

  final List<String> _contactMethods = ['app', 'whatsapp', 'email'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _trainingScheduleController.dispose();
    _availabilityController.dispose();
    _contactInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Publicación'),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _savePost,
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
              // Tipo de publicación
              _buildSectionTitle('Tipo de publicación'),
              _buildPostTypeSelector(),

              const SizedBox(height: 24),

              // Información básica
              _buildSectionTitle('Información básica'),
              _buildBasicInfo(),

              const SizedBox(height: 24),

              // Información específica según tipo
              _buildSectionTitle(
                _postType == 'team_seeking_player'
                    ? 'Requisitos del jugador'
                    : 'Información del jugador',
              ),
              _buildSpecificInfo(),

              const SizedBox(height: 24),

              // Contacto
              _buildSectionTitle('Información de contacto'),
              _buildContactInfo(),

              const SizedBox(height: 32),

              // Botón guardar
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _savePost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Crear Publicación',
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

  Widget _buildPostTypeSelector() {
    return Container(
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
          RadioListTile<String>(
            title: const Text('🏆 Equipo busca jugador'),
            subtitle: const Text(
              'Publicar una búsqueda de jugador para tu equipo',
            ),
            value: 'team_seeking_player',
            groupValue: _postType,
            onChanged: (value) {
              setState(() {
                _postType = value!;
              });
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          const Divider(height: 1),
          RadioListTile<String>(
            title: const Text('⚽ Jugador busca equipo'),
            subtitle: const Text('Promocionarte como jugador disponible'),
            value: 'player_seeking_team',
            groupValue: _postType,
            onChanged: (value) {
              setState(() {
                _postType = value!;
              });
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
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
              labelText: 'Título de la publicación',
              hintText: 'Ej: Se busca delantero centro',
              border: OutlineInputBorder(),
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
              hintText: 'Describe los detalles de la publicación...',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa una descripción';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _selectedComuna,
            decoration: const InputDecoration(
              labelText: 'Comuna',
              border: OutlineInputBorder(),
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
        ],
      ),
    );
  }

  Widget _buildSpecificInfo() {
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
            value: _selectedPosition,
            decoration: InputDecoration(
              labelText:
                  _postType == 'team_seeking_player'
                      ? 'Posición buscada'
                      : 'Tu posición',
              border: const OutlineInputBorder(),
            ),
            items:
                _positions.map((position) {
                  return DropdownMenuItem(
                    value: position,
                    child: Text(position),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedPosition = value;
              });
            },
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _selectedExperience,
            decoration: InputDecoration(
              labelText:
                  _postType == 'team_seeking_player'
                      ? 'Nivel requerido'
                      : 'Tu nivel de experiencia',
              border: const OutlineInputBorder(),
            ),
            items:
                _experienceLevels.map((level) {
                  return DropdownMenuItem(value: level, child: Text(level));
                }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedExperience = value;
              });
            },
          ),

          const SizedBox(height: 16),

          if (_postType == 'team_seeking_player') ...[
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Edad mínima',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _ageRangeMin = int.tryParse(value);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Edad máxima',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _ageRangeMax = int.tryParse(value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _trainingScheduleController,
              decoration: const InputDecoration(
                labelText: 'Horarios de entrenamiento',
                hintText: 'Ej: Martes y jueves 19:00-21:00',
                border: OutlineInputBorder(),
              ),
            ),
          ] else ...[
            TextFormField(
              controller: _availabilityController,
              decoration: const InputDecoration(
                labelText: 'Tu disponibilidad',
                hintText: 'Ej: Fines de semana, noches entre semana',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
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
            value: _selectedContactMethod,
            decoration: const InputDecoration(
              labelText: 'Método de contacto preferido',
              border: OutlineInputBorder(),
            ),
            items:
                _contactMethods.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(_getContactMethodDisplayName(method)),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedContactMethod = value;
              });
            },
          ),

          const SizedBox(height: 16),

          if (_selectedContactMethod != 'app')
            TextFormField(
              controller: _contactInfoController,
              decoration: InputDecoration(
                labelText:
                    _selectedContactMethod == 'whatsapp'
                        ? 'Número de WhatsApp'
                        : 'Email de contacto',
                hintText:
                    _selectedContactMethod == 'whatsapp'
                        ? '+56 9 1234 5678'
                        : 'tu.email@ejemplo.com',
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (_selectedContactMethod != 'app' &&
                    (value == null || value.isEmpty)) {
                  return 'Por favor ingresa información de contacto';
                }
                return null;
              },
            ),
        ],
      ),
    );
  }

  String _getContactMethodDisplayName(String method) {
    switch (method) {
      case 'app':
        return 'A través de la aplicación';
      case 'whatsapp':
        return 'WhatsApp';
      case 'email':
        return 'Email';
      default:
        return method;
    }
  }

  Future<void> _savePost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final post = RecruitmentPost(
        id: '', // Se generará en el backend
        authorId: 'current-user-id', // TODO: Obtener del auth
        postType: _postType,
        title: _titleController.text,
        description: _descriptionController.text,
        comuna: _selectedComuna!,
        contactMethod: _selectedContactMethod!,
        contactInfo:
            _contactInfoController.text.isNotEmpty
                ? _contactInfoController.text
                : null,
        positionNeeded:
            _postType == 'team_seeking_player' ? _selectedPosition : null,
        experienceLevel:
            _postType == 'team_seeking_player' ? _selectedExperience : null,
        ageRangeMin: _ageRangeMin,
        ageRangeMax: _ageRangeMax,
        trainingSchedule:
            _trainingScheduleController.text.isNotEmpty
                ? _trainingScheduleController.text
                : null,
        playerPosition:
            _postType == 'player_seeking_team' ? _selectedPosition : null,
        playerExperience:
            _postType == 'player_seeking_team' ? _selectedExperience : null,
        availability:
            _availabilityController.text.isNotEmpty
                ? _availabilityController.text
                : null,
        authorName: 'Usuario Actual', // TODO: Obtener del profile
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        featured: false,
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );

      await ref.read(recruitmentProvider.notifier).createPost(post);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Publicación creada exitosamente'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear publicación: $error'),
            backgroundColor: Theme.of(context).colorScheme.error,
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
