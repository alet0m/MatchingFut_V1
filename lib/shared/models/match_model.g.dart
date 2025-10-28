// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MatchModelImpl _$$MatchModelImplFromJson(Map<String, dynamic> json) =>
    _$MatchModelImpl(
      id: json['id'] as String,
      hostTeamId: json['hostTeamId'] as String,
      guestTeamId: json['guestTeamId'] as String?,
      hostTeamName: json['hostTeamName'] as String?,
      guestTeamName: json['guestTeamName'] as String?,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      location: json['location'] as String,
      matchType: json['matchType'] as String? ?? 'futbolito',
      status: json['status'] as String? ?? 'scheduled',
      isPublic: json['isPublic'] as bool? ?? false,
      description: json['description'] as String?,
      hostTeamScore: (json['hostTeamScore'] as num?)?.toInt(),
      guestTeamScore: (json['guestTeamScore'] as num?)?.toInt(),
      startedAt:
          json['startedAt'] == null
              ? null
              : DateTime.parse(json['startedAt'] as String),
      finishedAt:
          json['finishedAt'] == null
              ? null
              : DateTime.parse(json['finishedAt'] as String),
      createdBy: json['createdBy'] as String?,
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] == null
              ? null
              : DateTime.parse(json['updatedAt'] as String),
      homeTeamId: json['homeTeamId'] as String?,
      awayTeamId: json['awayTeamId'] as String?,
      canchaId: json['canchaId'] as String?,
      sectorId: json['sectorId'] as String?,
      matchDate:
          json['matchDate'] == null
              ? null
              : DateTime.parse(json['matchDate'] as String),
      homeScore: (json['homeScore'] as num?)?.toInt() ?? 0,
      awayScore: (json['awayScore'] as num?)?.toInt() ?? 0,
      eloChange: (json['eloChange'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$MatchModelImplToJson(_$MatchModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hostTeamId': instance.hostTeamId,
      'guestTeamId': instance.guestTeamId,
      'hostTeamName': instance.hostTeamName,
      'guestTeamName': instance.guestTeamName,
      'scheduledDate': instance.scheduledDate.toIso8601String(),
      'location': instance.location,
      'matchType': instance.matchType,
      'status': instance.status,
      'isPublic': instance.isPublic,
      'description': instance.description,
      'hostTeamScore': instance.hostTeamScore,
      'guestTeamScore': instance.guestTeamScore,
      'startedAt': instance.startedAt?.toIso8601String(),
      'finishedAt': instance.finishedAt?.toIso8601String(),
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'homeTeamId': instance.homeTeamId,
      'awayTeamId': instance.awayTeamId,
      'canchaId': instance.canchaId,
      'sectorId': instance.sectorId,
      'matchDate': instance.matchDate?.toIso8601String(),
      'homeScore': instance.homeScore,
      'awayScore': instance.awayScore,
      'eloChange': instance.eloChange,
    };
