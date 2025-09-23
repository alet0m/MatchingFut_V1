// ignore_for_file: avoid_print

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/challenge_model.dart';
import '../../../shared/models/team_model.dart';
import '../../../shared/models/match_model.dart';
import '../../../core/config/supabase_config.dart';
import '../../matches/data/matches_service.dart';

class ChallengesService {
  final SupabaseClient _supabase;
  final MatchesService _matchesService;

  ChallengesService(this._supabase, this._matchesService);

  // Helper method para mapear respuestas de la base de datos
  Map<String, dynamic> _mapChallengeFromDatabase(
    Map<String, dynamic> dbChallenge,
  ) {
    return {
      'id': dbChallenge['id'],
      'challengerTeamId': dbChallenge['challenger_team_id'],
      'challengedTeamId': dbChallenge['challenged_team_id'],
      'message': dbChallenge['message'],
      'proposedDate':
          dbChallenge['proposed_date'] != null
              ? DateTime.parse(
                dbChallenge['proposed_date'] as String,
              ).toIso8601String()
              : null,
      'canchaId': dbChallenge['cancha_id'],
      'sectorId': dbChallenge['sector_id'],
      'status': dbChallenge['status'] ?? 'pending',
      'createdBy': dbChallenge['created_by'],
      'createdAt':
          dbChallenge['created_at'] != null
              ? DateTime.parse(
                dbChallenge['created_at'] as String,
              ).toIso8601String()
              : DateTime.now().toIso8601String(),
      'respondedAt':
          dbChallenge['responded_at'] != null
              ? DateTime.parse(
                dbChallenge['responded_at'] as String,
              ).toIso8601String()
              : null,
      'respondedBy': dbChallenge['responded_by'],
      'matchId': dbChallenge['match_id'],
    };
  }

  // Crear un nuevo desafío
  Future<ChallengeModel> createChallenge({
    required String challengerTeamId,
    required String challengedTeamId,
    String? message,
    DateTime? proposedDate,
    String? canchaId,
    String? sectorId,
    required String createdBy,
  }) async {
    try {
      final data = {
        'challenger_team_id': challengerTeamId,
        'challenged_team_id': challengedTeamId,
        'message': message,
        'proposed_date': proposedDate?.toIso8601String(),
        'cancha_id': canchaId,
        'sector_id': sectorId,
        'status': 'pending',
        'created_by': createdBy,
        'created_at': DateTime.now().toIso8601String(),
      };

      print('Creando desafío con datos: $data');

      final response =
          await _supabase.from('challenges').insert(data).select().single();

      print('Respuesta de Supabase: $response');

      final mappedResponse = _mapChallengeFromDatabase(response);
      return ChallengeModel.fromJson(mappedResponse);
    } catch (e) {
      print('Error al crear desafío: $e');
      rethrow;
    }
  }

  // Buscar equipos disponibles para retar (excluyendo propios)
  Future<List<TeamModel>> searchAvailableTeams(
    String currentTeamId, {
    String? searchQuery,
    String? comuna,
    int? minElo,
    int? maxElo,
  }) async {
    try {
      var query = _supabase.from('teams').select().neq('id', currentTeamId);

      // Filtro por búsqueda de texto
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('name', '%$searchQuery%');
      }

      // Filtro por comuna
      if (comuna != null && comuna.isNotEmpty) {
        query = query.eq('comuna', comuna);
      }

      // Filtro por ELO mínimo
      if (minElo != null) {
        query = query.gte('average_elo', minElo);
      }

      // Filtro por ELO máximo
      if (maxElo != null) {
        query = query.lte('average_elo', maxElo);
      }

      // Ordenar y limitar
      final teamsResponse = await query
          .order('name', ascending: true)
          .limit(50);

      return teamsResponse.map<TeamModel>((json) {
        final mappedData = {
          'id': json['id'],
          'name': json['name'],
          'captainId': json['captain_id'],
          'sectorId': json['sector_id'],
          'averageElo': json['average_elo'] ?? 1200,
          'totalMatches': json['total_matches'] ?? 0,
          'wins': json['wins'] ?? 0,
          'losses': json['losses'] ?? 0,
          'draws': json['draws'] ?? 0,
          'createdAt':
              json['created_at'] != null
                  ? DateTime.parse(
                    json['created_at'] as String,
                  ).toIso8601String()
                  : DateTime.now().toIso8601String(),
        };
        return TeamModel.fromJson(mappedData);
      }).toList();
    } catch (e) {
      print('Error al buscar equipos: $e');
      rethrow;
    }
  }

  // Obtener desafíos recibidos por un equipo
  Future<List<ChallengeModel>> getReceivedChallenges(String teamId) async {
    try {
      final response = await _supabase
          .from('challenges')
          .select()
          .eq('challenged_team_id', teamId)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return response
          .map<ChallengeModel>(
            (json) => ChallengeModel.fromJson(_mapChallengeFromDatabase(json)),
          )
          .toList();
    } catch (e) {
      print('Error al obtener desafíos recibidos: $e');
      rethrow;
    }
  }

  // Obtener desafíos enviados por un equipo
  Future<List<ChallengeModel>> getSentChallenges(String teamId) async {
    try {
      final response = await _supabase
          .from('challenges')
          .select()
          .eq('challenger_team_id', teamId)
          .order('created_at', ascending: false);

      return response
          .map<ChallengeModel>(
            (json) => ChallengeModel.fromJson(_mapChallengeFromDatabase(json)),
          )
          .toList();
    } catch (e) {
      print('Error al obtener desafíos enviados: $e');
      rethrow;
    }
  }

  // Aceptar un desafío y crear el partido
  Future<MatchModel> acceptChallenge({
    required String challengeId,
    required String respondedBy,
  }) async {
    try {
      // Primero obtener el desafío
      final challengeResponse =
          await _supabase
              .from('challenges')
              .select()
              .eq('id', challengeId)
              .single();

      // Crear el partido usando los datos directos
      final match = await _matchesService.createMatch(
        homeTeamId: challengeResponse['challenged_team_id'],
        awayTeamId: challengeResponse['challenger_team_id'],
        matchDate:
            challengeResponse['proposed_date'] != null
                ? DateTime.parse(challengeResponse['proposed_date'] as String)
                : DateTime.now().add(const Duration(days: 7)),
        canchaId: challengeResponse['cancha_id'],
        sectorId: challengeResponse['sector_id'],
        createdBy: respondedBy,
      );

      // Actualizar el desafío como aceptado
      await _supabase
          .from('challenges')
          .update({
            'status': 'accepted',
            'responded_at': DateTime.now().toIso8601String(),
            'responded_by': respondedBy,
            'match_id': match.id,
          })
          .eq('id', challengeId);

      return match;
    } catch (e) {
      print('Error al aceptar desafío: $e');
      rethrow;
    }
  }

  // Rechazar un desafío
  Future<void> rejectChallenge({
    required String challengeId,
    required String respondedBy,
  }) async {
    try {
      await _supabase
          .from('challenges')
          .update({
            'status': 'rejected',
            'responded_at': DateTime.now().toIso8601String(),
            'responded_by': respondedBy,
          })
          .eq('id', challengeId);
    } catch (e) {
      print('Error al rechazar desafío: $e');
      rethrow;
    }
  }
}

// Providers
final challengesServiceProvider = Provider<ChallengesService>((ref) {
  final supabase = ref.watch(supabaseProvider);
  final matchesService = ref.watch(matchesServiceProvider);
  return ChallengesService(supabase, matchesService);
});

final availableTeamsProvider = FutureProvider.family<
  List<TeamModel>,
  ({
    String currentTeamId,
    String? searchQuery,
    String? comuna,
    int? minElo,
    int? maxElo,
  })
>((ref, params) async {
  final challengesService = ref.watch(challengesServiceProvider);
  return challengesService.searchAvailableTeams(
    params.currentTeamId,
    searchQuery: params.searchQuery,
    comuna: params.comuna,
    minElo: params.minElo,
    maxElo: params.maxElo,
  );
});

final receivedChallengesProvider =
    FutureProvider.family<List<ChallengeModel>, String>((ref, teamId) async {
      final challengesService = ref.watch(challengesServiceProvider);
      return challengesService.getReceivedChallenges(teamId);
    });

final sentChallengesProvider =
    FutureProvider.family<List<ChallengeModel>, String>((ref, teamId) async {
      final challengesService = ref.watch(challengesServiceProvider);
      return challengesService.getSentChallenges(teamId);
    });
