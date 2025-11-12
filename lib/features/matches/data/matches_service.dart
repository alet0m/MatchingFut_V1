// ignore_for_file: avoid_print

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/match_model.dart';
import '../../../shared/models/team_model.dart';
import '../../../core/config/supabase_config.dart';
import '../../teams/data/players_service.dart';

class MatchesService {
  final SupabaseClient _supabase;
  final PlayersService _playersService;

  MatchesService(this._supabase, this._playersService);

  // Helper method para mapear respuestas de la base de datos
  Map<String, dynamic> _mapMatchFromDatabase(Map<String, dynamic> dbMatch) {
    return {
      'id': dbMatch['id'],
      'homeTeamId': dbMatch['home_team_id'],
      'awayTeamId': dbMatch['away_team_id'],
      'canchaId': dbMatch['cancha_id'],
      'sectorId': dbMatch['sector_id'],
      'matchDate':
          dbMatch['match_date'] != null
              ? DateTime.parse(
                dbMatch['match_date'] as String,
              ).toIso8601String()
              : DateTime.now().toIso8601String(),
      'status': dbMatch['status'] ?? 'scheduled',
      'homeScore': dbMatch['home_score'] ?? 0,
      'awayScore': dbMatch['away_score'] ?? 0,
      'eloChange': dbMatch['elo_change'] ?? 0,
      'createdBy': dbMatch['created_by'],
      'createdAt':
          dbMatch['created_at'] != null
              ? DateTime.parse(
                dbMatch['created_at'] as String,
              ).toIso8601String()
              : DateTime.now().toIso8601String(),
    };
  }

  // Validar que ambos equipos tengan jugadores suficientes
  Future<void> _validateTeamsHavePlayers({
    required String homeTeamId,
    required String awayTeamId,
    int minPlayers = 7,
  }) async {
    final homePlayersCount = await _playersService.getTeamPlayersCount(
      homeTeamId,
    );
    final awayPlayersCount = await _playersService.getTeamPlayersCount(
      awayTeamId,
    );

    if (homePlayersCount < minPlayers) {
      throw Exception(
        'El equipo local necesita al menos $minPlayers jugadores para crear un partido',
      );
    }

    if (awayPlayersCount < minPlayers) {
      throw Exception(
        'El equipo visitante necesita al menos $minPlayers jugadores para crear un partido',
      );
    }
  }

  // Crear un nuevo partido
  Future<MatchModel> createMatch({
    required String homeTeamId,
    required String awayTeamId,
    required DateTime matchDate,
    String? canchaId,
    String? sectorId,
    required String createdBy,
    bool skipPlayerValidation = false,
    String modality = 'futbolito', // Agregar parámetro de modalidad
    int? minPlayers,
    int? maxPlayers,
    int? fieldPlayers,
  }) async {
    try {
      // Validar que los equipos tengan jugadores suficientes
      if (!skipPlayerValidation) {
        await _validateTeamsHavePlayers(
          homeTeamId: homeTeamId,
          awayTeamId: awayTeamId,
          minPlayers: minPlayers ?? 7,
        );
      }

      final data = {
        'home_team_id': homeTeamId,
        'away_team_id': awayTeamId,
        'cancha_id': canchaId,
        'sector_id': sectorId,
        'match_date': matchDate.toIso8601String(),
        'status': 'scheduled',
        'home_score': 0,
        'away_score': 0,
        'elo_change': 0,
        'created_by': createdBy,
        'modality': modality,
        'min_players': minPlayers,
        'max_players': maxPlayers,
        'field_players': fieldPlayers,
        'created_at': DateTime.now().toIso8601String(),
      };

      print('Creando partido con datos: $data');

      final response =
          await _supabase.from('matches').insert(data).select().single();

      print('Respuesta de Supabase: $response');

      // Mapear los nombres de campos de la base de datos al modelo
      final mappedResponse = _mapMatchFromDatabase(response);

      print('Datos mapeados: $mappedResponse');

      return MatchModel.fromJson(mappedResponse);
    } catch (e) {
      print('Error al crear partido: $e');
      rethrow;
    }
  }

  // Obtener partidos por equipo
  Future<List<MatchModel>> getMatchesByTeam(String teamId) async {
    final response = await _supabase
        .from('matches')
        .select()
        .or('home_team_id.eq.$teamId,away_team_id.eq.$teamId')
        .order('match_date', ascending: false);

    return response
        .map<MatchModel>(
          (json) => MatchModel.fromJson(_mapMatchFromDatabase(json)),
        )
        .toList();
  }

  // Obtener partidos próximos
  Future<List<MatchModel>> getUpcomingMatches({int limit = 10}) async {
    final now = DateTime.now();
    final response = await _supabase
        .from('matches')
        .select()
        .gte('match_date', now.toIso8601String())
        .eq('status', 'scheduled')
        .order('match_date', ascending: true)
        .limit(limit);

    return response
        .map<MatchModel>(
          (json) => MatchModel.fromJson(_mapMatchFromDatabase(json)),
        )
        .toList();
  }

  // Obtener partidos terminados
  Future<List<MatchModel>> getFinishedMatches({int limit = 10}) async {
    final response = await _supabase
        .from('matches')
        .select()
        .eq('status', 'finished')
        .order('match_date', ascending: false)
        .limit(limit);

    return response
        .map<MatchModel>(
          (json) => MatchModel.fromJson(_mapMatchFromDatabase(json)),
        )
        .toList();
  }

  // Obtener partidos por sector
  Future<List<MatchModel>> getMatchesBySector(String sectorId) async {
    final response = await _supabase
        .from('matches')
        .select()
        .eq('sector_id', sectorId)
        .order('match_date', ascending: false);

    return response
        .map<MatchModel>((json) => MatchModel.fromJson(json))
        .toList();
  }

  // Actualizar resultado del partido
  Future<MatchModel> updateMatchResult({
    required String matchId,
    required int homeScore,
    required int awayScore,
  }) async {
    final data = {
      'home_score': homeScore,
      'away_score': awayScore,
      'status': 'finished',
    };

    final response =
        await _supabase
            .from('matches')
            .update(data)
            .eq('id', matchId)
            .select()
            .single();

    return MatchModel.fromJson(response);
  }

  // Cancelar partido
  Future<MatchModel> cancelMatch(String matchId) async {
    final response =
        await _supabase
            .from('matches')
            .update({'status': 'cancelled'})
            .eq('id', matchId)
            .select()
            .single();

    return MatchModel.fromJson(response);
  }

  // Iniciar partido
  Future<MatchModel> startMatch(String matchId) async {
    final response =
        await _supabase
            .from('matches')
            .update({'status': 'in_progress'})
            .eq('id', matchId)
            .select()
            .single();

    return MatchModel.fromJson(response);
  }

  // Obtener partidos del usuario (como creador o miembro de equipos)
  Future<List<MatchModel>> getUserMatches(String userId) async {
    // Primero obtener los equipos del usuario
    final userTeamsResponse = await _supabase
        .from('team_members')
        .select('team_id')
        .eq('user_id', userId);

    final teamIds =
        userTeamsResponse.map((e) => e['team_id'] as String).toList();

    if (teamIds.isEmpty) return [];

    // Luego obtener los partidos donde el usuario participa
    final matchesResponse = await _supabase
        .from('matches')
        .select()
        .or(
          teamIds
              .map((id) => 'home_team_id.eq.$id,away_team_id.eq.$id')
              .join(','),
        )
        .order('match_date', ascending: false);

    return matchesResponse
        .map<MatchModel>((json) => MatchModel.fromJson(json))
        .toList();
  }

  // Obtener equipos disponibles para desafiar
  Future<List<TeamModel>> getAvailableTeamsToChallenge(
    String currentTeamId,
  ) async {
    final response = await _supabase
        .from('teams')
        .select()
        .neq('id', currentTeamId)
        .order('average_elo', ascending: false);

    return response.map<TeamModel>((json) => TeamModel.fromJson(json)).toList();
  }

  // Crear partido público
  Future<void> createPublicMatch({
    required String hostTeamId,
    required String title,
    required String description,
    required DateTime matchDate,
    required String comunaId,
    String? location,
    int? minEloRange,
    int? maxEloRange,
    String modality = 'futbolito', // Agregar parámetro de modalidad
    int? minPlayers,
    int? maxPlayers,
    int? fieldPlayers,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Validar que el equipo anfitrión tenga suficientes jugadores
      final homePlayersCount = await _playersService.getTeamPlayersCount(
        hostTeamId,
      );
      final requiredPlayers = minPlayers ?? 7;
      if (homePlayersCount < requiredPlayers) {
        throw Exception(
          'El equipo necesita al menos $requiredPlayers jugadores para crear un partido público',
        );
      }

      // Obtener información del equipo para desnormalizar
      final teamResponse =
          await _supabase
              .from('teams')
              .select('name, tag')
              .eq('id', hostTeamId)
              .single();

      // Crear entrada en la tabla de partidos públicos
      await _supabase.from('public_matches').insert({
        'host_team_id': hostTeamId,
        'title': title,
        'description': description,
        'match_date': matchDate.toIso8601String(),
        'comuna_id': comunaId,
        'location': location,
        'min_elo_range': minEloRange,
        'max_elo_range': maxEloRange,
        'modality_type': modality,
        'min_players': minPlayers,
        'max_players': maxPlayers,
        'field_players': fieldPlayers,
        'host_team_name': teamResponse['name'],
        'host_team_tag': teamResponse['tag'],
        'status': 'open',
        'created_by': user.id,
        'created_at': DateTime.now().toIso8601String(),
        'expires_at':
            DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      });
    } catch (e) {
      print('Error creating public match: $e');
      rethrow;
    }
  }
}

// Provider para el servicio de partidos
final matchesServiceProvider = Provider<MatchesService>((ref) {
  final supabase = ref.watch(supabaseProvider);
  final playersService = ref.watch(playersServiceProvider);
  return MatchesService(supabase, playersService);
});

// Provider para obtener partidos del usuario
final userMatchesProvider = FutureProvider<List<MatchModel>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return [];

  final matchesService = ref.watch(matchesServiceProvider);
  return matchesService.getUserMatches(user.id);
});

// Provider para obtener partidos próximos
final upcomingMatchesProvider = FutureProvider<List<MatchModel>>((ref) async {
  final matchesService = ref.watch(matchesServiceProvider);
  return matchesService.getUpcomingMatches();
});

// Provider para obtener partidos terminados
final finishedMatchesProvider = FutureProvider<List<MatchModel>>((ref) async {
  final matchesService = ref.watch(matchesServiceProvider);
  return matchesService.getFinishedMatches();
});

// Provider para obtener partidos por equipo
final teamMatchesProvider = FutureProvider.family<List<MatchModel>, String>((
  ref,
  teamId,
) async {
  final matchesService = ref.watch(matchesServiceProvider);
  return matchesService.getMatchesByTeam(teamId);
});

// Provider para obtener equipos disponibles para desafiar
final availableTeamsProvider = FutureProvider.family<List<TeamModel>, String>((
  ref,
  teamId,
) async {
  final matchesService = ref.watch(matchesServiceProvider);
  return matchesService.getAvailableTeamsToChallenge(teamId);
});
