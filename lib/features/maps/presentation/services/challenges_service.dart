import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/models/team_model.dart';
import '../../../../shared/models/sector_model.dart';
import '../../../core/config/supabase_config.dart';

/// Servicio para gestionar los desafíos territoriales entre equipos
class ChallengesService {
  final _supabase = Supabase.instance.client;

  /// Obtiene el equipo del usuario actual
  Future<TeamModel?> getUserTeam() async {
    try {
      // Obtener el ID del usuario autenticado
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      // Buscar si el usuario pertenece a algún equipo como capitán o miembro
      final response =
          await _supabase
              .from('team_members')
              .select('teams(*)')
              .eq('user_id', userId)
              .maybeSingle();

      if (response == null) return null;

      return TeamModel.fromJson(response['teams']);
    } catch (e) {
      debugPrint('Error obteniendo equipo del usuario: $e');
      return null;
    }
  }

  /// Obtiene los desafíos pendientes (por confirmar) en una comuna
  Future<List<Map<String, dynamic>>> getPendingChallenges(
    String comunaId,
  ) async {
    try {
      // Obtener el equipo del usuario
      final userTeam = await getUserTeam();
      if (userTeam == null) return [];

      // Consultar desafíos donde el usuario es desafiante o defensor y están pendientes
      final response = await _supabase
          .from('challenges')
          .select('''
            id, 
            status, 
            challenge_date,
            challenger_team_id, 
            defender_team_id,
            sector_id,
            challenger_team:challenger_team_id(id, name, logo_url, averageElo),
            defender_team:defender_team_id(id, name, logo_url, averageElo),
            sector:sector_id(id, name, description, comuna_id)
          ''')
          .eq('status', 'pending')
          .or(
            'challenger_team_id.eq.${userTeam.id},defender_team_id.eq.${userTeam.id}',
          )
          .eq('sector.comuna_id', comunaId)
          .order('challenge_date', ascending: true);

      return _processChallengesResponse(response);
    } catch (e) {
      debugPrint('Error obteniendo desafíos pendientes: $e');
      return [];
    }
  }

  /// Obtiene los desafíos activos (confirmados, pendientes de jugar) en una comuna
  Future<List<Map<String, dynamic>>> getActiveChallenges(
    String comunaId,
  ) async {
    try {
      // Obtener el equipo del usuario
      final userTeam = await getUserTeam();
      if (userTeam == null) return [];

      // Consultar desafíos donde el usuario es desafiante o defensor y están activos
      final response = await _supabase
          .from('challenges')
          .select('''
            id, 
            status, 
            challenge_date,
            match_date,
            challenger_team_id, 
            defender_team_id,
            sector_id,
            challenger_team:challenger_team_id(id, name, logo_url, averageElo),
            defender_team:defender_team_id(id, name, logo_url, averageElo),
            sector:sector_id(id, name, description, comuna_id)
          ''')
          .eq('status', 'accepted')
          .or(
            'challenger_team_id.eq.${userTeam.id},defender_team_id.eq.${userTeam.id}',
          )
          .eq('sector.comuna_id', comunaId)
          .order('match_date', ascending: true);

      return _processChallengesResponse(response);
    } catch (e) {
      debugPrint('Error obteniendo desafíos activos: $e');
      return [];
    }
  }

  /// Obtiene el historial de desafíos (completados) en una comuna
  Future<List<Map<String, dynamic>>> getHistoricalChallenges(
    String comunaId,
  ) async {
    try {
      // Obtener el equipo del usuario
      final userTeam = await getUserTeam();
      if (userTeam == null) return [];

      // Consultar desafíos donde el usuario es desafiante o defensor y están completados
      final response = await _supabase
          .from('challenges')
          .select('''
            id, 
            status, 
            challenge_date,
            match_date,
            completion_date,
            winner_team_id,
            challenger_team_id, 
            defender_team_id,
            sector_id,
            challenger_team:challenger_team_id(id, name, logo_url, averageElo),
            defender_team:defender_team_id(id, name, logo_url, averageElo),
            sector:sector_id(id, name, description, comuna_id),
            winner_team:winner_team_id(id, name, logo_url)
          ''')
          .eq('status', 'completed')
          .or(
            'challenger_team_id.eq.${userTeam.id},defender_team_id.eq.${userTeam.id}',
          )
          .eq('sector.comuna_id', comunaId)
          .order('completion_date', ascending: false);

      return _processChallengesResponse(response);
    } catch (e) {
      debugPrint('Error obteniendo historial de desafíos: $e');
      return [];
    }
  }

  /// Procesa la respuesta de la consulta de desafíos
  List<Map<String, dynamic>> _processChallengesResponse(
    List<dynamic> response,
  ) {
    return response.map((data) {
      // Convertir los datos de equipos y sector a modelos
      final challengerTeam = TeamModel.fromJson(data['challenger_team']);
      final defenderTeam = TeamModel.fromJson(data['defender_team']);
      final sector = SectorModel.fromJson(data['sector']);

      // Crear objeto con la información del desafío
      return {
        'id': data['id'],
        'status': data['status'],
        'challenge_date': data['challenge_date'],
        'match_date': data['match_date'],
        'completion_date': data['completion_date'],
        'challenger_team': challengerTeam,
        'defender_team': defenderTeam,
        'sector': sector,
        'winner_team_id': data['winner_team_id'],
      };
    }).toList();
  }

  /// Acepta un desafío pendiente
  Future<void> acceptChallenge(String challengeId) async {
    try {
      // Verificar que el usuario es el defensor en este desafío
      final userTeam = await getUserTeam();
      if (userTeam == null) {
        throw Exception('No tienes un equipo para aceptar desafíos');
      }

      // Obtener información del desafío
      final challenge =
          await _supabase
              .from('challenges')
              .select('*')
              .eq('id', challengeId)
              .single();

      if (challenge['defender_team_id'] != userTeam.id) {
        throw Exception('Solo el equipo defensor puede aceptar el desafío');
      }

      if (challenge['status'] != 'pending') {
        throw Exception('Este desafío no está en estado pendiente');
      }

      // Actualizar el estado del desafío a 'accepted'
      await _supabase
          .from('challenges')
          .update({
            'status': 'accepted',
            'match_date':
                DateTime.now().add(const Duration(days: 7)).toIso8601String(),
          })
          .eq('id', challengeId);
    } catch (e) {
      debugPrint('Error aceptando desafío: $e');
      rethrow;
    }
  }

  /// Rechaza un desafío pendiente
  Future<void> rejectChallenge(String challengeId) async {
    try {
      // Verificar que el usuario es el defensor en este desafío
      final userTeam = await getUserTeam();
      if (userTeam == null) {
        throw Exception('No tienes un equipo para rechazar desafíos');
      }

      // Obtener información del desafío
      final challenge =
          await _supabase
              .from('challenges')
              .select('*')
              .eq('id', challengeId)
              .single();

      if (challenge['defender_team_id'] != userTeam.id) {
        throw Exception('Solo el equipo defensor puede rechazar el desafío');
      }

      if (challenge['status'] != 'pending') {
        throw Exception('Este desafío no está en estado pendiente');
      }

      // Actualizar el estado del desafío a 'rejected'
      await _supabase
          .from('challenges')
          .update({'status': 'rejected'})
          .eq('id', challengeId);
    } catch (e) {
      debugPrint('Error rechazando desafío: $e');
      rethrow;
    }
  }

  /// Crea un nuevo desafío territorial
  Future<String> createChallenge({
    required String sectorId,
    required String defenderTeamId,
  }) async {
    try {
      // Verificar que el usuario tiene un equipo
      final userTeam = await getUserTeam();
      if (userTeam == null) {
        throw Exception('No tienes un equipo para crear desafíos');
      }

      // Verificar que no existe un desafío activo o pendiente para este sector y equipos
      final existingChallenge =
          await _supabase
              .from('challenges')
              .select('id')
              .eq('sector_id', sectorId)
              .eq('challenger_team_id', userTeam.id)
              .eq('defender_team_id', defenderTeamId)
              .or('status.eq.pending,status.eq.accepted')
              .maybeSingle();

      if (existingChallenge != null) {
        throw Exception(
          'Ya existe un desafío activo o pendiente para este sector',
        );
      }

      // Crear el nuevo desafío
      final response =
          await _supabase
              .from('challenges')
              .insert({
                'challenger_team_id': userTeam.id,
                'defender_team_id': defenderTeamId,
                'sector_id': sectorId,
                'status': 'pending',
                'challenge_date': DateTime.now().toIso8601String(),
              })
              .select('id')
              .single();

      return response['id'];
    } catch (e) {
      debugPrint('Error creando desafío: $e');
      rethrow;
    }
  }

  /// Obtiene los detalles completos de un desafío
  Future<Map<String, dynamic>> getChallengeDetails(String challengeId) async {
    try {
      final response =
          await _supabase
              .from('challenges')
              .select('''
            id, 
            status, 
            challenge_date,
            match_date,
            completion_date,
            winner_team_id,
            challenger_team_id, 
            defender_team_id,
            sector_id,
            challenger_team:challenger_team_id(id, name, logo_url, averageElo),
            defender_team:defender_team_id(id, name, logo_url, averageElo),
            sector:sector_id(id, name, description, comuna_id),
            winner_team:winner_team_id(id, name, logo_url)
          ''')
              .eq('id', challengeId)
              .single();

      // Procesar respuesta para crear un objeto detallado
      final challengerTeam = TeamModel.fromJson(response['challenger_team']);
      final defenderTeam = TeamModel.fromJson(response['defender_team']);
      final sector = SectorModel.fromJson(response['sector']);

      return {
        'id': response['id'],
        'status': response['status'],
        'challenge_date': response['challenge_date'],
        'match_date': response['match_date'],
        'completion_date': response['completion_date'],
        'challenger_team': challengerTeam,
        'defender_team': defenderTeam,
        'sector': sector,
        'winner_team_id': response['winner_team_id'],
      };
    } catch (e) {
      debugPrint('Error obteniendo detalles del desafío: $e');
      rethrow;
    }
  }
}
