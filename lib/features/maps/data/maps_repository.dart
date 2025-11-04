import '../models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositorio abstracto para datos del mapa
abstract class MapsRepository {
  Future<List<Cancha>> fetchCanchas({
    required String region,
    required String comuna,
  });

  Future<List<EquipoRank>> fetchRanking({
    required String region,
    required String comuna,
  });
}

/// Implementación mock con datos de ejemplo
class MapsRepositoryMock implements MapsRepository {
  @override
  Future<List<Cancha>> fetchCanchas({
    required String region,
    required String comuna,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    // Datos mock que varían según la comuna
    final canchas = <Cancha>[
      Cancha(
        id: '1',
        nombre: 'Cancha Municipal $comuna',
        fotoUrl: null, // Simula cancha sin foto
        comuna: comuna,
      ),
      Cancha(
        id: '2',
        nombre: 'Club $comuna',
        fotoUrl: 'https://picsum.photos/200',
        comuna: comuna,
      ),
      Cancha(
        id: '3',
        nombre: 'Estadio Norte',
        fotoUrl: 'https://picsum.photos/201',
        comuna: comuna,
      ),
    ];

    // Simular diferente cantidad según comuna
    if (comuna.toLowerCase().contains('quilicura')) {
      return canchas;
    } else if (comuna.toLowerCase().contains('santiago')) {
      return canchas.take(2).toList();
    } else {
      return [canchas.first]; // Solo una cancha para otras comunas
    }
  }

  @override
  Future<List<EquipoRank>> fetchRanking({
    required String region,
    required String comuna,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    // Datos mock que varían según la comuna
    final baseRanking = <EquipoRank>[
      EquipoRank(id: 'a', nombre: '$comuna FC', puntos: 27, comuna: comuna),
      EquipoRank(id: 'b', nombre: 'Atlético Norte', puntos: 23, comuna: comuna),
      EquipoRank(id: 'c', nombre: 'Deportivo Río', puntos: 19, comuna: comuna),
      EquipoRank(id: 'd', nombre: 'Club $comuna', puntos: 15, comuna: comuna),
      EquipoRank(id: 'e', nombre: 'Unión $comuna', puntos: 12, comuna: comuna),
    ];

    // Simular diferente cantidad según comuna
    if (comuna.toLowerCase().contains('quilicura')) {
      return baseRanking;
    } else if (comuna.toLowerCase().contains('santiago')) {
      return baseRanking.take(3).toList();
    } else {
      return baseRanking.take(2).toList();
    }
  }
}

/// Implementación real (placeholder para futuro)
class MapsRepositoryReal implements MapsRepository {
  final SupabaseClient _supabase;

  MapsRepositoryReal(this._supabase);

  @override
  Future<List<Cancha>> fetchCanchas({
    required String region,
    required String comuna,
  }) async {
    // Aún no hay canchas cargadas en BD para este flujo.
    // Devolvemos lista vacía (estado vacío en UI), sin datos falsos.
    return const <Cancha>[];
  }

  @override
  Future<List<EquipoRank>> fetchRanking({
    required String region,
    required String comuna,
  }) async {
    // Permitir modo Global (sin filtros) o por Comuna/Región

    // 1) Resolver filtros de región/comuna a IDs (de ser posible)
    String comunaId = '';
    int? regionId;

    final comunaTrim = comuna.trim();
    final regionTrim = region.trim();

    try {
      if (regionTrim.isNotEmpty) {
        final r =
            await _supabase
                .from('regions')
                .select('id')
                .ilike('name', regionTrim)
                .maybeSingle();
        if (r != null) regionId = (r['id'] as num).toInt();
      }

      if (comunaTrim.isNotEmpty) {
        final cQuery = _supabase.from('comunas').select('id,name');
        final c =
            regionId != null
                ? await cQuery
                    .eq('region_id', regionId)
                    .ilike('name', comunaTrim)
                    .maybeSingle()
                : await cQuery.ilike('name', comunaTrim).maybeSingle();
        if (c != null) comunaId = (c['id'] ?? '').toString();
      }
    } catch (_) {
      // Ignorar errores de resolución de nombres; seguiremos con filtros disponibles
    }

    // 2) Construir consulta de equipos según filtros (global si no hay filtros válidos)
    var query = _supabase.from('teams').select('id,name,elo_rating,comuna_id');
    query = query.eq('is_active', true);

    if (comunaId.isNotEmpty) {
      query = query.eq('comuna_id', comunaId);
    } else if (regionId != null) {
      // Filtrar por todas las comunas de la región
      try {
        final comunas = await _supabase
            .from('comunas')
            .select('id')
            .eq('region_id', regionId);
        final ids =
            (comunas as List)
                .map((e) => (e['id'] ?? '').toString())
                .where((id) => id.isNotEmpty)
                .toList();
        if (ids.isNotEmpty) {
          query = query.inFilter('comuna_id', ids);
        }
      } catch (_) {
        // Si falla la resolución de región, caer en ranking global (sin filtro adicional)
      }
    } else {
      // Sin comuna ni región: ranking global
    }

    final List rows = await query.order('elo_rating', ascending: false);
    if (rows.isEmpty) return const <EquipoRank>[];

    // 3) Mapear a modelo de ranking (puntos = elo_rating)
    final List<EquipoRank> ranking = [];
    for (final row in rows) {
      final name = (row['name'] ?? '').toString();
      if (name.isEmpty) continue; // Ignorar filas inconsistentes
      final puntos = (row['elo_rating'] as num?)?.toInt() ?? 0;
      final comunaName = comunaTrim.isNotEmpty ? comunaTrim : '';
      ranking.add(
        EquipoRank(
          id: (row['id'] ?? '').toString(),
          nombre: name,
          puntos: puntos,
          comuna: comunaName,
        ),
      );
    }

    return ranking;
  }
}
