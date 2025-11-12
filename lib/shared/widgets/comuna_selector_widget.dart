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
  // ignore: unused_field
  String? _selectedComunaName;
  // ignore: unused_field
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
    final scheme = Theme.of(context).colorScheme;
    final regionsAsync = ref.watch(activeRegionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Región',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        regionsAsync.when(
          data: (regions) {
            return DropdownButtonFormField<String>(
              value: _selectedRegionId,
              decoration: InputDecoration(
                filled: true,
                fillColor: scheme.surface,
                hintText: 'Selecciona tu región',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: scheme.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: scheme.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: scheme.primary, width: 2),
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
              () => LinearProgressIndicator(
                backgroundColor: scheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
              ),
          error:
              (error, stackTrace) => Text(
                'Error al cargar regiones: $error',
                style: TextStyle(color: scheme.error),
              ),
        ),
        const SizedBox(height: 16),
        Text(
          'Comuna',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
          ),
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
                    return Text(
                      'No hay comunas disponibles en esta región',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: scheme.onSurfaceVariant,
                      ),
                    );
                  }

                  return DropdownButtonFormField<String>(
                    value: _selectedComunaId,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: scheme.surface,
                      hintText: 'Selecciona tu comuna',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: scheme.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: scheme.outlineVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: scheme.primary, width: 2),
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
                    () => LinearProgressIndicator(
                      backgroundColor: scheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
                    ),
                error:
                    (error, stackTrace) => Text(
                      'Error al cargar comunas: $error',
                      style: TextStyle(color: scheme.error),
                    ),
              );
            },
          )
        else
          Text(
            'Primero selecciona una región',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: scheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}
