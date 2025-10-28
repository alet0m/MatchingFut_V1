import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../../../onboarding/data/onboarding_provider.dart';
import '../../../auth/data/auth_service.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  final Map<String, dynamic> userProfile;
  const EditProfilePage({super.key, required this.userProfile});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final TextEditingController _bioController = TextEditingController();
  late Map<String, dynamic> _formData;
  late Map<String, bool> _fieldsVisibility;

  @override
  void initState() {
    super.initState();
    _formData = Map<String, dynamic>.from(widget.userProfile);
    // Por defecto, todos los campos visibles
    _fieldsVisibility = {
      'display_name': true,
      'email': true,
      'comuna': true,
      'date_of_birth': true,
      'position': true,
      'preferred_foot': true,
      'skill_level': true,
      'bio': true,
      'altura': true,
      'peso': true,
      'experiencia': true,
      'tipo_juego': true,
      'dias_disponibles': true,
      'horario_preferido': true,
      'objetivos': true,
    };
    // Inicializar el controlador de biografía con el valor actual
    dynamic bioValue = _formData['bio'];
    if (bioValue == null && _formData['bio'] != null) {
      try {
        final bioMap =
            _formData['bio'] is String
                ? json.decode(_formData['bio'])
                : _formData['bio'];
        bioValue = bioMap['bio'];
      } catch (_) {}
    }
    _bioController.text = bioValue?.toString() ?? '';
  }

  void _saveProfile() async {
    // Actualiza el provider global
    ref.read(onboardingProvider.notifier).state = _formData;
    // Actualiza en Supabase
    final supabase = ref.read(supabaseClientProvider);
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      // Construir el bio correctamente como Map
      final bioMap = <String, dynamic>{};
      for (final key in [
        'altura',
        'peso',
        'experiencia',
        'tipo_juego',
        'dias_disponibles',
        'horario_preferido',
        'objetivos',
      ]) {
        if (_formData.containsKey(key)) {
          bioMap[key] = _formData[key];
        }
      }

      // Preparar datos básicos que sabemos que existen
      final basicUpdate = {
        'display_name': _formData['display_name'],
        'full_name': _formData['full_name'],
        'bio': json.encode(bioMap),
        'position': _formData['position'],
        'preferred_foot': _formData['preferred_foot'],
        'comuna': _formData['comuna'],
        'skill_level': _formData['skill_level'],
        'updated_at': DateTime.now().toIso8601String(),
        'tag': _formData['tag'],
        'is_active': true,
      };

      // Agregar date_of_birth solo si no está vacío
      final dateOfBirth = _formData['date_of_birth'];
      if (dateOfBirth != null && dateOfBirth.toString().trim().isNotEmpty) {
        basicUpdate['date_of_birth'] = dateOfBirth;
      }

      try {
        // Intentar con todos los campos
        final fullUpdate = {
          ...basicUpdate,
          'first_name': _formData['first_name'],
          'last_name': _formData['last_name'],
          'photo_url': _formData['photo_url'],
        };
        await supabase
            .from('profiles')
            .update(fullUpdate)
            .eq('id', currentUser.id);
      } catch (e) {
        // Si falla, intentar solo con campos básicos
        print(
          'Warning: Some profile fields may not exist, using basic fields only: $e',
        );
        await supabase
            .from('profiles')
            .update(basicUpdate)
            .eq('id', currentUser.id);
      }
    }
    Navigator.of(context).pop(_formData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._fieldsVisibility.keys.map((key) => _buildEditableField(key)),
            const SizedBox(height: 24),
            Text(
              '¿Qué quieres mostrar en tu perfil?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8,
              children:
                  _fieldsVisibility.keys
                      .map(
                        (key) => FilterChip(
                          label: Text(_getLabel(key)),
                          selected: _fieldsVisibility[key]!,
                          onSelected: (selected) {
                            setState(() {
                              _fieldsVisibility[key] = selected;
                            });
                          },
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Guardar cambios'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _saveProfile,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(String key) {
    if (key == 'tipo_de_juego') {
      final items = [
        'Fútbol 5',
        'Fútbol 7',
        'Fútbol 9',
        'Fútbol 11',
        'Futsal',
        'Mixto',
      ];
      final dropdownValue =
          items.contains(_formData[key]) ? _formData[key] : items.first;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: DropdownButtonFormField<String>(
          value: dropdownValue,
          decoration: InputDecoration(
            labelText: 'Tipo de juego',
            border: OutlineInputBorder(),
          ),
          items:
              items
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
          onChanged: (val) {
            setState(() {
              _formData[key] = val;
            });
          },
        ),
      );
    }
    if (key == 'bio') {
      // Campo de biografía editable multilinea interactivo
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _bioController,
              decoration: InputDecoration(
                labelText: _getLabel(key),
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Limpiar biografía',
                  onPressed: () {
                    _bioController.clear();
                    setState(() {
                      _formData[key] = '';
                    });
                  },
                ),
              ),
              maxLines: 4,
              maxLength: 200,
              onChanged: (val) {
                setState(() {
                  _formData[key] = val;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${_bioController.text.length}/200 caracteres',
                  style: TextStyle(
                    color:
                        _bioController.text.length > 180
                            ? Colors.orange
                            : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    if (!_fieldsVisibility[key]!) return const SizedBox.shrink();
    // Si el campo es del bio, obtener el valor desde bio
    dynamic value = _formData[key];
    if (value == null && _formData['bio'] != null) {
      try {
        final bioMap =
            _formData['bio'] is String
                ? json.decode(_formData['bio'])
                : _formData['bio'];
        value = bioMap[key];
      } catch (_) {}
    }
    value = value?.toString() ?? '';

    // Campos con opciones predefinidas
    if (key == 'dias_disponibles') {
      final items = [
        'Lunes',
        'Martes',
        'Miércoles',
        'Jueves',
        'Viernes',
        'Sábado',
        'Domingo',
      ];
      List<String> selected = [];
      if (_formData[key] is List) {
        selected = List<String>.from(_formData[key]);
      } else if (_formData[key] is String &&
          (_formData[key] as String).isNotEmpty) {
        selected =
            (_formData[key] as String).split(',').map((e) => e.trim()).toList();
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: _getLabel(key),
            border: OutlineInputBorder(),
          ),
          child: Wrap(
            spacing: 8,
            children:
                items
                    .map(
                      (dia) => FilterChip(
                        label: Text(dia),
                        selected: selected.contains(dia),
                        onSelected: (sel) {
                          setState(() {
                            if (sel) {
                              selected.add(dia);
                            } else {
                              selected.remove(dia);
                            }
                            _formData[key] = selected;
                          });
                        },
                      ),
                    )
                    .toList(),
          ),
        ),
      );
    }
    if (key == 'objetivos') {
      final items = [
        'Mejorar técnica',
        'Hacer amigos',
        'Competir',
        'Divertirse',
        'Ejercicio',
        'Ganar partidos',
      ];
      List<String> selected = [];
      if (_formData[key] is List) {
        selected = List<String>.from(_formData[key]);
      } else if (_formData[key] is String &&
          (_formData[key] as String).isNotEmpty) {
        selected =
            (_formData[key] as String).split(',').map((e) => e.trim()).toList();
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: _getLabel(key),
            border: OutlineInputBorder(),
          ),
          child: Wrap(
            spacing: 8,
            children:
                items
                    .map(
                      (obj) => FilterChip(
                        label: Text(obj),
                        selected: selected.contains(obj),
                        onSelected: (sel) {
                          setState(() {
                            if (sel) {
                              selected.add(obj);
                            } else {
                              selected.remove(obj);
                            }
                            _formData[key] = selected;
                          });
                        },
                      ),
                    )
                    .toList(),
          ),
        ),
      );
    }
    if (key == 'date_of_birth') {
      // Selector de fecha
      DateTime? selectedDate;
      if (_formData[key] != null && _formData[key].toString().isNotEmpty) {
        try {
          selectedDate = DateTime.parse(_formData[key]);
        } catch (_) {}
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime(2000, 1, 1),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() {
                _formData[key] = picked.toIso8601String().substring(0, 10);
              });
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: _getLabel(key),
              border: OutlineInputBorder(),
            ),
            child: Text(
              _formData[key]?.toString() ?? 'Selecciona fecha',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }
    if (key == 'altura') {
      final items = List.generate(61, (i) => (140 + i).toString());
      final dropdownValue = items.contains(value) ? value : '170';
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: DropdownButtonFormField<String>(
          value: dropdownValue,
          decoration: InputDecoration(
            labelText: '${_getLabel(key)} (cm)',
            border: OutlineInputBorder(),
          ),
          items:
              items
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
          onChanged: (val) {
            setState(() {
              _formData[key] = val;
            });
          },
        ),
      );
    }
    if (key == 'peso') {
      final items = List.generate(81, (i) => (40 + i).toString());
      final dropdownValue = items.contains(value) ? value : '70';
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: DropdownButtonFormField<String>(
          value: dropdownValue,
          decoration: InputDecoration(
            labelText: '${_getLabel(key)} (kg)',
            border: OutlineInputBorder(),
          ),
          items:
              items
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
          onChanged: (val) {
            setState(() {
              _formData[key] = val;
            });
          },
        ),
      );
    }
    if (key == 'experiencia') {
      final items = List.generate(21, (i) => i.toString());
      final dropdownValue = items.contains(value) ? value : '0';
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: DropdownButtonFormField<String>(
          value: dropdownValue,
          decoration: InputDecoration(
            labelText: '${_getLabel(key)} (años)',
            border: OutlineInputBorder(),
          ),
          items:
              items
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
          onChanged: (val) {
            setState(() {
              _formData[key] = val;
            });
          },
        ),
      );
    }
    // Campo de selección para posición, nivel, pie hábil, tipo de juego
    if (key == 'position') {
      final items = ['Arquero', 'Defensa', 'Mediocampo', 'Delantero'];
      final dropdownValue = items.contains(value) ? value : items.first;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: DropdownButtonFormField<String>(
          value: dropdownValue,
          decoration: InputDecoration(
            labelText: _getLabel(key),
            border: OutlineInputBorder(),
          ),
          items:
              items
                  .map((pos) => DropdownMenuItem(value: pos, child: Text(pos)))
                  .toList(),
          onChanged: (val) {
            setState(() {
              _formData[key] = val;
            });
          },
        ),
      );
    }
    if (key == 'skill_level') {
      final items = ['Principiante', 'Intermedio', 'Avanzado', 'Profesional'];
      final dropdownValue = items.contains(value) ? value : items.first;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: DropdownButtonFormField<String>(
          value: dropdownValue,
          decoration: InputDecoration(
            labelText: _getLabel(key),
            border: OutlineInputBorder(),
          ),
          items:
              items
                  .map((lvl) => DropdownMenuItem(value: lvl, child: Text(lvl)))
                  .toList(),
          onChanged: (val) {
            setState(() {
              _formData[key] = val;
            });
          },
        ),
      );
    }
    if (key == 'preferred_foot') {
      final items = ['Derecho', 'Izquierdo', 'Ambidiestro'];
      final dropdownValue = items.contains(value) ? value : items.first;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: DropdownButtonFormField<String>(
          value: dropdownValue,
          decoration: InputDecoration(
            labelText: _getLabel(key),
            border: OutlineInputBorder(),
          ),
          items:
              items
                  .map(
                    (foot) => DropdownMenuItem(value: foot, child: Text(foot)),
                  )
                  .toList(),
          onChanged: (val) {
            setState(() {
              _formData[key] = val;
            });
          },
        ),
      );
    }
    if (key == 'tipo_juego') {
      final items = ['Fútbol 5', 'Fútbol 7', 'Fútbol 11'];
      final dropdownValue = items.contains(value) ? value : items.first;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: DropdownButtonFormField<String>(
          value: dropdownValue,
          decoration: InputDecoration(
            labelText: _getLabel(key),
            border: OutlineInputBorder(),
          ),
          items:
              items
                  .map(
                    (tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)),
                  )
                  .toList(),
          onChanged: (val) {
            setState(() {
              _formData[key] = val;
            });
          },
        ),
      );
    }
    // Campo texto normal
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: value,
        decoration: InputDecoration(
          labelText: _getLabel(key),
          border: OutlineInputBorder(),
        ),
        onChanged: (val) {
          setState(() {
            _formData[key] = val;
          });
        },
      ),
    );
  }

  String _getLabel(String key) {
    switch (key) {
      case 'display_name':
        return 'Nombre público';
      case 'email':
        return 'Email';
      case 'comuna':
        return 'Comuna';
      case 'date_of_birth':
        return 'Fecha de nacimiento';
      case 'position':
        return 'Posición';
      case 'preferred_foot':
        return 'Pie hábil';
      case 'skill_level':
        return 'Nivel';
      case 'bio':
        return 'Biografía';
      case 'altura':
        return 'Altura';
      case 'peso':
        return 'Peso';
      case 'experiencia':
        return 'Experiencia';
      case 'tipo_juego':
        return 'Tipo de juego';
      case 'dias_disponibles':
        return 'Días disponibles';
      case 'horario_preferido':
        return 'Horario preferido';
      case 'objetivos':
        return 'Objetivos';
      default:
        return key;
    }
  }
}
