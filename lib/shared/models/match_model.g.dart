// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MatchModelImpl _$$MatchModelImplFromJson(Map<String, dynamic> json) =>
    _$MatchModelImpl(
      id: json['id'] as String,
      homeTeamId: json['homeTeamId'] as String?,
      awayTeamId: json['awayTeamId'] as String?,
      canchaId: json['canchaId'] as String?,
      sectorId: json['sectorId'] as String?,
      matchDate:
          json['matchDate'] == null
              ? null
              : DateTime.parse(json['matchDate'] as String),
      status: json['status'] as String? ?? 'scheduled',
      homeScore: (json['homeScore'] as num?)?.toInt() ?? 0,
      awayScore: (json['awayScore'] as num?)?.toInt() ?? 0,
      eloChange: (json['eloChange'] as num?)?.toInt() ?? 0,
      createdBy: json['createdBy'] as String?,
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$MatchModelImplToJson(_$MatchModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'homeTeamId': instance.homeTeamId,
      'awayTeamId': instance.awayTeamId,
      'canchaId': instance.canchaId,
      'sectorId': instance.sectorId,
      'matchDate': instance.matchDate?.toIso8601String(),
      'status': instance.status,
      'homeScore': instance.homeScore,
      'awayScore': instance.awayScore,
      'eloChange': instance.eloChange,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
