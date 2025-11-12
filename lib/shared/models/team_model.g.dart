// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TeamModelImpl _$$TeamModelImplFromJson(Map<String, dynamic> json) =>
    _$TeamModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      tag: json['tag'] as String?,
      captainId: json['captainId'] as String?,
      sectorId: json['sectorId'] as String?,
      comunaId: json['comunaId'] as String?,
      modality:
          $enumDecodeNullable(_$FootballModalityEnumMap, json['modality']) ??
          FootballModality.futbolito,
      eloRating: (json['eloRating'] as num?)?.toInt() ?? 1200,
      leaguePoints: (json['leaguePoints'] as num?)?.toInt() ?? 100,
      leagueTier: json['leagueTier'] as String?,
      totalMatches: (json['totalMatches'] as num?)?.toInt() ?? 0,
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      losses: (json['losses'] as num?)?.toInt() ?? 0,
      draws: (json['draws'] as num?)?.toInt() ?? 0,
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$TeamModelImplToJson(_$TeamModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'tag': instance.tag,
      'captainId': instance.captainId,
      'sectorId': instance.sectorId,
      'comunaId': instance.comunaId,
      'modality': _$FootballModalityEnumMap[instance.modality]!,
      'eloRating': instance.eloRating,
      'leaguePoints': instance.leaguePoints,
      'leagueTier': instance.leagueTier,
      'totalMatches': instance.totalMatches,
      'wins': instance.wins,
      'losses': instance.losses,
      'draws': instance.draws,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$FootballModalityEnumMap = {
  FootballModality.futbolito: 'futbolito',
  FootballModality.futbol11: 'futbol11',
  FootballModality.babyFutbol: 'babyFutbol',
};
