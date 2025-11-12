import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/match_model.dart';

class MatchesServiceEnhanced {
  static final SupabaseClient supabase = Supabase.instance.client;

  // Crear partido público (queda listado y otro equipo puede aceptarlo)
  Future<String> createPublicMatch({
    required String hostTeamId,
    required DateTime scheduledDate,
    required String location,
    String matchType = 'futbolito',
    String? description,
  }) async {
    print('🏆 Creando partido público para equipo $hostTeamId');

    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Usuario no autenticado');
    }

    // Intento A: esquema base (home_team_id/match_date/modality_type)
    try {
      final matchDataA = <String, dynamic>{
        'home_team_id': hostTeamId,
        'match_date': scheduledDate.toIso8601String(),
        'location': location,
        'modality_type': matchType,
        'is_public': true,
        'status': 'scheduled',
        'created_by': currentUser.id,
      };

      final responseA =
          await supabase.from('matches').insert(matchDataA).select().single();
      final matchIdA = responseA['id'];
      print('✅ Partido público (A) creado con ID: $matchIdA');
      return matchIdA;
    } catch (e) {
      print('ℹ️ Intento A falló, probando esquema alternativo B: $e');
      // Intento B: esquema alternativo mejorado (host_team_id/scheduled_date/match_type + nombres)
      // Buscar nombre del equipo host
      final hostTeamRow =
          await supabase
              .from('teams')
              .select('name')
              .eq('id', hostTeamId)
              .maybeSingle();
      final hostTeamName = (hostTeamRow?['name'] as String?) ?? 'Equipo';

      final matchDataB = <String, dynamic>{
        'host_team_id': hostTeamId,
        'host_team_name': hostTeamName,
        'scheduled_date': scheduledDate.toIso8601String(),
        'location': location,
        'match_type': matchType,
        'is_public': true,
        'status': 'pending',
        'created_by': currentUser.id,
      };

      final responseB =
          await supabase.from('matches').insert(matchDataB).select().single();
      final matchIdB = responseB['id'];
      print('✅ Partido público (B) creado con ID: $matchIdB');
      return matchIdB;
    }
  }

  // Crear partido privado (desafío directo ya con equipo invitado)
  Future<String> createPrivateMatch({
    required String hostTeamId,
    required String guestTeamId,
    required DateTime scheduledDate,
    required String location,
    String matchType = 'futbolito',
    String? description,
  }) async {
    print('🏆 Creando partido privado: $hostTeamId vs $guestTeamId');

    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Usuario no autenticado');
    }

    // Intento A: esquema base
    try {
      final matchDataA = <String, dynamic>{
        'home_team_id': hostTeamId,
        'away_team_id': guestTeamId,
        'match_date': scheduledDate.toIso8601String(),
        'location': location,
        'modality_type': matchType,
        'is_public': false,
        'status': 'scheduled',
        'created_by': currentUser.id,
      };
      final responseA =
          await supabase.from('matches').insert(matchDataA).select().single();
      final matchIdA = responseA['id'];
      print('✅ Partido privado (A) creado con ID: $matchIdA');
      return matchIdA;
    } catch (e) {
      print('ℹ️ Intento A falló, probando esquema alternativo B: $e');

      // Intento B: esquema alternativo mejorado (con nombres)
      final hostTeamRow =
          await supabase
              .from('teams')
              .select('name')
              .eq('id', hostTeamId)
              .maybeSingle();
      final guestTeamRow =
          await supabase
              .from('teams')
              .select('name')
              .eq('id', guestTeamId)
              .maybeSingle();
      final hostTeamName = (hostTeamRow?['name'] as String?) ?? 'Local';
      final guestTeamName = (guestTeamRow?['name'] as String?) ?? 'Visitante';

      final matchDataB = <String, dynamic>{
        'host_team_id': hostTeamId,
        'host_team_name': hostTeamName,
        'guest_team_id': guestTeamId,
        'guest_team_name': guestTeamName,
        'scheduled_date': scheduledDate.toIso8601String(),
        'location': location,
        'match_type': matchType,
        'is_public': false,
        'status': 'confirmed',
        'created_by': currentUser.id,
      };

      final responseB =
          await supabase.from('matches').insert(matchDataB).select().single();
      final matchIdB = responseB['id'];
      print('✅ Partido privado (B) creado con ID: $matchIdB');
      return matchIdB;
    }
  }

  // Aceptar/unirse a un partido público como equipo visitante
  Future<void> joinPublicMatch(String matchId) async {
    print('⚽ Uniéndose al partido público $matchId');

    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Usuario no autenticado');
    }

    // Obtener el equipo del usuario
    final userTeams = await supabase
        .from('team_members')
        .select('team_id')
        .eq('player_id', currentUser.id)
        .eq('is_active', true);

    if (userTeams.isEmpty) {
      throw Exception('No tienes equipos activos');
    }

    final teamId = userTeams.first['team_id'];

    // Verificar que el partido existe y está disponible
    final match =
        await supabase
            .from('matches')
            .select('*')
            .eq('id', matchId)
            .eq('is_public', true)
            .eq('status', 'scheduled')
            .isFilter('away_team_id', null)
            .maybeSingle();

    if (match == null) {
      throw Exception('Partido no disponible');
    }

    if (match['home_team_id'] == teamId) {
      throw Exception('No puedes unirte a tu propio partido');
    }

    await supabase
        .from('matches')
        .update({'away_team_id': teamId})
        .eq('id', matchId);

    print('✅ Te has unido al partido exitosamente');
  }

  // Iniciar partido
  Future<void> startMatch(String matchId) async {
    print('🚀 Iniciando partido $matchId');

    // Actualizamos solo el status; triggers se encargan de updated_at si existe
    await supabase
        .from('matches')
        .update({'status': 'active'})
        .eq('id', matchId);

    print('✅ Partido iniciado');
  }

  // Finalizar partido (aplica ELO simple y control territorial si corresponde)
  Future<void> finishMatch(
    String matchId,
    int hostScore,
    int guestScore,
  ) async {
    print('🏁 Finalizando partido $matchId');

    // 1) Actualizar resultado y ganador
    final match =
        await supabase
            .from('matches')
            .select('home_team_id, away_team_id, sector_id')
            .eq('id', matchId)
            .single();

    final String homeId = (match['home_team_id'] ?? '').toString();
    final String awayId = (match['away_team_id'] ?? '').toString();

    String? winnerId;
    if (hostScore > guestScore) winnerId = homeId;
    if (guestScore > hostScore) winnerId = awayId;

    final finishData = <String, dynamic>{
      'status': 'finished',
      // soportar ambos esquemas de columnas de score
      'home_score': hostScore,
      'away_score': guestScore,
      'score_host': hostScore,
      'score_guest': guestScore,
    };

    // Intentar actualizar con columnas modernas primero; si falla, intentar con legacy
    try {
      await supabase.from('matches').update(finishData).eq('id', matchId);
    } catch (_) {
      await supabase
          .from('matches')
          .update({'status': 'finished'})
          .eq('id', matchId);
    }

    // 2) ELO simple: +10 al ganador, -10 al perdedor, 0 en empate
    if (winnerId != null) {
      final loserId = winnerId == homeId ? awayId : homeId;

      if (loserId.isNotEmpty) {
        try {
          final winnerRow =
              await supabase
                  .from('teams')
                  .select('elo_rating')
                  .eq('id', winnerId)
                  .single();
          final loserRow =
              await supabase
                  .from('teams')
                  .select('elo_rating')
                  .eq('id', loserId)
                  .single();

          final int winnerElo =
              (winnerRow['elo_rating'] as num?)?.toInt() ?? 1200;
          final int loserElo =
              (loserRow['elo_rating'] as num?)?.toInt() ?? 1200;

          final int newWinner = winnerElo + 10;
          final int newLoser = (loserElo - 10);

          await supabase
              .from('teams')
              .update({'elo_rating': newWinner})
              .eq('id', winnerId);
          await supabase
              .from('teams')
              .update({'elo_rating': newLoser})
              .eq('id', loserId);

          // Historial
          await supabase.from('team_elo_history').insert({
            'team_id': winnerId,
            'match_id': matchId,
            'previous_elo': winnerElo,
            'new_elo': newWinner,
            'change': (newWinner - winnerElo),
          });
          await supabase.from('team_elo_history').insert({
            'team_id': loserId,
            'match_id': matchId,
            'previous_elo': loserElo,
            'new_elo': newLoser,
            'change': (newLoser - loserElo),
          });
        } catch (_) {}
      }
    }

    // 3) Control territorial: si el match está asociado a un sector
    final String sectorId = (match['sector_id'] ?? '').toString();
    if (sectorId.isNotEmpty && winnerId != null) {
      try {
        final sector =
            await supabase
                .from('sectors')
                .select('controlling_team_id')
                .eq('id', sectorId)
                .single();
        final String? currentController =
            sector['controlling_team_id'] as String?;
        if (currentController != winnerId) {
          final nowIso = DateTime.now().toIso8601String();
          // Cerrar control previo si existe
          final prev =
              await supabase
                  .from('sector_control_history')
                  .select('id, control_start')
                  .eq('sector_id', sectorId)
                  .isFilter('control_end', null)
                  .maybeSingle();
          if (prev != null) {
            final startStr = prev['control_start'] as String?;
            int? totalDays;
            if (startStr != null) {
              final start = DateTime.tryParse(startStr);
              if (start != null) {
                totalDays = DateTime.now().difference(start).inDays;
              }
            }
            await supabase
                .from('sector_control_history')
                .update({
                  'control_end': nowIso,
                  'total_days': totalDays,
                  'loss_match_id': matchId,
                })
                .eq('id', prev['id']);
          }
          // Insertar nuevo control
          await supabase.from('sector_control_history').insert({
            'sector_id': sectorId,
            'team_id': winnerId,
            'control_start': nowIso,
            'match_id': matchId,
          });
          // Actualizar sector
          await supabase
              .from('sectors')
              .update({
                'controlling_team_id': winnerId,
                'control_start_date': nowIso,
                'last_match_date': nowIso,
              })
              .eq('id', sectorId);
        }
      } catch (_) {}
    }

    print('✅ Partido finalizado');
  }

  // Obtener partidos públicos (en matches con is_public y sin rival)
  Future<List<MatchModel>> getPublicMatches() async {
    try {
      // Equipos del usuario para excluir partidos donde es anfitrión
      final userId = supabase.auth.currentUser?.id;
      final userTeams =
          userId == null
              ? <dynamic>[]
              : await supabase
                  .from('team_members')
                  .select('team_id')
                  .eq('player_id', userId)
                  .eq('is_active', true);
      final hostTeamIds = userTeams.map((t) => t['team_id']).toSet();

      dynamic response;
      // Intento A: columnas base (away_team_id + match_date + is_public)
      try {
        response = await supabase
            .from('matches')
            .select('*')
            .eq('is_public', true)
            .isFilter('away_team_id', null)
            .or('status.eq.scheduled,status.eq.pending')
            .order('match_date', ascending: true);
      } catch (e) {
        // Intento B: esquema alternativo (guest_team_id + scheduled_date)
        try {
          final base = supabase
              .from('matches')
              .select('*')
              .isFilter('guest_team_id', null)
              .or('status.eq.scheduled,status.eq.pending');
          dynamic tmp;
          try {
            tmp = await base
                .eq('is_public', true)
                .order('scheduled_date', ascending: true);
          } catch (_) {
            // Si is_public no existe, omitirlo
            tmp = await base.order('scheduled_date', ascending: true);
          }
          response = tmp;
        } catch (_) {
          // Último recurso: sin orden específico
          response = await supabase
              .from('matches')
              .select('*')
              .isFilter('guest_team_id', null)
              .or('status.eq.scheduled,status.eq.pending');
        }
      }

      final list =
          (response as List<dynamic>)
              .map((match) => _mapToMatchModel(match))
              .where(
                (m) =>
                    // Excluir partidos donde el usuario es del equipo anfitrión
                    !(hostTeamIds.contains(m.hostTeamId)),
              )
              .toList();

      return list;
    } catch (e) {
      print('Error obteniendo partidos públicos: $e');
      rethrow;
    }
  }

  // Obtener mis partidos
  Future<List<MatchModel>> getMyMatches() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      // Obtener equipos del usuario
      final userTeams = await supabase
          .from('team_members')
          .select('team_id')
          .eq('player_id', userId)
          .eq('is_active', true);

      if (userTeams.isEmpty) return [];

      final teamIds = userTeams.map((t) => t['team_id']).toList();

      final idsCsv = '(${teamIds.join(',')})';
      dynamic response;
      // Intento A: columnas home/away
      try {
        response = await supabase
            .from('matches')
            .select('*')
            .or('home_team_id.in.$idsCsv,away_team_id.in.$idsCsv')
            .order('match_date', ascending: false);
      } catch (e) {
        // Intento B: columnas host/guest
        try {
          response = await supabase
              .from('matches')
              .select('*')
              .or('host_team_id.in.$idsCsv,guest_team_id.in.$idsCsv')
              .order('scheduled_date', ascending: false);
        } catch (_) {
          response = await supabase
              .from('matches')
              .select('*')
              .or('host_team_id.in.$idsCsv,guest_team_id.in.$idsCsv');
        }
      }

      final list =
          (response as List<dynamic>)
              .map((match) => _mapToMatchModel(match))
              .toList();
      // De-duplicar por id en caso de OR múltiple
      final seen = <String>{};
      final deduped = <MatchModel>[];
      for (final m in list) {
        if (!seen.contains(m.id)) {
          seen.add(m.id);
          deduped.add(m);
        }
      }
      return deduped;
    } catch (e) {
      print('Error obteniendo mis partidos: $e');
      rethrow;
    }
  }

  // Obtener partidos en vivo
  Future<List<MatchModel>> getLiveMatches() async {
    try {
      dynamic response;
      try {
        response = await supabase
            .from('matches')
            .select('*')
            .or('status.eq.active,status.eq.live')
            .order('match_date', ascending: false);
      } catch (_) {
        response = await supabase
            .from('matches')
            .select('*')
            .or('status.eq.active,status.eq.live')
            .order('scheduled_date', ascending: false);
      }

      return (response as List<dynamic>)
          .map((match) => _mapToMatchModel(match))
          .toList();
    } catch (e) {
      print('Error obteniendo partidos en vivo: $e');
      rethrow;
    }
  }

  // Obtener historial de partidos
  Future<List<MatchModel>> getMatchHistory() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      final userTeams = await supabase
          .from('team_members')
          .select('team_id')
          .eq('player_id', userId)
          .eq('is_active', true);

      if (userTeams.isEmpty) return [];

      final teamIds = userTeams.map((t) => t['team_id']).toList();

      final idsCsv = '(${teamIds.join(',')})';
      dynamic response;
      // Intento A: columnas home/away
      try {
        response = await supabase
            .from('matches')
            .select('*')
            .or('home_team_id.in.$idsCsv,away_team_id.in.$idsCsv')
            .eq('status', 'finished')
            .order('match_date', ascending: false);
      } catch (e) {
        // Intento B: columnas host/guest
        try {
          response = await supabase
              .from('matches')
              .select('*')
              .or('host_team_id.in.$idsCsv,guest_team_id.in.$idsCsv')
              .eq('status', 'finished')
              .order('scheduled_date', ascending: false);
        } catch (_) {
          response = await supabase
              .from('matches')
              .select('*')
              .or('host_team_id.in.$idsCsv,guest_team_id.in.$idsCsv')
              .eq('status', 'finished');
        }
      }

      final list =
          (response as List<dynamic>)
              .map((match) => _mapToMatchModel(match))
              .toList();
      final seen = <String>{};
      final deduped = <MatchModel>[];
      for (final m in list) {
        if (!seen.contains(m.id)) {
          seen.add(m.id);
          deduped.add(m);
        }
      }
      return deduped;
    } catch (e) {
      print('Error obteniendo historial: $e');
      rethrow;
    }
  }

  // Obtener un partido específico
  Future<MatchModel?> getMatch(String matchId) async {
    try {
      final response =
          await supabase
              .from('matches')
              .select('*')
              .eq('id', matchId)
              .maybeSingle();

      if (response == null) return null;

      return _mapToMatchModel(response);
    } catch (e) {
      print('Error obteniendo partido: $e');
      rethrow;
    }
  }

  // Obtener partidos de un equipo específico
  Future<List<MatchModel>> getTeamMatches(String teamId) async {
    try {
      dynamic response;
      // Intento A: columnas home/away
      try {
        response = await supabase
            .from('matches')
            .select('*')
            .or('home_team_id.eq.$teamId,away_team_id.eq.$teamId')
            .order('match_date', ascending: false);
      } catch (e) {
        // Intento B: columnas host/guest
        response = await supabase
            .from('matches')
            .select('*')
            .or('host_team_id.eq.$teamId,guest_team_id.eq.$teamId')
            .order('scheduled_date', ascending: false);
      }

      return (response as List<dynamic>)
          .map((match) => _mapToMatchModel(match))
          .toList();
    } catch (e) {
      print('Error obteniendo partidos del equipo: $e');
      rethrow;
    }
  }

  // Cancelar un partido
  Future<void> cancelMatch(String matchId) async {
    try {
      await supabase
          .from('matches')
          .update({'status': 'cancelled'})
          .eq('id', matchId);

      print('Partido cancelado: $matchId');
    } catch (e) {
      print('Error cancelando partido: $e');
      rethrow;
    }
  }

  // Obtener estadísticas de partidos
  Future<Map<String, dynamic>> getMatchStats() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      final userTeams = await supabase
          .from('team_members')
          .select('team_id')
          .eq('player_id', userId)
          .eq('is_active', true);

      if (userTeams.isEmpty) {
        return {
          'totalMatches': 0,
          'wins': 0,
          'draws': 0,
          'losses': 0,
          'goalsFor': 0,
          'goalsAgainst': 0,
          'goalDifference': 0,
        };
      }

      final teamIds = userTeams.map((t) => t['team_id']).toList();

      final response = await supabase
          .from('matches')
          .select('status, home_team_id, away_team_id, home_score, away_score')
          .or(
            teamIds
                .map((id) => 'home_team_id.eq.$id,away_team_id.eq.$id')
                .join(','),
          )
          .eq('status', 'finished');

      final matches = response as List<dynamic>;

      int wins = 0;
      int draws = 0;
      int losses = 0;
      int goalsFor = 0;
      int goalsAgainst = 0;

      for (final match in matches) {
        final hostScore = match['home_score'];
        final guestScore = match['away_score'];
        if (hostScore != null && guestScore != null) {
          final int h = hostScore as int;
          final int g = guestScore as int;

          final isHost = teamIds.contains(match['home_team_id']);

          if (isHost) {
            goalsFor += h;
            goalsAgainst += g;

            if (h > g) {
              wins++;
            } else if (h == g)
              draws++;
            else
              losses++;
          } else {
            goalsFor += g;
            goalsAgainst += h;

            if (g > h) {
              wins++;
            } else if (g == h)
              draws++;
            else
              losses++;
          }
        }
      }

      return {
        'totalMatches': matches.length,
        'wins': wins,
        'draws': draws,
        'losses': losses,
        'goalsFor': goalsFor,
        'goalsAgainst': goalsAgainst,
        'goalDifference': goalsFor - goalsAgainst,
      };
    } catch (e) {
      print('Error obteniendo estadísticas: $e');
      rethrow;
    }
  }

  // Mapear datos de Supabase a MatchModel (soporta ambos esquemas del modelo)
  MatchModel _mapToMatchModel(Map<String, dynamic> data) {
    return MatchModel(
      id: data['id'],
      hostTeamId: data['home_team_id'] ?? data['host_team_id'],
      guestTeamId: data['away_team_id'] ?? data['guest_team_id'],
      hostTeamName:
          data['home_team']?['name'] ??
          data['host_team']?['name'] ??
          data['host_team_name'],
      guestTeamName:
          data['away_team']?['name'] ??
          data['guest_team']?['name'] ??
          data['guest_team_name'],
      scheduledDate: DateTime.parse(
        (data['match_date'] ?? data['scheduled_date']) as String,
      ),
      location: data['location'] ?? '',
      matchType: data['modality_type'] ?? data['match_type'] ?? 'futbolito',
      status: data['status'] ?? 'scheduled',
      isPublic: (data['is_public'] as bool?) ?? false,
      description: data['description'],
      hostTeamScore:
          data['home_score'] ?? data['score_host'] ?? data['host_team_score'],
      guestTeamScore:
          data['away_score'] ?? data['score_guest'] ?? data['guest_team_score'],
      createdBy: data['created_by'],
      createdAt:
          data['created_at'] != null
              ? DateTime.parse(data['created_at'])
              : null,
      updatedAt:
          data['updated_at'] != null
              ? DateTime.parse(data['updated_at'])
              : null,
      homeTeamId: data['home_team_id'],
      awayTeamId: data['away_team_id'],
      matchDate:
          data['match_date'] != null
              ? DateTime.parse(data['match_date'])
              : null,
      homeScore: (data['home_score'] as num?)?.toInt() ?? 0,
      awayScore: (data['away_score'] as num?)?.toInt() ?? 0,
    );
  }
}
