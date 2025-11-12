import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/territorial_map_service.dart';
import '../../../../shared/models/sector_model.dart';

// NOTE: This widget is currently unused after removing territorial map pages.
// Keeping it for potential future use; consider deletion if not needed.
class TerritorialMapWidget extends ConsumerStatefulWidget {
  final String comunaId;
  final Function(SectorModel sector)? onSectorTapped;
  final String? initialSectorId;

  const TerritorialMapWidget({
    super.key,
    required this.comunaId,
    this.onSectorTapped,
    this.initialSectorId,
  });

  @override
  ConsumerState<TerritorialMapWidget> createState() =>
      _TerritorialMapWidgetState();
}

class _TerritorialMapWidgetState extends ConsumerState<TerritorialMapWidget> {
  GoogleMapController? _mapController;
  final Map<String, SectorModel> _sectorsInfo = {};
  String? _selectedSectorId;
  bool _isLoadingSectors = true;
  // bool _isMapReady = false; // unused after feature removal

  // Coordenadas por defecto (centro de Santiago)
  final LatLng _defaultLocation = const LatLng(-33.4489, -70.6693);

  @override
  void initState() {
    super.initState();
    _selectedSectorId = widget.initialSectorId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSectorsInfo();
    });
  }

  Future<void> _loadSectorsInfo() async {
    setState(() {
      _isLoadingSectors = true;
    });

    try {
      final mapService = ref.read(territorialMapServiceProvider);
      final sectorsList = await mapService.getSectorsByComuna(widget.comunaId);

      for (final sector in sectorsList) {
        _sectorsInfo[sector.id] = sector;
      }

      // Si hay un sector seleccionado inicialmente, centramos el mapa en él
      if (_selectedSectorId != null && _mapController != null) {
        _centerMapOnSector(_selectedSectorId!);
      }
    } catch (e) {
      debugPrint('Error al cargar información de sectores: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSectors = false;
        });
      }
    }
  }

  Future<void> _centerMapOnSector(String sectorId) async {
    // Esta función debería obtener el centro del sector y centrar el mapa
    // Por ahora, usamos coordenadas por defecto
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _defaultLocation, zoom: 14),
        ),
      );
    }
  }

  // void _handleSectorTap(String sectorId) {
  //   if (_sectorsInfo.containsKey(sectorId)) {
  //     setState(() {
  //       _selectedSectorId = sectorId;
  //     });
  //
  //     if (widget.onSectorTapped != null) {
  //       widget.onSectorTapped!(_sectorsInfo[sectorId]!);
  //     }
  //
  //     _centerMapOnSector(sectorId);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final polygonsAsync = ref.watch(sectorPolygonsProvider(widget.comunaId));

    return Stack(
      children: [
        polygonsAsync.when(
          data: (polygons) {
            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _defaultLocation,
                zoom: 12,
              ),
              mapType: MapType.normal,
              polygons: polygons,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              compassEnabled: true,
              zoomControlsEnabled: true,
              onMapCreated: (controller) {
                setState(() {
                  _mapController = controller;
                  // _isMapReady = true;
                });

                if (_selectedSectorId != null) {
                  _centerMapOnSector(_selectedSectorId!);
                }
              },
              onTap: (_) {
                // Deseleccionar sector cuando se toca fuera
                setState(() {
                  _selectedSectorId = null;
                });
              },
            );
          },
          loading:
              () => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                ),
              ),
          error:
              (error, stackTrace) => Center(
                child: Text(
                  'Error al cargar el mapa: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
        ),
        if (_isLoadingSectors)
          const Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Card(
                color: Colors.white,
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Cargando sectores...',
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (_selectedSectorId != null &&
            _sectorsInfo.containsKey(_selectedSectorId))
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _sectorsInfo[_selectedSectorId!]!.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    if (_sectorsInfo[_selectedSectorId!]!.description != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _sectorsInfo[_selectedSectorId!]!.description!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _buildSectorInfoChip(
                            'ELO: 1200', // Valor predeterminado porque currentEloThreshold ya no está en el modelo
                            Icons.trending_up,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildSectorInfoChip(
                            'Partidos: ${_sectorsInfo[_selectedSectorId!]!.totalMatches}',
                            Icons.sports_soccer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_sectorsInfo[_selectedSectorId!]!.currentChampionId !=
                        null)
                      ElevatedButton.icon(
                        onPressed: () {
                          // Acción para ver detalles del equipo controlador
                        },
                        icon: const Icon(Icons.emoji_events),
                        label: const Text('Ver equipo controlador'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: () {
                          // Acción para disputar el sector
                        },
                        icon: const Icon(Icons.flag),
                        label: const Text('Disputar este sector'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6F00),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSectorInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
