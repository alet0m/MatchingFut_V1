import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/match_model.dart';

class MatchesServiceEnhanced {
  static final SupabaseClient supabase = Supabase.instance.client;

  // Crear partido público
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

    final matchData = {
      'host_team_id': hostTeamId,
      'scheduled_date': scheduledDate.toIso8601String(),
      'location': location,
      'description': description,
      'match_type': matchType,
      'is_public': true,
      'status': 'scheduled',
      'created_by': currentUser.id,
    };

    final response =
        await supabase
            .from('matches_enhanced')
            .insert(matchData)
            .select()
            .single();

    final matchId = response['id'];
    print('✅ Partido público creado con ID: $matchId');

    return matchId;
  }

  // Crear partido privado
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

    final matchData = {
      'host_team_id': hostTeamId,
      'guest_team_id': guestTeamId,
      'scheduled_date': scheduledDate.toIso8601String(),
      'location': location,
      'description': description,
      'match_type': matchType,
      'is_public': false,
      'status': 'scheduled',
      'created_by': currentUser.id,
    };

    final response =
        await supabase
            .from('matches_enhanced')
            .insert(matchData)
            .select()
            .single();

    final matchId = response['id'];
    print('✅ Partido privado creado con ID: $matchId');

    return matchId;
  }

  // Unirse a un partido público
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
            .from('matches_enhanced')
            .select('*')
            .eq('id', matchId)
            .eq('is_public', true)
            .eq('status', 'scheduled')
            .isFilter('guest_team_id', null)
            .maybeSingle();

    if (match == null) {
      throw Exception('Partido no disponible');
    }

    if (match['host_team_id'] == teamId) {
      throw Exception('No puedes unirte a tu propio partido');
    }

    await supabase
        .from('matches_enhanced')
        .update({'guest_team_id': teamId})
        .eq('id', matchId);

    print('✅ Te has unido al partido exitosamente');
  }

  // Iniciar partido
  Future<void> startMatch(String matchId) async {
    print('🚀 Iniciando partido $matchId');

    await supabase
        .from('matches_enhanced')
        .update({
          'status': 'live',
          'started_at': DateTime.now().toIso8601String(),
        })
        .eq('id', matchId);

    print('✅ Partido iniciado');
  }

  // Finalizar partido
  Future<void> finishMatch(
    String matchId,
    int hostScore,
    int guestScore,
  ) async {
    print('🏁 Finalizando partido $matchId');

    await supabase
        .from('matches_enhanced')
        .update({
          'status': 'finished',
          'finished_at': DateTime.now().toIso8601String(),
          'host_team_score': hostScore,
          'guest_team_score': guestScore,
        })
        .eq('id', matchId);

    print('✅ Partido finalizado');
  }

  // Obtener partidos públicos
  Future<List<MatchModel>> getPublicMatches() async {
    try {
      final response = await supabase
          .from('matches_enhanced')
          .select(
            '*, host_team:teams!host_team_id(name), guest_team:teams!guest_team_id(name)',
          )
          .eq('is_public', true)
          .eq('status', 'scheduled')
          .order('scheduled_date', ascending: true);

      return (response as List<dynamic>)
          .map((match) => _mapToMatchModel(match))
          .toList();
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

      final response = await supabase
          .from('matches_enhanced')
          .select(
            '*, host_team:teams!host_team_id(name), guest_team:teams!guest_team_id(name)',
          )
          .or(
            teamIds
                .map((id) => 'host_team_id.eq.$id,guest_team_id.eq.$id')
                .join(','),
          )
          .order('scheduled_date', ascending: false);

      return (response as List<dynamic>)
          .map((match) => _mapToMatchModel(match))
          .toList();
    } catch (e) {
      print('Error obteniendo mis partidos: $e');
      rethrow;
    }
  }

  // Obtener partidos en vivo
  Future<List<MatchModel>> getLiveMatches() async {
    try {
      final response = await supabase
          .from('matches_enhanced')
          .select(
            '*, host_team:teams!host_team_id(name), guest_team:teams!guest_team_id(name)',
          )
          .eq('status', 'live')
          .order('started_at', ascending: false);

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

      final response = await supabase
          .from('matches_enhanced')
          .select(
            '*, host_team:teams!host_team_id(name), guest_team:teams!guest_team_id(name)',
          )
          .or(
            teamIds
                .map((id) => 'host_team_id.eq.$id,guest_team_id.eq.$id')
                .join(','),
          )
          .eq('status', 'finished')
          .order('finished_at', ascending: false);

      return (response as List<dynamic>)
          .map((match) => _mapToMatchModel(match))
          .toList();
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
              .from('matches_enhanced')
              .select(
                '*, host_team:teams!host_team_id(name), guest_team:teams!guest_team_id(name)',
              )
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
      final response = await supabase
          .from('matches_enhanced')
          .select(
            '*, host_team:teams!host_team_id(name), guest_team:teams!guest_team_id(name)',
          )
          .or('host_team_id.eq.$teamId,guest_team_id.eq.$teamId')
          .order('scheduled_date', ascending: false);

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
          .from('matches_enhanced')
          .update({
            'status': 'cancelled',
            'updated_at': DateTime.now().toIso8601String(),
          })
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
          .from('matches_enhanced')
          .select(
            'status, host_team_id, guest_team_id, host_team_score, guest_team_score',
          )
          .or(
            teamIds
                .map((id) => 'host_team_id.eq.$id,guest_team_id.eq.$id')
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
        if (match['host_team_score'] != null &&
            match['guest_team_score'] != null) {
          final hostScore = match['host_team_score'] as int;
          final guestScore = match['guest_team_score'] as int;

          final isHost = teamIds.contains(match['host_team_id']);

          if (isHost) {
            goalsFor += hostScore;
            goalsAgainst += guestScore;

            if (hostScore > guestScore) {
              wins++;
            } else if (hostScore == guestScore)
              draws++;
            else
              losses++;
          } else {
            goalsFor += guestScore;
            goalsAgainst += hostScore;

            if (guestScore > hostScore) {
              wins++;
            } else if (guestScore == hostScore)
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

  // Mapear datos de Supabase a MatchModel
  MatchModel _mapToMatchModel(Map<String, dynamic> data) {
    return MatchModel(
      id: data['id'],
      hostTeamId: data['host_team_id'],
      guestTeamId: data['guest_team_id'],
      hostTeamName: data['host_team']?['name'],
      guestTeamName: data['guest_team']?['name'],
      scheduledDate: DateTime.parse(data['scheduled_date']),
      location: data['location'],
      matchType: data['match_type'] ?? 'futbolito',
      status: data['status'] ?? 'scheduled',
      isPublic: data['is_public'] ?? false,
      description: data['description'],
      hostTeamScore: data['host_team_score'],
      guestTeamScore: data['guest_team_score'],
      startedAt:
          data['started_at'] != null
              ? DateTime.parse(data['started_at'])
              : null,
      finishedAt:
          data['finished_at'] != null
              ? DateTime.parse(data['finished_at'])
              : null,
      createdBy: data['created_by'],
      createdAt:
          data['created_at'] != null
              ? DateTime.parse(data['created_at'])
              : null,
      updatedAt:
          data['updated_at'] != null
              ? DateTime.parse(data['updated_at'])
              : null,
    );
  }
}
