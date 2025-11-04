import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import '../../../core/config/supabase_config.dart';
import '../../../shared/models/sector_model.dart';

class TerritorialMapService {
  final SupabaseClient _supabase;

  TerritorialMapService(this._supabase);

  // Obtener sectores básicos desde la tabla sectors (evita depender de RPCs)
  Future<List<Map<String, dynamic>>> getSectorsForMap(String comunaId) async {
    try {
      final response = await _supabase
          .from('sectors')
          .select(
            'id,name,description,geojson,current_champion_id,center_lat,center_lng,bounds',
          )
          .eq('comuna_id', comunaId)
          .eq('is_active', true)
          .order('name');

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
        final lat = (point[1] as num).toDouble();
        final lng = (point[0] as num).toDouble();
        return LatLng(lat, lng);
      }).toList();
    } catch (e) {
      debugPrint('Error al parsear puntos del polígono: $e');
      return [];
    }
  }

  // Generar polígonos de Google Maps a partir de los datos de sectores
  Future<Set<Polygon>> generateSectorPolygons(String comunaId) async {
    try {
      final sectors = await getSectorsForMap(comunaId);
      final Set<Polygon> polygons = {};

      for (final sector in sectors) {
        try {
          final String sectorId = sector['id']?.toString() ?? '';
          if (sectorId.isEmpty) continue;

          // geojson puede venir como Map o String
          final dynamic geoDyn = sector['geojson'];
          Map<String, dynamic>? geo;
          if (geoDyn is String) {
            try {
              geo = jsonDecode(geoDyn) as Map<String, dynamic>;
            } catch (_) {
              geo = null;
            }
          } else if (geoDyn is Map<String, dynamic>) {
            geo = geoDyn;
          }

          final String teamId =
              (sector['current_champion_id']?.toString() ?? '');

          // Definir color del polígono según si tiene equipo controlador
          final Color fillColor =
              teamId.isNotEmpty
                  ? const Color(0x662E7D32) // Verde con transparencia
                  : const Color(0x66FF6F00); // Naranja con transparencia

          final Color strokeColor =
              teamId.isNotEmpty
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFFF6F00);

          if (geo != null &&
              geo['type'] != null &&
              geo['coordinates'] != null) {
            final type = geo['type']?.toString();
            final coords = geo['coordinates'];

            if (type == 'Polygon') {
              final List<dynamic> outerRing = (coords as List).first as List;
              final points = parsePolygonPoints(outerRing);
              if (points.isNotEmpty) {
                polygons.add(
                  Polygon(
                    polygonId: PolygonId('sector_$sectorId'),
                    points: points,
                    fillColor: fillColor,
                    strokeColor: strokeColor,
                    strokeWidth: 2,
                    consumeTapEvents: true,
                  ),
                );
              }
            } else if (type == 'MultiPolygon') {
              int idx = 0;
              for (final poly in (coords as List)) {
                final List<dynamic> outerRing = (poly as List).first as List;
                final points = parsePolygonPoints(outerRing);
                if (points.isNotEmpty) {
                  polygons.add(
                    Polygon(
                      polygonId: PolygonId('sector_${sectorId}_$idx'),
                      points: points,
                      fillColor: fillColor,
                      strokeColor: strokeColor,
                      strokeWidth: 2,
                      consumeTapEvents: true,
                    ),
                  );
                  idx++;
                }
              }
            }
          }
        } catch (e) {
          debugPrint('Error al generar polígono para sector: $e');
        }
      }

      return polygons;
    } catch (e) {
      debugPrint('Error general al generar polígonos: $e');
      return <Polygon>{};
    }
  }

  // Obtener el centro de un sector para posicionar la cámara
  Future<LatLng?> getSectorCenter(String sectorId) async {
    try {
      final data =
          await _supabase
              .from('sectors')
              .select('center_lat, center_lng, bounds')
              .eq('id', sectorId)
              .maybeSingle();

      if (data == null) return null;

      if (data['center_lat'] != null && data['center_lng'] != null) {
        final lat = (data['center_lat'] as num).toDouble();
        final lng = (data['center_lng'] as num).toDouble();
        return LatLng(lat, lng);
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
      final row =
          await _supabase
              .from('sectors')
              .select(
                'id,name,description,current_champion_id,center_lat,center_lng,bounds',
              )
              .eq('id', sectorId)
              .maybeSingle();
      return row == null ? null : Map<String, dynamic>.from(row);
    } catch (e) {
      debugPrint('Error al obtener detalles del sector: $e');
      return null;
    }
  }

  // Cargar lista de sectores de una comuna en forma de modelos (para ficha inferior)
  Future<List<SectorModel>> getSectorsByComuna(String comunaId) async {
    try {
      final response = await _supabase
          .from('sectors')
          .select(
            'id,name,description,comuna_id,total_matches,created_at,current_champion_id',
          )
          .eq('comuna_id', comunaId)
          .eq('is_active', true)
          .order('name');

      final List<SectorModel> result = [];
      for (final row in response) {
        try {
          final id = row['id']?.toString();
          final comuna = row['comuna_id']?.toString();
          // Si faltan claves críticas, saltar la fila para evitar excepciones
          if (id == null || id.isEmpty || comuna == null || comuna.isEmpty) {
            continue;
          }
          final createdAtStr = row['created_at']?.toString();
          final createdAt =
              createdAtStr != null
                  ? DateTime.tryParse(createdAtStr) ?? DateTime.now()
                  : DateTime.now();

          result.add(
            SectorModel(
              id: id,
              name: (row['name'] ?? '').toString(),
              comunaId: comuna,
              description: row['description']?.toString(),
              currentChampionId: row['current_champion_id']?.toString(),
              totalMatches: (row['total_matches'] as int?) ?? 0,
              createdAt: createdAt,
            ),
          );
        } catch (inner) {
          debugPrint('Fila de sector inválida, se omite: $inner');
        }
      }
      return result;
    } catch (e) {
      debugPrint('Error al cargar sectores por comuna: $e');
      return [];
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
