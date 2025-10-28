import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/region_model.dart';
import '../../../shared/models/comuna_model.dart';
import '../../../shared/models/sector_model.dart';
import '../../../core/config/supabase_config.dart';

class LocationService {
  final SupabaseClient _supabase;

  LocationService(this._supabase);

  // Helper methods para mapear datos
  Map<String, dynamic> _mapRegionFromDatabase(Map<String, dynamic> dbRegion) {
    return {
      'id': dbRegion['id']?.toString() ?? '',
      'name': (dbRegion['name'] ?? '').toString(),
      'code': (dbRegion['code'] ?? '').toString(),
      // Campos extra ignorados por el modelo, útiles si amplías el modelo luego
      'ordinal': dbRegion['ordinal'],
      'isActive': dbRegion['is_active'] ?? false,
      'createdAt':
          dbRegion['created_at']?.toString() ??
          DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> _mapComunaFromDatabase(Map<String, dynamic> dbComuna) {
    return {
      'id': dbComuna['id']?.toString() ?? '',
      'name': (dbComuna['name'] ?? '').toString(),
      'regionId': dbComuna['region_id']?.toString() ?? '',
      'code': (dbComuna['code'] ?? '').toString(),
      'isActive': dbComuna['is_active'] ?? false,
      'description': dbComuna['description'],
      'featuredImageUrl': dbComuna['featured_image_url'],
      'totalPlayers': dbComuna['total_players'] ?? 0,
      'totalTeams': dbComuna['total_teams'] ?? 0,
      'totalMatches': dbComuna['total_matches'] ?? 0,
      'createdAt':
          dbComuna['created_at']?.toString() ??
          DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> _mapSectorFromDatabase(Map<String, dynamic> dbSector) {
    return {
      // Campos esperados por SectorModel
      'id': dbSector['id']?.toString() ?? '',
      'name': (dbSector['name'] ?? '').toString(),
      'comunaId': dbSector['comuna_id']?.toString() ?? '',
      'description': dbSector['description'],
      'currentChampionId': dbSector['current_champion_id']?.toString(),
      'totalMatches': dbSector['total_matches'] ?? 0,
      // Freezed fromJson espera String ISO para DateTime
      'createdAt':
          dbSector['created_at']?.toString() ??
          DateTime.now().toIso8601String(),
    };
  }

  // Obtener todas las regiones activas
  Future<List<RegionModel>> getActiveRegions() async {
    final response = await _supabase
        .from('regions')
        .select()
        .eq('is_active', true)
        .order('ordinal');

    return response
        .map<RegionModel>(
          (json) => RegionModel.fromJson(_mapRegionFromDatabase(json)),
        )
        .toList();
  }

  // Obtener todas las comunas activas
  Future<List<ComunaModel>> getActiveComunas() async {
    final response = await _supabase
        .from('comunas')
        .select()
        .eq('is_active', true)
        .order('name');

    return response
        .map<ComunaModel>(
          (json) => ComunaModel.fromJson(_mapComunaFromDatabase(json)),
        )
        .toList();
  }

  // Obtener comunas por región
  Future<List<ComunaModel>> getComunasByRegion(String regionId) async {
    final response = await _supabase
        .from('comunas')
        .select()
        .eq('region_id', regionId)
        .order('name');

    return response
        .map<ComunaModel>(
          (json) => ComunaModel.fromJson(_mapComunaFromDatabase(json)),
        )
        .toList();
  }

  // Obtener sectores por comuna
  Future<List<SectorModel>> getSectorsByComuna(String comunaId) async {
    final response = await _supabase
        .from('sectors')
        .select()
        .eq('comuna_id', comunaId)
        .order('name');

    return response
        .map<SectorModel>(
          (json) => SectorModel.fromJson(_mapSectorFromDatabase(json)),
        )
        .toList();
  }

  // Obtener detalles de comuna incluyendo estadísticas
  Future<Map<String, dynamic>> getComunaStats(String comunaId) async {
    final response = await _supabase.rpc(
      'get_comuna_stats',
      params: {'comuna_id_param': comunaId},
    );

    return response as Map<String, dynamic>;
  }

  // Obtener ranking de equipos por comuna
  Future<List<dynamic>> getComunaTeamRanking(String comunaId) async {
    final response = await _supabase.rpc(
      'get_comuna_team_ranking',
      params: {'comuna_id_param': comunaId},
    );

    return response as List<dynamic>;
  }
}

// Provider para el servicio de ubicaciones
final locationServiceProvider = Provider<LocationService>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return LocationService(supabase);
});

// Provider para obtener regiones activas
final activeRegionsProvider = FutureProvider<List<RegionModel>>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  return locationService.getActiveRegions();
});

// Provider para obtener comunas activas
final activeComunasProvider = FutureProvider<List<ComunaModel>>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  return locationService.getActiveComunas();
});

// Provider para obtener comunas por región
final comunasByRegionProvider =
    FutureProvider.family<List<ComunaModel>, String>((ref, regionId) async {
      final locationService = ref.watch(locationServiceProvider);
      return locationService.getComunasByRegion(regionId);
    });

// Provider para obtener sectores por comuna
final sectorsByComunaProvider =
    FutureProvider.family<List<SectorModel>, String>((ref, comunaId) async {
      final locationService = ref.watch(locationServiceProvider);
      return locationService.getSectorsByComuna(comunaId);
    });
