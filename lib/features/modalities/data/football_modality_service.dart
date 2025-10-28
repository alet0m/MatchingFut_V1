import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/football_modality_model.dart';
import '../../../core/config/supabase_config.dart';

class FootballModalityService {
  final SupabaseClient _supabase;

  FootballModalityService(this._supabase);

  // Helper method para mapear datos
  Map<String, dynamic> _mapModalityFromDatabase(
    Map<String, dynamic> dbModality,
  ) {
    return {
      'id': dbModality['id'],
      'name': dbModality['name'],
      'code': dbModality['code'],
      'playersPerTeam': dbModality['players_per_team'],
      'minPlayers': dbModality['min_players'],
      'maxPlayers': dbModality['max_players'],
      'fieldPlayers': dbModality['field_players'],
      'description': dbModality['description'],
      'colorHex': dbModality['color_hex'],
    };
  }

  // Obtener todas las modalidades
  Future<List<FootballModalityModel>> getAllModalities() async {
    final response = await _supabase
        .from('football_modalities')
        .select()
        .order('players_per_team');

    return response
        .map<FootballModalityModel>(
          (json) =>
              FootballModalityModel.fromJson(_mapModalityFromDatabase(json)),
        )
        .toList();
  }

  // Obtener modalidad por ID
  Future<FootballModalityModel> getModalityById(int id) async {
    final response =
        await _supabase
            .from('football_modalities')
            .select()
            .eq('id', id)
            .single();

    return FootballModalityModel.fromJson(_mapModalityFromDatabase(response));
  }

  // Obtener modalidad por código
  Future<FootballModalityModel?> getModalityByCode(String code) async {
    final response = await _supabase
        .from('football_modalities')
        .select()
        .eq('code', code);

    if (response.isEmpty) {
      return null;
    }

    return FootballModalityModel.fromJson(
      _mapModalityFromDatabase(response.first),
    );
  }
}

// Provider para el servicio de modalidades
final footballModalityServiceProvider = Provider<FootballModalityService>((
  ref,
) {
  final supabase = ref.watch(supabaseProvider);
  return FootballModalityService(supabase);
});

// Provider para obtener todas las modalidades
final allModalitiesProvider = FutureProvider<List<FootballModalityModel>>((
  ref,
) async {
  final modalityService = ref.watch(footballModalityServiceProvider);
  return modalityService.getAllModalities();
});

// Provider para obtener modalidad por ID
final modalityByIdProvider = FutureProvider.family<FootballModalityModel, int>((
  ref,
  id,
) async {
  final modalityService = ref.watch(footballModalityServiceProvider);
  return modalityService.getModalityById(id);
});

// Provider para obtener modalidad por código
final modalityByCodeProvider =
    FutureProvider.family<FootballModalityModel?, String>((ref, code) async {
      final modalityService = ref.watch(footballModalityServiceProvider);
      return modalityService.getModalityByCode(code);
    });
