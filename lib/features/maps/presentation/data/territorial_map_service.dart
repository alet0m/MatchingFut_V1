import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import '../../../../shared/models/sector_model.dart';

final territorialMapServiceProvider = Provider<TerritorialMapService>((ref) {
  final supabase = Supabase.instance.client;
  return TerritorialMapService(supabase);
});

final sectorPolygonsProvider = FutureProvider.family<Set<Polygon>, String>((
  ref,
  comunaId,
) async {
  final service = ref.watch(territorialMapServiceProvider);
  return service.getSectorPolygons(comunaId);
});

class TerritorialMapService {
  final SupabaseClient _supabase;

  TerritorialMapService(this._supabase);

  Future<List<SectorModel>> getSectorsByComuna(String comunaId) async {
    final response = await _supabase
        .from('sectors')
        .select()
        .eq('comuna_id', comunaId);

    return response
        .map<SectorModel>((data) => SectorModel.fromJson(data))
        .toList();
  }

  Future<SectorModel?> getSectorById(String sectorId) async {
    try {
      final response =
          await _supabase.from('sectors').select().eq('id', sectorId).single();
      return SectorModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<Set<Polygon>> getSectorPolygons(String comunaId) async {
    final sectors = await getSectorsByComuna(comunaId);
    final Set<Polygon> polygons = {};

    for (final sector in sectors) {
      // Aquí deberíamos obtener los polígonos de cada sector desde la base de datos
      // Por ahora, usamos datos de prueba
      final List<LatLng> points = [
        const LatLng(-33.3622, -70.7322),
        const LatLng(-33.3622, -70.7222),
        const LatLng(-33.3522, -70.7222),
        const LatLng(-33.3522, -70.7322),
      ];

      polygons.add(
        Polygon(
          polygonId: PolygonId(sector.id),
          points: points,
          fillColor:
              sector.currentChampionId != null
                  ? const Color(0x7F00FF00) // Verde si está controlado
                  : const Color(0x7FFF0000), // Rojo si no está controlado
          strokeWidth: 2,
          strokeColor: const Color(0xFF000000),
        ),
      );
    }

    return polygons;
  }

  Future<Map<String, dynamic>> getSectorMetadata(String sectorId) async {
    final response =
        await _supabase
            .from('sectors')
            .select('*, controlling_team:teams(*)')
            .eq('id', sectorId)
            .single();

    return response;
  }
}
