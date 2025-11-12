import 'package:freezed_annotation/freezed_annotation.dart';
import 'football_modality.dart';

part 'team_model.freezed.dart';
part 'team_model.g.dart';

@freezed
class TeamModel with _$TeamModel {
  const TeamModel._(); // Constructor privado necesario para getters

  const factory TeamModel({
    required String id,
    required String name,
    String? tag,
    String? captainId,
    String? sectorId,
    String? comunaId, // ✅ Coincidir con base de datos
    @Default(FootballModality.futbolito) FootballModality modality,
    @Default(1200)
    int eloRating, // ✅ Coincidir con base de datos (no averageElo)
    // Puntos de liga acumulados (ranking principal)
    @Default(100) int leaguePoints,
    // Tier/slug de la liga (pichanga, barrio, etc.)
    String? leagueTier,
    @Default(0) int totalMatches,
    @Default(0) int wins,
    @Default(0) int losses,
    @Default(0) int draws,
    DateTime? createdAt,
  }) = _TeamModel;

  // Getter para compatibilidad con código existente
  String get comuna => comunaId ?? 'quilicura';

  factory TeamModel.fromJson(Map<String, dynamic> json) =>
      _$TeamModelFromJson(json);
}
