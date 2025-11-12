import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';
import '../../public_matches/domain/public_match_model.dart';
import '../../../shared/models/comuna_model.dart';

class PublicMatchesService {
  final SupabaseClient _supabase;

  PublicMatchesService(this._supabase);

  // Load comunas for selector
  Future<List<ComunaModel>> loadComunas() async {
    final rows = await _supabase
        .from('comunas')
        .select('id, name, region_id, created_at')
        .order('name');
    return (rows as List)
        .map(
          (e) => ComunaModel(
            id: e['id'] as String,
            name: e['name'] as String,
            regionId: e['region_id'] as String? ?? '13',
            createdAt:
                DateTime.tryParse(e['created_at']?.toString() ?? '') ??
                DateTime.now(),
          ),
        )
        .toList();
  }

  // List public matches feed with optional filters
  Future<List<PublicMatchModel>> listPublicMatches({
    String? comunaId,
    int? myElo,
    bool filterByMyLevel = false,
  }) async {
    dynamic query = _supabase.from('public_matches').select('''
        id,
        title,
        description,
        match_date,
        comuna_id,
        location,
        modality_type,
        min_players,
        max_players,
        field_players,
        min_elo_range,
        max_elo_range,
        host_team_id,
        host_team_name,
        host_team_tag,
        status,
        created_at,
        created_by,
        match_id
      ''');

    query = query.eq('status', 'open');
    if (comunaId != null) {
      query = query.eq('comuna_id', comunaId);
    }
    if (filterByMyLevel && myElo != null) {
      query = query.lte('min_elo_range', myElo).gte('max_elo_range', myElo);
    }

    // Prefer upcoming date; fallback by created_at
    query = query
        .order('match_date', ascending: true, nullsFirst: true)
        .order('created_at', ascending: false);

    final data = await query;
    final list =
        (data as List<dynamic>)
            .map((e) => PublicMatchModel.fromMap(e as Map<String, dynamic>))
            .toList();
    return list;
  }

  // Load a single public match by id
  Future<PublicMatchModel> getPublicMatch(String id) async {
    final data =
        await _supabase
            .from('public_matches')
            .select(
              '''id, title, description, match_date, comuna_id, location, modality_type,
          min_players, max_players, field_players, min_elo_range, max_elo_range,
          host_team_id, host_team_name, host_team_tag, status, created_at, created_by, match_id''',
            )
            .eq('id', id)
            .single();

    return PublicMatchModel.fromMap(data as Map<String, dynamic>);
  }

  // Accept a public match: creates a match and closes the posting
  Future<Map<String, dynamic>> acceptPublicMatch({
    required String publicMatchId,
    required String awayTeamId,
  }) async {
    // Fetch public match
    final pm = await getPublicMatch(publicMatchId);
    if (pm.status != 'open') {
      throw Exception('Este partido ya no está disponible.');
    }
    if (pm.hostTeamId == awayTeamId) {
      throw Exception('No puedes desafiar tu propio partido.');
    }

    // Create a match using the most compatible columns
    final insert = {
      'home_team_id': pm.hostTeamId,
      'away_team_id': awayTeamId,
      'match_date': pm.matchDate?.toIso8601String(),
      'modality_type': pm.modalityType,
      'min_players': pm.minPlayers,
      'max_players': pm.maxPlayers,
      'field_players': pm.fieldPlayers,
      'comuna_id': pm.comunaId,
      'location': pm.location ?? 'Cancha a definir',
      'status': 'scheduled',
      'is_public': true,
    };

    final matchRow =
        await _supabase.from('matches').insert(insert).select().single();

    // Close the public match and link to match_id
    final updated =
        await _supabase
            .from('public_matches')
            .update({'status': 'matched', 'match_id': matchRow['id'] as String})
            .eq('id', publicMatchId)
            .select()
            .single();

    return {'match': matchRow, 'public_match': updated};
  }
}

// Provider
final publicMatchesServiceProvider = Provider<PublicMatchesService>((ref) {
  final client = ref.watch(supabaseProvider);
  return PublicMatchesService(client);
});
