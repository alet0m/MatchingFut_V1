import 'package:freezed_annotation/freezed_annotation.dart';

part 'match_model.freezed.dart';
part 'match_model.g.dart';

@freezed
class MatchModel with _$MatchModel {
  const factory MatchModel({
    required String id,
    required String hostTeamId,
    String? guestTeamId,
    String? hostTeamName,
    String? guestTeamName,
    required DateTime scheduledDate,
    required String location,
    @Default('futbolito') String matchType, // futbolito, futbol
    @Default('scheduled') String status, // scheduled, live, finished, cancelled
    @Default(false) bool isPublic,
    String? description,
    int? hostTeamScore,
    int? guestTeamScore,
    DateTime? startedAt,
    DateTime? finishedAt,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    // Campos legacy para compatibilidad
    String? homeTeamId,
    String? awayTeamId,
    String? canchaId,
    String? sectorId,
    DateTime? matchDate,
    @Default(0) int homeScore,
    @Default(0) int awayScore,
    @Default(0) int eloChange,
  }) = _MatchModel;

  factory MatchModel.fromJson(Map<String, dynamic> json) =>
      _$MatchModelFromJson(json);
}
