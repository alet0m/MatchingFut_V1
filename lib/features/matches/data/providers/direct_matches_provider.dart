import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Inicialización recomendada en main.dart:
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Supabase.initialize(
//     url: '',
//     anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlucGlicXNhcmN5b3lwb3ZpZ2xmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMyNDY0OTMsImV4cCI6MjA2ODgyMjQ5M30.KQfBPOIAg3LtQVkUXo9QZgXMzSfMwsjfofowT2EyMQ4',
//   );
//   runApp(const MyApp());
// }

enum MatchSource { direct, public }

class DirectMatchesNotifier extends StateNotifier<AsyncValue<void>> {
  DirectMatchesNotifier() : super(const AsyncValue.data(null));

  final _supabase = Supabase.instance.client;

  Future<bool> createDirectChallenge({
    required String homeTeamId,
    required String awayTeamId,
    required DateTime matchDate,
    String? venueId,
    String? message,
  }) async {
    state = const AsyncValue.loading();

    try {
      // Crear el partido directo
      await _supabase.from('matches').insert({
        'home_team_id': homeTeamId,
        'away_team_id': awayTeamId,
        'date_played': matchDate.toIso8601String(),
        'venue_id': venueId,
        'match_message': message,
        'match_source': 'direct',
        'elo_multiplier': 0.8, // Multiplicador reducido para desafíos directos
        'match_type': 'friendly',
      });

      state = const AsyncValue.data(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      debugPrint('Error creating direct challenge: $error');
      return false;
    }
  }

  Future<bool> createPublicMatch({
    required String hostTeamId,
    required String title,
    String? description,
    required DateTime matchDate,
    String? venueId,
    required String comuna,
    int? minEloRange,
    int? maxEloRange,
  }) async {
    state = const AsyncValue.loading();

    try {
      await _supabase.from('public_matches').insert({
        'host_team_id': hostTeamId,
        'title': title,
        'description': description,
        'match_date': matchDate.toIso8601String(),
        'venue_id': venueId,
        'comuna': comuna,
        'min_elo_range': minEloRange,
        'max_elo_range': maxEloRange,
      });

      state = const AsyncValue.data(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      debugPrint('Error creating public match: $error');
      return false;
    }
  }
}

final directMatchesProvider =
    StateNotifierProvider<DirectMatchesNotifier, AsyncValue<void>>((ref) {
      return DirectMatchesNotifier();
    });

// Provider para obtener las estadísticas ELO del equipo
final teamEloStatsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, teamId) async {
      final supabase = Supabase.instance.client;

      try {
        // Obtener estadísticas del equipo basadas en los partidos
        final matchesResponse = await supabase
            .from('matches')
            .select('score_player1, score_player2, home_team_id, away_team_id')
            .or('home_team_id.eq.$teamId,away_team_id.eq.$teamId')
            .eq('verified', true);

        int wins = 0;
        int losses = 0;
        int draws = 0;

        for (final match in matchesResponse) {
          final isHome = match['home_team_id'] == teamId;
          final homeScore = match['score_player1'] ?? 0;
          final awayScore = match['score_player2'] ?? 0;

          if (isHome) {
            if (homeScore > awayScore) {
              wins++;
            } else if (homeScore < awayScore)
              losses++;
            else
              draws++;
          } else {
            if (awayScore > homeScore) {
              wins++;
            } else if (awayScore < homeScore)
              losses++;
            else
              draws++;
          }
        }

        // Calcular ELO aproximado basado en rendimiento
        final totalMatches = wins + losses + draws;
        final winRate = totalMatches > 0 ? wins / totalMatches : 0.0;
        final baseElo = 1200;
        final calculatedElo =
            (baseElo + (winRate * 400) + (wins * 10) - (losses * 5)).round();

        return {
          'elo': calculatedElo,
          'wins': wins,
          'losses': losses,
          'draws': draws,
          'totalMatches': totalMatches,
          'winRate': winRate,
        };
      } catch (error) {
        return {
          'elo': 1200,
          'wins': 0,
          'losses': 0,
          'draws': 0,
          'totalMatches': 0,
          'winRate': 0.0,
        };
      }
    });
