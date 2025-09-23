import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/models/team_model.dart';

class TeamSearchNotifier extends StateNotifier<AsyncValue<List<TeamModel>>> {
  TeamSearchNotifier() : super(const AsyncValue.data([]));

  final _supabase = Supabase.instance.client;

  Future<void> searchTeams(String query) async {
    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final response = await _supabase
          .from('teams')
          .select(
            'id, name, tag, description, logo_url, member_ids, captain_id, comuna_id, elo_rating, total_matches, wins, losses, draws, created_at',
          )
          .or('name.ilike.%$query%,tag.ilike.%$query%')
          .eq('is_active', true)
          .limit(20);

      final teams =
          response
              .map<TeamModel>(
                (team) => TeamModel(
                  id: team['id'],
                  name: team['name'],
                  tag: team['tag'],
                  captainId: team['captain_id'],
                  comunaId: team['comuna_id'] ?? 'quilicura',
                  eloRating: team['elo_rating'] ?? 1200,
                  totalMatches: team['total_matches'] ?? 0,
                  wins: team['wins'] ?? 0,
                  losses: team['losses'] ?? 0,
                  draws: team['draws'] ?? 0,
                  createdAt:
                      team['created_at'] != null
                          ? DateTime.parse(team['created_at'])
                          : DateTime.now(),
                ),
              )
              .toList();

      state = AsyncValue.data(teams);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<TeamModel?> getTeamById(String teamId) async {
    try {
      final response =
          await _supabase
              .from('teams')
              .select(
                'id, name, tag, description, captain_id, comuna_id, elo_rating, total_matches, wins, losses, draws, created_at',
              )
              .eq('id', teamId)
              .single();

      return TeamModel(
        id: response['id'],
        name: response['name'],
        tag: response['tag'],
        captainId: response['captain_id'],
        comunaId: response['comuna_id'] ?? 'quilicura',
        eloRating: response['elo_rating'] ?? 1200,
        totalMatches: response['total_matches'] ?? 0,
        wins: response['wins'] ?? 0,
        losses: response['losses'] ?? 0,
        draws: response['draws'] ?? 0,
        createdAt:
            response['created_at'] != null
                ? DateTime.parse(response['created_at'])
                : DateTime.now(),
      );
    } catch (error) {
      return null;
    }
  }

  void clearResults() {
    state = const AsyncValue.data([]);
  }
}

final teamSearchProvider =
    StateNotifierProvider<TeamSearchNotifier, AsyncValue<List<TeamModel>>>((
      ref,
    ) {
      return TeamSearchNotifier();
    });

// Provider para obtener el equipo actual del usuario
final currentUserTeamProvider = FutureProvider<TeamModel?>((ref) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) return null;

  try {
    final response =
        await supabase
            .from('teams')
            .select(
              'id, name, tag, description, captain_id, comuna_id, elo_rating, total_matches, wins, losses, draws, created_at',
            )
            .contains('member_ids', [user.id])
            .eq('is_active', true)
            .maybeSingle();

    if (response == null) return null;

    return TeamModel(
      id: response['id'],
      name: response['name'],
      tag: response['tag'],
      captainId: response['captain_id'],
      comunaId: response['comuna_id'] ?? 'quilicura',
      eloRating: response['elo_rating'] ?? 1200,
      totalMatches: response['total_matches'] ?? 0,
      wins: response['wins'] ?? 0,
      losses: response['losses'] ?? 0,
      draws: response['draws'] ?? 0,
      createdAt:
          response['created_at'] != null
              ? DateTime.parse(response['created_at'])
              : DateTime.now(),
    );
  } catch (error) {
    return null;
  }
});
