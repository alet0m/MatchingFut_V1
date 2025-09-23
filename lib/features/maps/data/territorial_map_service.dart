import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/sector_model.dart';
import '../../../core/config/supabase_config.dart';

class TerritorialMapService {
  final SupabaseClient _supabase;

  TerritorialMapService(this._supabase);

  // Obtener todos los sectores con su información geográfica para mostrar en el mapa
  Future<List<Map<String, dynamic>>> getSectorsForMap(String comunaId) async {
    try {
      final response = await _supabase.rpc(
        'get_sectors_with_geometry',
        params: {'comuna_id_param': comunaId},
      );

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('Error al cargar sectores para el mapa: $e');
      return [];
    }
  }

  // Convertir la geometría de PostGIS a polígonos de Google Maps
  List<LatLng> parsePolygonPoints(List<dynamic> coordinates) {
    try {
      return coordinates.map<LatLng>((point) {
        return LatLng(point[1] as double, point[0] as double);
      }).toList();
    } catch (e) {
      debugPrint('Error al parsear puntos del polígono: $e');
      return [];
    }
  }

  // Generar polígonos de Google Maps a partir de los datos de sectores
  Future<Set<Polygon>> generateSectorPolygons(String comunaId) async {
    final sectors = await getSectorsForMap(comunaId);
    final Set<Polygon> polygons = {};

    for (final sector in sectors) {
      try {
        final String sectorId = sector['id'];
        final String sectorName = sector['name'];
        final List<dynamic> coordinates = sector['coordinates'];
        final String teamId = sector['controlling_team_id'] ?? '';
        final String teamName =
            sector['controlling_team_name'] ?? 'Sin control';
        final String teamTag = sector['controlling_team_tag'] ?? '';
        final int eloThreshold = sector['current_elo_threshold'] ?? 1200;

        // Definir color del polígono según si tiene equipo controlador
        final Color fillColor =
            teamId.isNotEmpty
                ? Color(
                  0x662E7D32,
                ) // Verde con transparencia si está controlado
                : Color(
                  0x66FF6F00,
                ); // Naranja con transparencia si no está controlado

        final Color strokeColor =
            teamId.isNotEmpty
                ? Color(0xFF2E7D32) // Verde para borde si está controlado
                : Color(0xFFFF6F00); // Naranja para borde si no está controlado

        // Crear polígono con la información
        final Polygon polygon = Polygon(
          polygonId: PolygonId('sector_$sectorId'),
          points: parsePolygonPoints(coordinates),
          fillColor: fillColor,
          strokeColor: strokeColor,
          strokeWidth: 2,
          consumeTapEvents: true,
          onTap: () {
            // Este evento será manejado por el widget que use este servicio
          },
        );

        polygons.add(polygon);
      } catch (e) {
        debugPrint('Error al generar polígono para sector: $e');
      }
    }

    return polygons;
  }

  // Obtener el centro de un sector para posicionar la cámara
  Future<LatLng?> getSectorCenter(String sectorId) async {
    try {
      final response = await _supabase.rpc(
        'get_sector_center',
        params: {'sector_id_param': sectorId},
      );

      if (response != null) {
        return LatLng(
          response['latitude'] as double,
          response['longitude'] as double,
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error al obtener centro del sector: $e');
      return null;
    }
  }

  // Obtener detalles completos de un sector
  Future<Map<String, dynamic>?> getSectorDetails(String sectorId) async {
    try {
      final response = await _supabase.rpc(
        'get_sector_details',
        params: {'sector_id_param': sectorId},
      );

      return response as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error al obtener detalles del sector: $e');
      return null;
    }
  }
}

// Provider para el servicio de mapas territoriales
final territorialMapServiceProvider = Provider<TerritorialMapService>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return TerritorialMapService(supabase);
});

// Provider para obtener polígonos de sectores
final sectorPolygonsProvider = FutureProvider.family<Set<Polygon>, String>((
  ref,
  comunaId,
) async {
  final mapService = ref.watch(territorialMapServiceProvider);
  return mapService.generateSectorPolygons(comunaId);
});
