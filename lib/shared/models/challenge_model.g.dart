// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChallengeModelImpl _$$ChallengeModelImplFromJson(Map<String, dynamic> json) =>
    _$ChallengeModelImpl(
      id: json['id'] as String,
      challengerTeamId: json['challengerTeamId'] as String,
      challengedTeamId: json['challengedTeamId'] as String,
      message: json['message'] as String?,
      proposedDate:
          json['proposedDate'] == null
              ? null
              : DateTime.parse(json['proposedDate'] as String),
      canchaId: json['canchaId'] as String?,
      sectorId: json['sectorId'] as String?,
      status: json['status'] as String? ?? 'pending',
      createdBy: json['createdBy'] as String?,
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
      respondedAt:
          json['respondedAt'] == null
              ? null
              : DateTime.parse(json['respondedAt'] as String),
      respondedBy: json['respondedBy'] as String?,
      matchId: json['matchId'] as String?,
    );

Map<String, dynamic> _$$ChallengeModelImplToJson(
  _$ChallengeModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'challengerTeamId': instance.challengerTeamId,
  'challengedTeamId': instance.challengedTeamId,
  'message': instance.message,
  'proposedDate': instance.proposedDate?.toIso8601String(),
  'canchaId': instance.canchaId,
  'sectorId': instance.sectorId,
  'status': instance.status,
  'createdBy': instance.createdBy,
  'createdAt': instance.createdAt?.toIso8601String(),
  'respondedAt': instance.respondedAt?.toIso8601String(),
  'respondedBy': instance.respondedBy,
  'matchId': instance.matchId,
};
