import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/territorial_map_widget.dart';
import '../../../../shared/models/sector_model.dart';
import '../../../../shared/widgets/comuna_selector_widget.dart';
import '../../../locations/data/location_service.dart';

class TerritorialMapPage extends ConsumerStatefulWidget {
  const TerritorialMapPage({super.key});

  @override
  ConsumerState<TerritorialMapPage> createState() => _TerritorialMapPageState();
}

class _TerritorialMapPageState extends ConsumerState<TerritorialMapPage> {
  String? _selectedComunaId;
  String? _selectedComunaName;
  SectorModel? _selectedSector;

  @override
  void initState() {
    super.initState();
    _loadDefaultComuna();
  }

  Future<void> _loadDefaultComuna() async {
    try {
      final locationService = ref.read(locationServiceProvider);
      final comunas = await locationService.getActiveComunas();

      if (comunas.isNotEmpty) {
        // Por defecto usar Quilicura (o la primera comuna activa)
        final defaultComuna = comunas.firstWhere(
          (comuna) => comuna.name.toLowerCase() == 'quilicura',
          orElse: () => comunas.first,
        );

        setState(() {
          _selectedComunaId = defaultComuna.id;
          _selectedComunaName = defaultComuna.name;
        });
      }
    } catch (e) {
      debugPrint('Error al cargar comuna por defecto: $e');
    }
  }

  void _onComunaSelected(String comunaId, String comunaName) {
    setState(() {
      _selectedComunaId = comunaId;
      _selectedComunaName = comunaName;
      _selectedSector = null; // Reset sector selection when comuna changes
    });
  }

  void _onSectorTapped(SectorModel sector) {
    setState(() {
      _selectedSector = sector;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedComunaName != null
              ? 'Mapa de $_selectedComunaName'
              : 'Mapa Territorial',
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Mostrar información sobre el sistema territorial
              _showTerritorialInfoDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Selector de comuna
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFF8F9FA),
            child: ComunaSelector(
              initialComunaId: _selectedComunaId,
              onComunaSelected: _onComunaSelected,
            ),
          ),
          // Mapa territorial
          Expanded(
            child:
                _selectedComunaId != null
                    ? TerritorialMapWidget(
                      comunaId: _selectedComunaId!,
                      onSectorTapped: _onSectorTapped,
                    )
                    : const Center(
                      child: Text(
                        'Selecciona una comuna para ver el mapa territorial',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar a la página de clasificación por ELO
          context.push('/rankings');
        },
        backgroundColor: const Color(0xFFFF6F00),
        child: const Icon(Icons.leaderboard),
      ),
    );
  }

  void _showTerritorialInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sistema Territorial'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'El sistema territorial te permite:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• Controlar sectores de tu comuna ganando partidos'),
                  Text(
                    '• Aumentar tu ELO y reputación al defender tu territorio',
                  ),
                  Text('• Desafiar a equipos que controlan sectores'),
                  Text('• Organizar partidos en diferentes sectores'),
                  SizedBox(height: 16),
                  Text(
                    'Cómo funciona:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('1. Cada sector tiene un umbral de ELO mínimo'),
                  Text(
                    '2. Al ganar un partido en un sector, tu equipo lo controla',
                  ),
                  Text(
                    '3. Otros equipos pueden desafiarte para tomar el control',
                  ),
                  Text('4. Controlar sectores da bonificaciones de ELO'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Entendido'),
              ),
            ],
          ),
    );
  }
}
