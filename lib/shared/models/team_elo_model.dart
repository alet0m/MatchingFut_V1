import 'package:freezed_annotation/freezed_annotation.dart';
import 'football_modality.dart';

part 'team_elo_model.freezed.dart';
part 'team_elo_model.g.dart';

@freezed
class TeamEloModel with _$TeamEloModel {
  const factory TeamEloModel({
    required String id,
    required String teamId,
    required FootballModality modality,
    @Default(1200) int eloRating,
    @Default(0) int matchesPlayed,
    @Default(0) int wins,
    @Default(0) int losses,
    @Default(0) int draws,
    @Default(0) int goalsFor,
    @Default(0) int goalsAgainst,
    DateTime? lastMatchDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _TeamEloModel;

  factory TeamEloModel.fromJson(Map<String, dynamic> json) =>
      _$TeamEloModelFromJson(json);
}

@freezed
class PlayerModalityStats with _$PlayerModalityStats {
  const factory PlayerModalityStats({
    required String id,
    required String userId,
    required FootballModality modality,
    @Default(SkillLevel.principiante) SkillLevel skillLevel,
    String? preferredPosition,
    @Default(0) int matchesPlayed,
    @Default(0) int goals,
    @Default(0) int assists,
    @Default(0.0) double ratingAvg,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PlayerModalityStats;

  factory PlayerModalityStats.fromJson(Map<String, dynamic> json) =>
      _$PlayerModalityStatsFromJson(json);
}
