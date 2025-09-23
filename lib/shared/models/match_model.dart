import 'package:freezed_annotation/freezed_annotation.dart';

part 'match_model.freezed.dart';
part 'match_model.g.dart';

@freezed
class MatchModel with _$MatchModel {
  const factory MatchModel({
    required String id,
    String? homeTeamId,
    String? awayTeamId,
    String? canchaId,
    String? sectorId,
    DateTime? matchDate,
    @Default('scheduled')
    String status, // scheduled, in_progress, finished, cancelled
    @Default(0) int homeScore,
    @Default(0) int awayScore,
    @Default(0) int eloChange,
    String? createdBy,
    DateTime? createdAt,
  }) = _MatchModel;

  factory MatchModel.fromJson(Map<String, dynamic> json) =>
      _$MatchModelFromJson(json);
}
