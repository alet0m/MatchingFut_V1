import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/locations/data/location_service.dart';

class ComunaSelector extends ConsumerStatefulWidget {
  final String? initialComunaId;
  final Function(String comunaId, String comunaName) onComunaSelected;

  const ComunaSelector({
    super.key,
    this.initialComunaId,
    required this.onComunaSelected,
  });

  @override
  ConsumerState<ComunaSelector> createState() => _ComunaSelectorState();
}

class _ComunaSelectorState extends ConsumerState<ComunaSelector> {
  String? _selectedRegionId;
  String? _selectedComunaId;
  String? _selectedComunaName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedComunaId = widget.initialComunaId;
    // Si ya hay una comuna seleccionada, buscaremos su información
    if (_selectedComunaId != null) {
      _loadInitialComuna();
    }
  }

  Future<void> _loadInitialComuna() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final locationService = ref.read(locationServiceProvider);
      final comunas = await locationService.getActiveComunas();

      if (comunas.isNotEmpty) {
        final selectedComuna = comunas.firstWhere(
          (comuna) => comuna.id == _selectedComunaId,
          orElse: () => comunas.first,
        );

        setState(() {
          _selectedComunaId = selectedComuna.id;
          _selectedComunaName = selectedComuna.name;
          _selectedRegionId = selectedComuna.regionId;
        });
      }
    } catch (e) {
      debugPrint('Error al cargar comuna inicial: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final regionsAsync = ref.watch(activeRegionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Región',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        regionsAsync.when(
          data: (regions) {
            return DropdownButtonFormField<String>(
              value: _selectedRegionId,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Selecciona tu región',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              items:
                  regions.map((region) {
                    return DropdownMenuItem<String>(
                      value: region.id,
                      child: Text(region.name),
                    );
                  }).toList(),
              onChanged: (String? regionId) {
                setState(() {
                  _selectedRegionId = regionId;
                  _selectedComunaId = null;
                  _selectedComunaName = null;
                });
              },
            );
          },
          loading:
              () => const LinearProgressIndicator(
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
              ),
          error:
              (error, stackTrace) => Text(
                'Error al cargar regiones: $error',
                style: const TextStyle(color: Colors.red),
              ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Comuna',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        if (_selectedRegionId != null)
          Consumer(
            builder: (context, ref, child) {
              final comunasAsync = ref.watch(
                comunasByRegionProvider(_selectedRegionId!),
              );

              return comunasAsync.when(
                data: (comunas) {
                  if (comunas.isEmpty) {
                    return const Text(
                      'No hay comunas disponibles en esta región',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    );
                  }

                  return DropdownButtonFormField<String>(
                    value: _selectedComunaId,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Selecciona tu comuna',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    items:
                        comunas.map((comuna) {
                          return DropdownMenuItem<String>(
                            value: comuna.id,
                            child: Text(comuna.name),
                          );
                        }).toList(),
                    onChanged: (String? comunaId) {
                      if (comunaId != null) {
                        final selectedComuna = comunas.firstWhere(
                          (comuna) => comuna.id == comunaId,
                        );
                        setState(() {
                          _selectedComunaId = comunaId;
                          _selectedComunaName = selectedComuna.name;
                        });
                        widget.onComunaSelected(comunaId, selectedComuna.name);
                      }
                    },
                  );
                },
                loading:
                    () => const LinearProgressIndicator(
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF2E7D32),
                      ),
                    ),
                error:
                    (error, stackTrace) => Text(
                      'Error al cargar comunas: $error',
                      style: const TextStyle(color: Colors.red),
                    ),
              );
            },
          )
        else
          const Text(
            'Primero selecciona una región',
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
          ),
      ],
    );
  }
}
