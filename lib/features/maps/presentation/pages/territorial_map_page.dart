import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/comuna_selector_widget.dart';
import '../../../locations/data/location_service.dart';
import '../../widgets/responsive_panel.dart';
import '../../data/maps_repository.dart';
import '../../../../core/config/supabase_config.dart';

class TerritorialMapPage extends ConsumerStatefulWidget {
  const TerritorialMapPage({super.key});

  @override
  ConsumerState<TerritorialMapPage> createState() => _TerritorialMapPageState();
}

class _TerritorialMapPageState extends ConsumerState<TerritorialMapPage> {
  String? _selectedComunaId;
  String? _selectedComunaName;
  String? _selectedRegionName;

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
          _selectedRegionName = '';
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
      // Nota: si necesitas el nombre de la región, puedes resolverlo vía LocationService
      _selectedRegionName = _selectedRegionName ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comunas y Ranking'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: const [],
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
          // Panel responsivo (reemplaza el mapa por ahora)
          Expanded(
            child: ResponsivePanel(
              region: _selectedRegionName ?? '',
              comuna: _selectedComunaName ?? '', // vacío => Global
              repo: MapsRepositoryReal(ref.watch(supabaseProvider)),
            ),
          ),
        ],
      ),
      floatingActionButton: null,
    );
  }
}
