import 'package:freezed_annotation/freezed_annotation.dart';

part 'challenge_model.freezed.dart';
part 'challenge_model.g.dart';

@freezed
class ChallengeModel with _$ChallengeModel {
  const factory ChallengeModel({
    required String id,
    required String challengerTeamId,
    required String challengedTeamId,
    String? message,
    DateTime? proposedDate,
    String? canchaId,
    String? sectorId,
    @Default('pending') String status, // pending, accepted, rejected, expired
    String? createdBy,
    DateTime? createdAt,
    DateTime? respondedAt,
    String? respondedBy,
    String? matchId, // ID del partido creado al aceptar
  }) = _ChallengeModel;

  factory ChallengeModel.fromJson(Map<String, dynamic> json) =>
      _$ChallengeModelFromJson(json);
}
