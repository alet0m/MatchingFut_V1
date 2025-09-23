import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/teams_service.dart';

class CreateTeamPage extends ConsumerStatefulWidget {
  const CreateTeamPage({super.key});

  @override
  ConsumerState<CreateTeamPage> createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends ConsumerState<CreateTeamPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _tagController = TextEditingController();
  String _selectedComuna = 'quilicura';
  bool _isLoading = false;

  // Lista de comunas de Santiago (por ahora solo Quilicura habilitada)
  final List<Map<String, dynamic>> _comunas = [
    {'value': 'quilicura', 'label': 'Quilicura', 'enabled': true},
    {'value': 'maipu', 'label': 'Maipú', 'enabled': false},
    {'value': 'las_condes', 'label': 'Las Condes', 'enabled': false},
    {'value': 'providencia', 'label': 'Providencia', 'enabled': false},
    {'value': 'santiago_centro', 'label': 'Santiago Centro', 'enabled': false},
    {'value': 'puente_alto', 'label': 'Puente Alto', 'enabled': false},
    {'value': 'la_florida', 'label': 'La Florida', 'enabled': false},
    {'value': 'nunoa', 'label': 'Ñuñoa', 'enabled': false},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _createTeam() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final teamsService = ref.read(teamsServiceProvider);
      await teamsService.createTeam(
        name: _nameController.text.trim(),
        tag:
            _tagController.text.trim().isNotEmpty
                ? _tagController.text.trim()
                : null,
        captainId: user.id,
        comunaId: _selectedComuna, // ✅ Usar comunaId en lugar de comuna
      );

      if (mounted) {
        // Invalidar providers para refrescar la lista
        ref.invalidate(userTeamsProvider);
        ref.invalidate(topTeamsProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Equipo creado exitosamente!'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear equipo: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text(
          'Crear Equipo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.group_add,
                        size: 40,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Crear un Nuevo Equipo',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Forma tu equipo y comienza a competir en el territorio',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Formulario
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nombre del Equipo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Ej: Los Tigres FC',
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
                          borderSide: const BorderSide(
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.sports_soccer,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa un nombre para el equipo';
                        }
                        if (value.trim().length < 3) {
                          return 'El nombre debe tener al menos 3 caracteres';
                        }
                        if (value.trim().length > 30) {
                          return 'El nombre no puede exceder 30 caracteres';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Campo Tag
                    const Text(
                      'Tag del Equipo *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Un identificador único y obligatorio para encontrar tu equipo',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _tagController,
                      decoration: InputDecoration(
                        hintText:
                            'Ej: tigresfc, losleones, fuerzaquilicura (obligatorio)',
                        prefixText: '#',
                        prefixStyle: const TextStyle(
                          color: Color(0xFFFF6F00),
                          fontWeight: FontWeight.bold,
                        ),
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
                          borderSide: const BorderSide(
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.tag,
                          color: Color(0xFFFF6F00),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa un tag para el equipo';
                        }
                        if (value.trim().length < 3) {
                          return 'El tag debe tener al menos 3 caracteres';
                        }
                        if (value.trim().length > 20) {
                          return 'El tag no puede exceder 20 caracteres';
                        }
                        // Validar que solo contenga letras, números y guiones
                        if (!RegExp(
                          r'^[a-zA-Z0-9_-]+$',
                        ).hasMatch(value.trim())) {
                          return 'El tag solo puede contener letras, números, _ y -';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        // Auto-convertir a lowercase y remover espacios
                        final cleanValue = value.toLowerCase().replaceAll(
                          ' ',
                          '',
                        );
                        if (cleanValue != value) {
                          _tagController.value = _tagController.value.copyWith(
                            text: cleanValue,
                            selection: TextSelection.collapsed(
                              offset: cleanValue.length,
                            ),
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 24),

                    // Selector de Comuna
                    const Text(
                      'Comuna',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedComuna,
                          hint: const Text('Selecciona tu comuna'),
                          isExpanded: true,
                          icon: const Icon(
                            Icons.location_on,
                            color: Color(0xFF2E7D32),
                          ),
                          items:
                              _comunas.map<DropdownMenuItem<String>>((comuna) {
                                return DropdownMenuItem<String>(
                                  value: comuna['value'],
                                  enabled: comuna['enabled'],
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_city,
                                        color:
                                            comuna['enabled']
                                                ? const Color(0xFF2E7D32)
                                                : Colors.grey,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        comuna['label'],
                                        style: TextStyle(
                                          color:
                                              comuna['enabled']
                                                  ? Colors.black87
                                                  : Colors.grey,
                                          fontWeight:
                                              comuna['enabled']
                                                  ? FontWeight.normal
                                                  : FontWeight.w300,
                                        ),
                                      ),
                                      if (!comuna['enabled'])
                                        const Expanded(
                                          child: Text(
                                            ' (próximamente)',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              final comuna = _comunas.firstWhere(
                                (c) => c['value'] == newValue,
                              );
                              if (comuna['enabled']) {
                                setState(() {
                                  _selectedComuna = newValue;
                                });
                              }
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Color(0xFF2E7D32),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Por ahora solo está disponible Quilicura. '
                              'Pronto habilitaremos más comunas.',
                              style: TextStyle(
                                color: Color(0xFF2E7D32),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Info adicional
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF2E7D32).withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Color(0xFF2E7D32),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Como creador, serás el capitán del equipo',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.people_outline,
                                color: Color(0xFF2E7D32),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Podrás invitar hasta 10 jugadores más',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Botón crear
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createTeam,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text(
                            'Crear Equipo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
}
