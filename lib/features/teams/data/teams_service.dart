import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/team_model.dart';
import '../../../core/config/supabase_config.dart';
import '../../auth/data/auth_service.dart';

class TeamsService {
  final SupabaseClient _supabase;

  TeamsService(this._supabase);

  // Helper method para mapear respuestas de la base de datos
  Map<String, dynamic> _mapTeamFromDatabase(Map<String, dynamic> dbTeam) {
    return {
      'id': dbTeam['id']?.toString() ?? '',
      'name': (dbTeam['name'] ?? '').toString(),
      'tag': dbTeam['tag']?.toString(),
      'captainId': dbTeam['captain_id']?.toString(),
      'comunaId': dbTeam['comuna_id']?.toString(),
      // TeamModel.modality tiene default, omitimos conversión desde modality_id
      'eloRating': dbTeam['elo_rating'] ?? 1200,
      'totalMatches': dbTeam['total_matches'] ?? 0,
      'wins': dbTeam['wins'] ?? 0,
      'losses': dbTeam['losses'] ?? 0,
      'draws': dbTeam['draws'] ?? 0,
      // Campos no presentes en TeamModel se omiten
      'createdAt': dbTeam['created_at']?.toString(),
    };
  }

  // Crear un nuevo equipo
  Future<TeamModel> createTeam({
    required String name,
    required String captainId,
    String? comunaId,
    String? comuna,
    int? modalityId,
    String? tag,
    String? description,
    String? logoUrl,
    String? homeColor,
    String? awayColor,
  }) async {
    try {
      // Verificar que el usuario esté autenticado
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // Verificar que el captainId coincida con el usuario actual
      if (currentUser.id != captainId) {
        throw Exception('El capitán debe ser el usuario actual');
      }

      print('🏆 Creando equipo para usuario: ${currentUser.id}');
      print('📝 Nombre del equipo: $name');
      print('🏙️ Comuna/ComunaId: ${comuna ?? comunaId}');

      // Resolver el comuna_id si se pasa un código de comuna
      String? finalComunaId = comunaId;
      if (comunaId == null && comuna != null) {
        print('🔍 Buscando ID de comuna para código: $comuna');
        try {
          final comunaResponse =
              await _supabase
                  .from('comunas')
                  .select('id')
                  .eq('code', comuna)
                  .maybeSingle();

          if (comunaResponse != null) {
            finalComunaId = comunaResponse['id'];
            print('✅ Comuna ID encontrado: $finalComunaId');
          } else {
            print('⚠️ Comuna no encontrada, creando sin comuna_id');
          }
        } catch (e) {
          print('❌ Error buscando comuna: $e');
        }
      }

      // Si el tag es nulo o vacío, generar uno único
      String finalTag = tag?.trim() ?? "";
      if (finalTag.isEmpty) {
        try {
          final tagResponse = await _supabase.rpc(
            'generate_team_tag',
            params: {'team_name': name},
          );
          finalTag = tagResponse as String;
          print('🏷️ Tag generado automáticamente: $finalTag');
        } catch (e) {
          // Si la función no existe, generar tag manualmente
          print(
            '⚠️ Función generate_team_tag no disponible, generando manualmente',
          );
          finalTag = name
              .toLowerCase()
              .replaceAll(RegExp(r'[^a-z0-9]'), '')
              .substring(0, name.length > 15 ? 15 : name.length);

          // Verificar unicidad manualmente
          var counter = 1;
          var testTag = finalTag;
          while (true) {
            final existing =
                await _supabase
                    .from('teams')
                    .select('id')
                    .eq('tag', testTag)
                    .maybeSingle();

            if (existing == null) {
              finalTag = testTag;
              break;
            }
            testTag = '$finalTag$counter';
            counter++;
          }
          print('🏷️ Tag manual generado: $finalTag');
        }
      }

      final data = {
        'name': name,
        'tag': finalTag,
        'captain_id': captainId,
        'modality_id': modalityId ?? 1, // Default a futbolito
        'description': description,
        'logo_url': logoUrl,
        'elo_rating': 1200,
        'total_matches': 0,
        'wins': 0,
        'losses': 0,
        'draws': 0,
        'is_active': true,
        'max_members': 15,
        'home_color':
            (homeColor == null || homeColor.isEmpty)
                ? '#2E7D32'
                : (homeColor.startsWith('#') ? homeColor : '#$homeColor'),
        'away_color':
            (awayColor == null || awayColor.isEmpty)
                ? '#FFFFFF'
                : (awayColor.startsWith('#') ? awayColor : '#$awayColor'),
      };

      // Solo agregar comuna_id si existe
      if (finalComunaId != null) {
        data['comuna_id'] = finalComunaId;
      }

      print('📋 Datos a insertar: $data');

      final response =
          await _supabase.from('teams').insert(data).select().single();

      print('✅ Respuesta de Supabase: $response');

      // Mapear los nombres de campos de la base de datos al modelo
      final mappedResponse = _mapTeamFromDatabase(response);

      print('Datos mapeados: $mappedResponse');

      final team = TeamModel.fromJson(mappedResponse);

      // Agregar al capitán como miembro del equipo
      await addTeamMember(
        teamId: team.id,
        userId: captainId,
        position: 'Capitán',
      );

      return team;
    } catch (e) {
      print('Error al crear equipo: $e');
      if (e is PostgrestException) {
        print('Código de error: ${e.code}');
        print('Mensaje: ${e.message}');
        print('Detalles: ${e.details}');

        if (e.code == '42501') {
          throw Exception(
            'Error de permisos: Verifica la configuración de seguridad en Supabase',
          );
        }
      }
      rethrow;
    }
  }

  // Obtener equipos por sector
  Future<List<TeamModel>> getTeamsBySector(String sectorId) async {
    // Nota: la tabla teams no tiene sector_id ni average_elo en el esquema base.
    // Se deja método como placeholder para futuro (filtrar por comuna/sector si aplica).
    final response = await _supabase
        .from('teams')
        .select()
        .order('elo_rating', ascending: false);

    return response
        .map<TeamModel>(
          (json) => TeamModel.fromJson(_mapTeamFromDatabase(json)),
        )
        .toList();
  }

  // Obtener equipos del usuario
  Future<List<TeamModel>> getUserTeams(String userId) async {
    final response = await _supabase
        .from('teams')
        .select('''
          *,
          team_members!inner (
            player_id
          )
        ''')
        .eq('team_members.player_id', userId)
        .eq('team_members.is_active', true);

    return response
        .map<TeamModel>(
          (json) => TeamModel.fromJson(_mapTeamFromDatabase(json)),
        )
        .toList();
  }

  // Agregar miembro al equipo
  Future<void> addTeamMember({
    required String teamId,
    required String userId,
    required String position,
  }) async {
    try {
      print('👥 Agregando miembro al equipo:');
      print('   Team ID: $teamId');
      print('   User ID: $userId');
      print('   Position: $position');

      await _supabase.from('team_members').insert({
        'team_id': teamId,
        'player_id': userId, // ✅ Usar player_id según esquema de BD
        'role': position.toLowerCase() == 'capitán' ? 'captain' : 'player',
        'position': position,
        'is_active': true,
        'joined_at': DateTime.now().toIso8601String(),
      });

      print('✅ Miembro agregado exitosamente');
    } catch (e) {
      print('❌ Error agregando miembro: $e');
      throw Exception('Error al agregar miembro al equipo: $e');
    }
  }

  // Obtener miembros del equipo
  Future<List<Map<String, dynamic>>> getTeamMembers(String teamId) async {
    final response = await _supabase
        .from('team_members')
        .select('''
          *,
          users (
            id,
            full_name,
            nickname,
            profile_image_url
          )
        ''')
        .eq('team_id', teamId)
        .eq('is_active', true);

    return List<Map<String, dynamic>>.from(response);
  }

  // Actualizar estadísticas del equipo después de un partido
  Future<void> updateTeamStats({
    required String teamId,
    required bool won,
    required bool draw,
    required int newElo,
  }) async {
    // Obtener estadísticas actuales
    final current =
        await _supabase
            .from('teams')
            .select('total_matches, wins, losses, draws')
            .eq('id', teamId)
            .single();

    final updatedData = {
      'total_matches': (current['total_matches'] as int) + 1,
      'elo_rating': newElo,
    };

    if (won) {
      updatedData['wins'] = (current['wins'] as int) + 1;
    } else if (draw) {
      updatedData['draws'] = (current['draws'] as int) + 1;
    } else {
      updatedData['losses'] = (current['losses'] as int) + 1;
    }

    await _supabase.from('teams').update(updatedData).eq('id', teamId);
  }

  // Buscar equipos por nombre
  Future<List<TeamModel>> searchTeams(String query) async {
    final response = await _supabase
        .from('teams')
        .select()
        .ilike('name', '%$query%')
        .order('elo_rating', ascending: false);

    return response.map<TeamModel>((json) => TeamModel.fromJson(json)).toList();
  }

  // Obtener top equipos (por ELO)
  Future<List<TeamModel>> getTopTeams({int limit = 10}) async {
    final response = await _supabase
        .from('teams')
        .select()
        .order('elo_rating', ascending: false)
        .limit(limit);

    return response.map<TeamModel>((json) => TeamModel.fromJson(json)).toList();
  }

  // Eliminar miembro del equipo
  Future<void> removeTeamMember({
    required String teamId,
    required String userId,
  }) async {
    await _supabase
        .from('team_members')
        .update({'is_active': false})
        .eq('team_id', teamId)
        .eq('player_id', userId);
  }

  // Transferir capitanía
  Future<void> transferCaptaincy({
    required String teamId,
    required String newCaptainId,
  }) async {
    await _supabase
        .from('teams')
        .update({'captain_id': newCaptainId})
        .eq('id', teamId);
  }

  // Eliminar equipo (solo para capitanes)
  Future<void> deleteTeam({
    required String teamId,
    required String userId,
  }) async {
    try {
      // Verificar que el usuario esté autenticado
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // Verificar que el usuario sea el capitán del equipo
      final teamResponse =
          await _supabase
              .from('teams')
              .select('captain_id')
              .eq('id', teamId)
              .single();

      if (teamResponse['captain_id'] != userId) {
        throw Exception('Solo el capitán puede eliminar el equipo');
      }

      // Eliminar en orden correcto para respetar foreign keys

      // Simplificado: solo eliminar lo que sabemos que existe
      try {
        // 1. Eliminar partidos públicos (si la tabla existe)
        await _supabase
            .from('public_matches')
            .delete()
            .or('host_team_id.eq.$teamId,accepted_team_id.eq.$teamId');
      } catch (e) {
        print('Tabla public_matches no existe o error: $e');
      }

      try {
        // 2. Eliminar recruitment_by_modality relacionado
        final recruitmentPosts = await _supabase
            .from('recruitment_posts')
            .select('id')
            .eq('team_id', teamId);

        if (recruitmentPosts.isNotEmpty) {
          for (final post in recruitmentPosts) {
            await _supabase
                .from('recruitment_by_modality')
                .delete()
                .eq('post_id', post['id']);
          }
        }
      } catch (e) {
        print('Error con recruitment: $e');
      }

      try {
        // 3. Eliminar posts de reclutamiento
        await _supabase
            .from('recruitment_posts')
            .delete()
            .eq('team_id', teamId);
      } catch (e) {
        print('Error con recruitment_posts: $e');
      }

      try {
        // 4. Eliminar registros de ELO por modalidad
        await _supabase
            .from('team_elo_by_modality')
            .delete()
            .eq('team_id', teamId);
      } catch (e) {
        print('Error con team_elo_by_modality: $e');
      }

      // 5. Finalmente eliminar el equipo (esta tabla sí debe existir)
      await _supabase.from('teams').delete().eq('id', teamId);

      print('Equipo eliminado exitosamente: $teamId');
    } catch (e) {
      print('Error al eliminar equipo: $e');
      throw Exception('Error al eliminar el equipo: $e');
    }
  }
}

// Provider para el servicio de equipos
final teamsServiceProvider = Provider<TeamsService>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return TeamsService(supabase);
});

// Provider para obtener equipos del usuario actual
final userTeamsProvider = FutureProvider<List<TeamModel>>((ref) async {
  // Escuchar cambios de autenticación para refrescar automáticamente al cambiar de cuenta
  ref.watch(authStateProvider);

  final supabase = ref.watch(supabaseProvider);
  final user = supabase.auth.currentUser;
  if (user == null) return [];

  final teamsService = ref.watch(teamsServiceProvider);
  return teamsService.getUserTeams(user.id);
});

// Provider para obtener top equipos
final topTeamsProvider = FutureProvider<List<TeamModel>>((ref) async {
  final teamsService = ref.watch(teamsServiceProvider);
  return teamsService.getTopTeams();
});

// Provider para obtener equipos por sector
final teamsBySectorProvider = FutureProvider.family<List<TeamModel>, String>((
  ref,
  sectorId,
) async {
  final teamsService = ref.watch(teamsServiceProvider);
  return teamsService.getTeamsBySector(sectorId);
});
