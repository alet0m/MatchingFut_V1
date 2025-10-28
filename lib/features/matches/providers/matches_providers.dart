import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/matches_service_enhanced.dart';
import '../../../../shared/models/match_model.dart';

// Provider del servicio de partidos
final matchesServiceProvider = Provider<MatchesServiceEnhanced>((ref) {
  return MatchesServiceEnhanced();
});

// Provider para partidos públicos
final publicMatchesProvider = FutureProvider<List<MatchModel>>((ref) async {
  final service = ref.read(matchesServiceProvider);
  return service.getPublicMatches();
});

// Provider para mis partidos
final myMatchesProvider = FutureProvider<List<MatchModel>>((ref) async {
  final service = ref.read(matchesServiceProvider);
  return service.getMyMatches();
});

// Provider para partidos en vivo
final liveMatchesProvider = FutureProvider<List<MatchModel>>((ref) async {
  final service = ref.read(matchesServiceProvider);
  return service.getLiveMatches();
});

// Provider para historial de partidos
final matchHistoryProvider = FutureProvider<List<MatchModel>>((ref) async {
  final service = ref.read(matchesServiceProvider);
  return service.getMatchHistory();
});

// Provider para un partido específico
final matchProvider = FutureProvider.family<MatchModel?, String>((
  ref,
  matchId,
) async {
  final service = ref.read(matchesServiceProvider);
  return service.getMatch(matchId);
});

// Provider para partidos por equipo
final teamMatchesProvider = FutureProvider.family<List<MatchModel>, String>((
  ref,
  teamId,
) async {
  final service = ref.read(matchesServiceProvider);
  return service.getTeamMatches(teamId);
});

// Provider para estadísticas de partidos
final matchStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.read(matchesServiceProvider);
  return service.getMatchStats();
});
