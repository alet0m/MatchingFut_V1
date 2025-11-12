import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/public_matches_service.dart';
import '../../domain/public_match_model.dart';
import '../../../../shared/models/comuna_model.dart';
import '../../../teams/data/teams_service.dart';

// Selected comuna filter (nullable)
final selectedComunaIdProvider = StateProvider<String?>((ref) => null);

// Level filter: false = Todos, true = Mi nivel
final filterByMyLevelProvider = StateProvider<bool>((ref) => false);

// Comunas list
final comunasListProvider = FutureProvider<List<ComunaModel>>((ref) async {
  final service = ref.watch(publicMatchesServiceProvider);
  return service.loadComunas();
});

// Current team ELO (simple heuristic: take first user's team elo_rating)
final myTeamEloProvider = FutureProvider<int?>((ref) async {
  final teams = await ref.watch(userTeamsProvider.future);
  if (teams.isEmpty) return null;
  return teams.first.eloRating;
});

// Feed provider driven by filters
final publicMatchesFeedProvider = FutureProvider<List<PublicMatchModel>>((
  ref,
) async {
  final service = ref.watch(publicMatchesServiceProvider);
  final comunaId = ref.watch(selectedComunaIdProvider);
  final byLevel = ref.watch(filterByMyLevelProvider);
  final myElo = await ref.watch(myTeamEloProvider.future);

  return service.listPublicMatches(
    comunaId: comunaId,
    myElo: myElo,
    filterByMyLevel: byLevel,
  );
});

// Detail provider
final publicMatchDetailProvider =
    FutureProvider.family<PublicMatchModel, String>((ref, id) async {
      final service = ref.watch(publicMatchesServiceProvider);
      return service.getPublicMatch(id);
    });
