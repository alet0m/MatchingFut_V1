import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/models/team_model.dart';

/// Servicio para gestionar los rankings de equipos y territorios
class RankingService {
  final _supabase = Supabase.instance.client;

  /// Obtiene el ranking global de equipos ordenados por league_points (desempate elo)
  Future<List<TeamModel>> getGlobalRankings() async {
    try {
      final response = await _supabase
          .from('teams')
          .select(
            'id,name,tag,captain_id,comuna_id,elo_rating,league_points,league_tier,total_matches,wins,losses,draws,created_at',
          )
          .eq('is_active', true)
          .order('league_points', ascending: false)
          .order('elo_rating', ascending: false)
          .limit(100);
      return response.map<TeamModel>((e) {
        return TeamModel.fromJson({
          'id': e['id'],
          'name': e['name'],
          'tag': e['tag'],
          'captainId': e['captain_id'],
          'comunaId': e['comuna_id'],
          'eloRating': e['elo_rating'],
          'leaguePoints': e['league_points'],
          'leagueTier': e['league_tier'],
          'totalMatches': e['total_matches'],
          'wins': e['wins'],
          'losses': e['losses'],
          'draws': e['draws'],
          'createdAt': e['created_at'],
        });
      }).toList();
    } catch (e) {
      debugPrint('Error obteniendo ranking global: $e');
      return [];
    }
  }

  /// Obtiene el ranking de equipos de una comuna (league_points -> elo)
  Future<List<TeamModel>> getComunaRankings(String comunaId) async {
    try {
      // Preferir nuevo RPC basado en league_points si está creado
      try {
        final json = await _supabase.rpc(
          'get_top_teams_comuna',
          params: {'comuna_id_param': comunaId, 'limit_param': 100},
        );
        if (json is List) {
          return json.map<TeamModel>((e) {
            return TeamModel.fromJson({
              'id': e['id'],
              'name': e['name'],
              'tag': e['tag'],
              'eloRating': e['elo_rating'],
              'leaguePoints': e['league_points'],
              'leagueTier': e['league_tier'],
              'comunaId': comunaId,
            });
          }).toList();
        }
      } catch (_) {
        // Ignorar y usar fallback
      }

      final response = await _supabase
          .from('teams')
          .select(
            'id,name,tag,captain_id,comuna_id,elo_rating,league_points,league_tier,total_matches,wins,losses,draws,created_at',
          )
          .eq('comuna_id', comunaId)
          .eq('is_active', true)
          .order('league_points', ascending: false)
          .order('elo_rating', ascending: false)
          .limit(100);
      return response.map<TeamModel>((e) {
        return TeamModel.fromJson({
          'id': e['id'],
          'name': e['name'],
          'tag': e['tag'],
          'captainId': e['captain_id'],
          'comunaId': e['comuna_id'],
          'eloRating': e['elo_rating'],
          'leaguePoints': e['league_points'],
          'leagueTier': e['league_tier'],
          'totalMatches': e['total_matches'],
          'wins': e['wins'],
          'losses': e['losses'],
          'draws': e['draws'],
          'createdAt': e['created_at'],
        });
      }).toList();
    } catch (e) {
      debugPrint('Error obteniendo ranking de comuna: $e');
      return [];
    }
  }

  /// Obtiene los equipos que controlan sectores en una comuna
  Future<List<TeamModel>> getSectorControllers(String comunaId) async {
    try {
      // 1) Obtener los sectores de la comuna
      final sectors = await _supabase
          .from('sectors')
          .select('id')
          .eq('comuna_id', comunaId)
          .eq('is_active', true);

      if (sectors.isEmpty) return [];
      final sectorIds = sectors.map<String>((s) => s['id'] as String).toList();

      // 2) Buscar historial de control para esos sectores (equipos recientes)
      final history = await _supabase
          .from('sector_control_history')
          .select('team_id, teams(*)')
          .inFilter('sector_id', sectorIds)
          .order('control_start', ascending: false)
          .limit(200);

      final Map<String, TeamModel> uniqueTeams = {};
      for (final row in history) {
        final team = TeamModel.fromJson(row['teams'] as Map<String, dynamic>);
        uniqueTeams[team.id] = team;
      }

      return uniqueTeams.values.toList();
    } catch (e) {
      debugPrint('Error obteniendo controladores de sectores: $e');
      return [];
    }
  }

  /// Obtiene el historial de ELO de un equipo para gráficos
  Future<List<Map<String, dynamic>>> getTeamEloHistory(String teamId) async {
    try {
      // Preferir función SQL canónica
      try {
        final json = await _supabase.rpc(
          'get_team_elo_history',
          params: {'team_id_param': teamId},
        );
        if (json is List) {
          return List<Map<String, dynamic>>.from(json);
        }
      } catch (e) {
        debugPrint('Función get_team_elo_history no disponible: $e');
      }

      // Fallback directo a tabla team_elo_history (estructura simplificada)
      final response = await _supabase
          .from('team_elo_history')
          .select('recorded_at, previous_elo, new_elo, change, match_id')
          .eq('team_id', teamId)
          .order('recorded_at', ascending: true)
          .limit(50);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error obteniendo historial de ELO: $e');
      return [];
    }
  }

  /// Obtiene estadísticas de territorio para un equipo
  Future<Map<String, dynamic>> getTeamTerritorialStats(String teamId) async {
    try {
      final response = await _supabase.rpc(
        'get_team_territorial_stats',
        params: {'team_id_param': teamId},
      );

      return Map<String, dynamic>.from(response);
    } catch (e) {
      debugPrint('Error obteniendo estadísticas territoriales: $e');
      return {};
    }
  }

  /// Métricas globales: total equipos activos y promedio ELO top 10
  Future<Map<String, dynamic>> getGlobalSummaryMetrics() async {
    try {
      final teamsRes = await _supabase
          .from('teams')
          .select('elo_rating')
          .eq('is_active', true)
          .order('elo_rating', ascending: false)
          .limit(10);
      // Obtener total de equipos activos (conteo por segunda consulta ligera)
      final totalActiveRes = await _supabase
          .from('teams')
          .select('id')
          .eq('is_active', true);

      final top10 =
          teamsRes.map((e) => (e['elo_rating'] as num?)?.toInt() ?? 0).toList();
      final avgTop10 =
          top10.isEmpty
              ? 0
              : (top10.reduce((a, b) => a + b) / top10.length).round();
      final totalActive = totalActiveRes.length;

      return {'total_active_teams': totalActive, 'avg_top10_elo': avgTop10};
    } catch (e) {
      debugPrint('Error métricas globales: $e');
      return {'total_active_teams': 0, 'avg_top10_elo': 0};
    }
  }

  /// Sectores más disputados en una comuna (RPC get_hottest_sectors)
  Future<List<Map<String, dynamic>>> getHottestSectors(
    String comunaId, {
    int limit = 5,
  }) async {
    try {
      final json = await _supabase.rpc(
        'get_hottest_sectors',
        params: {'comuna_id_param': comunaId, 'limit_param': limit},
      );
      if (json is List) {
        return List<Map<String, dynamic>>.from(json);
      }
      return [];
    } catch (e) {
      debugPrint(
        'Error obteniendo hottest sectors (RPC falló, usando fallback): $e',
      );
      // Fallback directo vía tablas
      try {
        final sectorsRes = await _supabase
            .from('sectors')
            .select(
              'id,name,description,total_matches,last_match_date,controlling_team_id,current_elo_threshold,featured_image_url',
            )
            .eq('comuna_id', comunaId)
            .eq('is_active', true)
            .order('total_matches', ascending: false)
            .limit(limit);

        if (sectorsRes.isEmpty) return [];

        final controllerIds =
            sectorsRes
                .map((s) => s['controlling_team_id'])
                .where((id) => id != null)
                .cast<String>()
                .toSet()
                .toList();

        Map<String, dynamic> teamsMap = {};
        if (controllerIds.isNotEmpty) {
          final teamsRes = await _supabase
              .from('teams')
              .select('id,name,tag,elo_rating')
              .inFilter('id', controllerIds);
          for (final t in teamsRes) {
            teamsMap[t['id'] as String] = t;
          }
        }

        final sectorIds = sectorsRes.map((s) => s['id'] as String).toList();
        final historyRes = await _supabase
            .from('sector_control_history')
            .select('sector_id')
            .inFilter('sector_id', sectorIds);
        final Map<String, int> controlChangesMap = {};
        for (final row in historyRes) {
          final sid = row['sector_id'] as String?;
          if (sid == null) continue;
          controlChangesMap[sid] = (controlChangesMap[sid] ?? 0) + 1;
        }

        return sectorsRes.map<Map<String, dynamic>>((s) {
          final controllerId = s['controlling_team_id'] as String?;
          final controllingTeam =
              controllerId != null ? teamsMap[controllerId] : null;
          return {
            'id': s['id'],
            'name': s['name'],
            'description': s['description'],
            'total_matches': s['total_matches'],
            'last_match_date': s['last_match_date'],
            'controlling_team': controllingTeam,
            'control_changes': controlChangesMap[s['id']] ?? 0,
            'elo_threshold': s['current_elo_threshold'],
            'featured_image_url': s['featured_image_url'],
          };
        }).toList();
      } catch (fallbackError) {
        debugPrint('Fallback sectores falló: $fallbackError');
        return [];
      }
    }
  }

  // ================= NUEVO: Ranking por región =================
  /// Top 100 equipos por región (league_points -> elo)
  Future<List<TeamModel>> getRegionTeamsRanking(
    String regionId, {
    int limit = 100,
  }) async {
    try {
      final comunasRes = await _supabase
          .from('comunas')
          .select('id')
          .eq('region_id', regionId)
          .eq('is_active', true);
      final comunaIds = comunasRes.map((e) => e['id'] as String).toList();
      if (comunaIds.isEmpty) return [];
      final teamsRes = await _supabase
          .from('teams')
          .select(
            'id,name,tag,captain_id,comuna_id,elo_rating,league_points,league_tier,total_matches,wins,losses,draws,created_at',
          )
          .inFilter('comuna_id', comunaIds)
          .eq('is_active', true)
          .order('league_points', ascending: false)
          .order('elo_rating', ascending: false)
          .limit(limit);
      return teamsRes.map<TeamModel>((e) {
        return TeamModel.fromJson({
          'id': e['id'],
          'name': e['name'],
          'tag': e['tag'],
          'captainId': e['captain_id'],
          'comunaId': e['comuna_id'],
          'eloRating': e['elo_rating'],
          'leaguePoints': e['league_points'],
          'leagueTier': e['league_tier'],
          'totalMatches': e['total_matches'],
          'wins': e['wins'],
          'losses': e['losses'],
          'draws': e['draws'],
          'createdAt': e['created_at'],
        });
      }).toList();
    } catch (e) {
      debugPrint('Error ranking equipos región: $e');
      return [];
    }
  }

  /// Rank del equipo del usuario (por captain_id) en región
  Future<int?> getUserTeamRankInRegion(String userId, String regionId) async {
    try {
      final teamRes = await _supabase
          .from('teams')
          .select('id,elo_rating,comuna_id')
          .eq('captain_id', userId)
          .eq('is_active', true)
          .limit(1);
      if (teamRes.isEmpty) return null;
      final teamElo = teamRes.first['elo_rating'] as int? ?? 1200;
      final comunasRes = await _supabase
          .from('comunas')
          .select('id')
          .eq('region_id', regionId)
          .eq('is_active', true);
      final comunaIds = comunasRes.map((e) => e['id'] as String).toList();
      if (comunaIds.isEmpty) return null;
      final higherRes = await _supabase
          .from('teams')
          .select('id')
          .inFilter('comuna_id', comunaIds)
          .eq('is_active', true)
          .gt('elo_rating', teamElo);
      return higherRes.length + 1;
    } catch (e) {
      debugPrint('Error rank equipo usuario región: $e');
      return null;
    }
  }

  /// Top 100 jugadores por región
  Future<List<Map<String, dynamic>>> getRegionPlayersRanking(
    String regionId, {
    int limit = 100,
  }) async {
    try {
      // 1) Comunas activas de la región (usamos nombres para cruzar con profiles.comuna)
      final comunasNameRes = await _supabase
          .from('comunas')
          .select('name')
          .eq('region_id', regionId)
          .eq('is_active', true);
      final comunaNames =
          comunasNameRes
              .map((e) => (e['name'] as String?)?.trim())
              .whereType<String>()
              .where((n) => n.isNotEmpty)
              .toList();
      if (comunaNames.isEmpty) return [];

      // 2) Perfiles activos en esas comunas
      final profilesInRegion = await _supabase
          .from('profiles')
          .select('id,full_name,tag')
          .inFilter('comuna', comunaNames)
          .eq('is_active', true);
      List<String> playerIds =
          profilesInRegion.map((p) => p['id'] as String).toList();
      // Fallback: si no hay perfiles, usar miembros de equipos de la región
      if (playerIds.isEmpty) {
        final comunasRes = await _supabase
            .from('comunas')
            .select('id')
            .eq('region_id', regionId)
            .eq('is_active', true);
        final comunaIds = comunasRes.map((e) => e['id'] as String).toList();
        if (comunaIds.isEmpty) return [];
        final teamsRes = await _supabase
            .from('teams')
            .select('id')
            .inFilter('comuna_id', comunaIds)
            .eq('is_active', true);
        final teamIds = teamsRes.map((e) => e['id'] as String).toList();
        if (teamIds.isNotEmpty) {
          final membersRes = await _supabase
              .from('team_members')
              .select('player_id')
              .inFilter('team_id', teamIds)
              .eq('is_active', true);
          playerIds =
              membersRes
                  .map((m) => m['player_id'] as String?)
                  .where((id) => id != null)
                  .cast<String>()
                  .toSet()
                  .toList();
          if (playerIds.isEmpty) return [];
          // También traer perfiles de esos ids para nombres
          final profilesRes = await _supabase
              .from('profiles')
              .select('id,full_name,tag')
              .inFilter('id', playerIds);
          profilesInRegion.clear();
          profilesInRegion.addAll(profilesRes);
        } else {
          return [];
        }
      }

      // 3) Jugadores ordenados por LP -> ELO
      final playersRes = await _supabase
          .from('players')
          .select('id,elo_rating,league_points,league_tier')
          .inFilter('id', playerIds)
          .order('league_points', ascending: false)
          .order('elo_rating', ascending: false)
          .limit(limit);
      if (playersRes.isEmpty) return [];

      // 4) Mapa id->perfil
      final Map<String, Map<String, dynamic>> profilesMap = {
        for (final p in profilesInRegion) p['id'] as String: p,
      };

      // 5) Construir resultado unificado
      return playersRes.map<Map<String, dynamic>>((pl) {
        final pid = pl['id'] as String;
        final profile = profilesMap[pid];
        return {
          'id': pid,
          'name':
              profile != null
                  ? (profile['full_name'] ?? profile['tag'] ?? 'Jugador')
                  : 'Jugador',
          'elo': pl['elo_rating'] ?? 1200,
          'leaguePoints': pl['league_points'] ?? 100,
          'leagueTier': pl['league_tier'],
        };
      }).toList();
    } catch (e) {
      debugPrint('Error ranking jugadores región: $e');
      return [];
    }
  }

  /// Rank personal del jugador en región
  Future<int?> getUserPlayerRankInRegion(String userId, String regionId) async {
    try {
      // Obtener LP y ELO desde tabla players
      int elo = 1200;
      int lp = 100;
      final playerStats = await _supabase
          .from('players')
          .select('elo_rating,league_points')
          .eq('id', userId)
          .limit(1);
      if (playerStats.isNotEmpty) {
        elo = (playerStats.first['elo_rating'] as int?) ?? 1200;
        lp = (playerStats.first['league_points'] as int?) ?? 100;
      }
      // Ranking regional basado en profiles.comuna
      final comunasNameRes = await _supabase
          .from('comunas')
          .select('name')
          .eq('region_id', regionId)
          .eq('is_active', true);
      final comunaNames =
          comunasNameRes
              .map((e) => (e['name'] as String?)?.trim())
              .whereType<String>()
              .where((n) => n.isNotEmpty)
              .toList();
      if (comunaNames.isEmpty) return null;
      final profilesRes = await _supabase
          .from('profiles')
          .select('id')
          .inFilter('comuna', comunaNames)
          .eq('is_active', true);
      final playerIds = profilesRes.map((p) => p['id'] as String).toList();
      if (playerIds.isEmpty) return null;
      final higherLp = await _supabase
          .from('players')
          .select('id')
          .inFilter('id', playerIds)
          .gt('league_points', lp);
      final tieHigherElo = await _supabase
          .from('players')
          .select('id')
          .inFilter('id', playerIds)
          .eq('league_points', lp)
          .gt('elo_rating', elo);
      return higherLp.length + tieHigherElo.length + 1;
    } catch (e) {
      debugPrint('Error rank jugador usuario región: $e');
      return null;
    }
  }

  /// Ranking global de jugadores.
  /// Si [limit] es null, retorna TODOS los jugadores (cuidado con performance).
  /// Orden: league_points DESC, elo_rating DESC.
  Future<List<Map<String, dynamic>>> getGlobalPlayersRanking({
    int? limit = 100,
  }) async {
    try {
      // 1) Traer todos los perfiles activos (para asegurar inclusión total)
      final allProfilesRes = await _supabase
          .from('profiles')
          .select('id,full_name,tag,is_active')
          .eq('is_active', true);
      if (allProfilesRes.isEmpty) return [];
      final allProfileIds =
          allProfilesRes.map((p) => p['id'] as String).toList();

      // 2) Traer filas existentes en players para esos perfiles
      final playersRes = await _supabase
          .from('players')
          .select('id,elo_rating,league_points,league_tier')
          .inFilter('id', allProfileIds);
      final Map<String, Map<String, dynamic>> playersMap = {
        for (final pl in playersRes) pl['id'] as String: pl,
      };

      // 3) Construir lista combinada (si falta player -> valores por defecto)
      final List<Map<String, dynamic>> combined = [];
      for (final profile in allProfilesRes) {
        final pid = profile['id'] as String;
        final player = playersMap[pid];
        final lp = (player?['league_points'] as int?) ?? 100;
        final elo = (player?['elo_rating'] as int?) ?? 1200;
        combined.add({
          'id': pid,
          'name':
              (profile['full_name'] ?? profile['tag'] ?? 'Jugador') as String,
          'elo': elo,
          'leaguePoints': lp,
          'leagueTier': player?['league_tier'],
        });
      }

      // 4) Ordenar (league_points DESC, elo DESC)
      combined.sort((a, b) {
        final lpA = a['leaguePoints'] as int? ?? 0;
        final lpB = b['leaguePoints'] as int? ?? 0;
        if (lpA != lpB) return lpB.compareTo(lpA);
        final eloA = a['elo'] as int? ?? 0;
        final eloB = b['elo'] as int? ?? 0;
        return eloB.compareTo(eloA);
      });

      // 5) Aplicar límite si corresponde
      if (limit != null && combined.length > limit) {
        return combined.sublist(0, limit);
      }
      return combined;
      // Método getComunaPlayersRanking fue movido correctamente más abajo.
    } catch (e) {
      debugPrint('Error ranking jugadores comuna: $e');
      return [];
    }
  }

  /// Top jugadores por comuna (incluye todos los perfiles en esa comuna)
  Future<List<Map<String, dynamic>>> getComunaPlayersRanking(
    String comunaId, {
    int limit = 100,
  }) async {
    try {
      // 1) Nombre de la comuna
      final comunaRow = await _supabase
          .from('comunas')
          .select('name')
          .eq('id', comunaId)
          .eq('is_active', true)
          .limit(1);
      if (comunaRow.isEmpty) return [];
      final comunaName = (comunaRow.first['name'] as String?)?.trim();
      if (comunaName == null || comunaName.isEmpty) return [];

      // 2) Perfiles activos en esa comuna
      final profilesInComuna = await _supabase
          .from('profiles')
          .select('id,full_name,tag')
          .eq('comuna', comunaName)
          .eq('is_active', true);
      List<String> playerIds =
          profilesInComuna.map((p) => p['id'] as String).toList();
      // Fallback: si no hay perfiles en profiles, usar miembros de equipos de la comuna
      if (playerIds.isEmpty) {
        final teamsRes = await _supabase
            .from('teams')
            .select('id')
            .eq('comuna_id', comunaId)
            .eq('is_active', true);
        final teamIds = teamsRes.map((e) => e['id'] as String).toList();
        if (teamIds.isNotEmpty) {
          final membersRes = await _supabase
              .from('team_members')
              .select('player_id')
              .inFilter('team_id', teamIds)
              .eq('is_active', true);
          playerIds =
              membersRes
                  .map((m) => m['player_id'] as String?)
                  .where((id) => id != null)
                  .cast<String>()
                  .toSet()
                  .toList();
          if (playerIds.isEmpty) return [];
          // Y traer perfiles para nombres
          final profilesRes = await _supabase
              .from('profiles')
              .select('id,full_name,tag')
              .inFilter('id', playerIds);
          profilesInComuna.clear();
          profilesInComuna.addAll(profilesRes);
        } else {
          return [];
        }
      }

      // 3) Jugadores ordenados por LP -> ELO
      final playersRes = await _supabase
          .from('players')
          .select('id,elo_rating,league_points,league_tier')
          .inFilter('id', playerIds)
          .order('league_points', ascending: false)
          .order('elo_rating', ascending: false)
          .limit(limit);
      if (playersRes.isEmpty) return [];

      // 4) Mapa id->perfil
      final Map<String, Map<String, dynamic>> profilesMap = {
        for (final p in profilesInComuna) p['id'] as String: p,
      };

      // 5) Construir resultado
      return playersRes.map<Map<String, dynamic>>((pl) {
        final pid = pl['id'] as String;
        final profile = profilesMap[pid];
        return {
          'id': pid,
          'name':
              profile != null
                  ? (profile['full_name'] ?? profile['tag'] ?? 'Jugador')
                  : 'Jugador',
          'elo': pl['elo_rating'] ?? 1200,
          'leaguePoints': pl['league_points'] ?? 100,
          'leagueTier': pl['league_tier'],
        };
      }).toList();
    } catch (e) {
      debugPrint('Error ranking jugadores comuna: $e');
      return [];
    }
  }

  /// Rank personal del jugador en una comuna
  Future<int?> getUserPlayerRankInComuna(String userId, String comunaId) async {
    try {
      // LP y ELO del usuario
      int elo = 1200;
      int lp = 100;
      final playerStats = await _supabase
          .from('players')
          .select('elo_rating,league_points')
          .eq('id', userId)
          .limit(1);
      if (playerStats.isNotEmpty) {
        elo = (playerStats.first['elo_rating'] as int?) ?? 1200;
        lp = (playerStats.first['league_points'] as int?) ?? 100;
      }

      // Nombre de la comuna
      final comunaRow = await _supabase
          .from('comunas')
          .select('name')
          .eq('id', comunaId)
          .eq('is_active', true)
          .limit(1);
      if (comunaRow.isEmpty) return null;
      final comunaName = (comunaRow.first['name'] as String?)?.trim();
      if (comunaName == null || comunaName.isEmpty) return null;

      // Conjunto de jugadores de esa comuna (perfiles)
      final profilesRes = await _supabase
          .from('profiles')
          .select('id')
          .eq('comuna', comunaName)
          .eq('is_active', true);
      final playerIds = profilesRes.map((p) => p['id'] as String).toList();
      if (playerIds.isEmpty) return null;

      final higherLp = await _supabase
          .from('players')
          .select('id')
          .inFilter('id', playerIds)
          .gt('league_points', lp);
      final tieHigherElo = await _supabase
          .from('players')
          .select('id')
          .inFilter('id', playerIds)
          .eq('league_points', lp)
          .gt('elo_rating', elo);
      return higherLp.length + tieHigherElo.length + 1;
    } catch (e) {
      debugPrint('Error rank jugador comuna: $e');
      return null;
    }
  }

  /// Rank del equipo del usuario (capitán) dentro de una comuna, usando LP->ELO
  Future<int?> getUserTeamRankInComuna(String userId, String comunaId) async {
    try {
      final teamRes = await _supabase
          .from('teams')
          .select('id,league_points,elo_rating')
          .eq('captain_id', userId)
          .eq('comuna_id', comunaId)
          .eq('is_active', true)
          .limit(1);
      if (teamRes.isEmpty) return null;
      final lp = (teamRes.first['league_points'] as int?) ?? 0;
      final elo = (teamRes.first['elo_rating'] as int?) ?? 1200;

      final higherLp = await _supabase
          .from('teams')
          .select('id')
          .eq('comuna_id', comunaId)
          .eq('is_active', true)
          .gt('league_points', lp);
      final tieHigherElo = await _supabase
          .from('teams')
          .select('id')
          .eq('comuna_id', comunaId)
          .eq('is_active', true)
          .eq('league_points', lp)
          .gt('elo_rating', elo);
      return higherLp.length + tieHigherElo.length + 1;
    } catch (e) {
      debugPrint('Error rank equipo comuna: $e');
      return null;
    }
  }
}
