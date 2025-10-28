import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PublicMatch {
  final String id;
  final String hostTeamId;
  final String title;
  final String? description;
  final DateTime matchDate;
  final String? venueId;
  final String comuna;
  final int? minEloRange;
  final int? maxEloRange;
  final String status;
  final String? acceptedTeamId;
  final DateTime createdAt;
  final DateTime expiresAt;

  // Datos del equipo host (join)
  final String hostTeamName;
  final String? hostTeamTag;
  final String? hostTeamLogoUrl;

  PublicMatch({
    required this.id,
    required this.hostTeamId,
    required this.title,
    this.description,
    required this.matchDate,
    this.venueId,
    required this.comuna,
    this.minEloRange,
    this.maxEloRange,
    required this.status,
    this.acceptedTeamId,
    required this.createdAt,
    required this.expiresAt,
    required this.hostTeamName,
    this.hostTeamTag,
    this.hostTeamLogoUrl,
  });

  factory PublicMatch.fromJson(Map<String, dynamic> json) {
    return PublicMatch(
      id: json['id'],
      hostTeamId: json['host_team_id'],
      title: json['title'],
      description: json['description'],
      matchDate: DateTime.parse(json['match_date']),
      venueId: json['venue_id'],
      comuna: json['comuna'],
      minEloRange: json['min_elo_range'],
      maxEloRange: json['max_elo_range'],
      status: json['status'],
      acceptedTeamId: json['accepted_team_id'],
      createdAt: DateTime.parse(json['created_at']),
      expiresAt: DateTime.parse(json['expires_at']),
      hostTeamName: json['host_team']['name'] ?? 'Equipo Desconocido',
      hostTeamTag: json['host_team']['tag'],
      hostTeamLogoUrl: json['host_team']['logo_url'],
    );
  }
}

class PublicMatchesNotifier
    extends StateNotifier<AsyncValue<List<PublicMatch>>> {
  PublicMatchesNotifier() : super(const AsyncValue.data([]));

  final _supabase = Supabase.instance.client;

  Future<void> searchPublicMatches(String comuna) async {
    state = const AsyncValue.loading();

    try {
      final response = await _supabase
          .from('public_matches')
          .select('''
            id,
            host_team_id,
            title,
            description,
            match_date,
            venue_id,
            comuna,
            min_elo_range,
            max_elo_range,
            status,
            accepted_team_id,
            created_at,
            expires_at,
            host_team:teams!host_team_id (
              name,
              tag,
              logo_url
            )
          ''')
          .eq('comuna', comuna)
          .eq('status', 'open')
          .gt('expires_at', DateTime.now().toIso8601String())
          .order('match_date', ascending: true);

      final matches =
          (response as List)
              .map((match) => PublicMatch.fromJson(match))
              .toList();

      state = AsyncValue.data(matches);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
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

      return true;
    } catch (error) {
      print('Error creating public match: $error');
      return false;
    }
  }

  Future<bool> applyToMatch(
    String publicMatchId,
    String teamId,
    String? message,
  ) async {
    try {
      await _supabase.from('match_applications').insert({
        'public_match_id': publicMatchId,
        'applicant_team_id': teamId,
        'message': message,
      });

      return true;
    } catch (error) {
      print('Error applying to match: $error');
      return false;
    }
  }

  void clearMatches() {
    state = const AsyncValue.data([]);
  }
}

final publicMatchesProvider =
    StateNotifierProvider<PublicMatchesNotifier, AsyncValue<List<PublicMatch>>>(
      (ref) {
        return PublicMatchesNotifier();
      },
    );

// Provider para obtener las comunas disponibles
final availableComunasProvider = FutureProvider<List<String>>((ref) async {
  final supabase = Supabase.instance.client;

  try {
    final response = await supabase
        .from('venues')
        .select('commune')
        .not('commune', 'is', null);

    final comunas =
        (response as List)
            .map((venue) => venue['commune'] as String)
            .where((comuna) => comuna.isNotEmpty)
            .toSet()
            .toList();

    comunas.sort();
    return comunas;
  } catch (error) {
    // Fallback a comunas predefinidas
    return [
      'Quilicura',
      'Las Condes',
      'Providencia',
      'Santiago Centro',
      'Ñuñoa',
      'La Florida',
      'Maipú',
      'Puente Alto',
    ];
  }
});
