// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_elo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TeamEloModelImpl _$$TeamEloModelImplFromJson(Map<String, dynamic> json) =>
    _$TeamEloModelImpl(
      id: json['id'] as String,
      teamId: json['teamId'] as String,
      modality: $enumDecode(_$FootballModalityEnumMap, json['modality']),
      eloRating: (json['eloRating'] as num?)?.toInt() ?? 1200,
      matchesPlayed: (json['matchesPlayed'] as num?)?.toInt() ?? 0,
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      losses: (json['losses'] as num?)?.toInt() ?? 0,
      draws: (json['draws'] as num?)?.toInt() ?? 0,
      goalsFor: (json['goalsFor'] as num?)?.toInt() ?? 0,
      goalsAgainst: (json['goalsAgainst'] as num?)?.toInt() ?? 0,
      lastMatchDate:
          json['lastMatchDate'] == null
              ? null
              : DateTime.parse(json['lastMatchDate'] as String),
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] == null
              ? null
              : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$TeamEloModelImplToJson(_$TeamEloModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teamId': instance.teamId,
      'modality': _$FootballModalityEnumMap[instance.modality]!,
      'eloRating': instance.eloRating,
      'matchesPlayed': instance.matchesPlayed,
      'wins': instance.wins,
      'losses': instance.losses,
      'draws': instance.draws,
      'goalsFor': instance.goalsFor,
      'goalsAgainst': instance.goalsAgainst,
      'lastMatchDate': instance.lastMatchDate?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$FootballModalityEnumMap = {
  FootballModality.futbolito: 'futbolito',
  FootballModality.futbol11: 'futbol11',
  FootballModality.babyFutbol: 'babyFutbol',
};

_$PlayerModalityStatsImpl _$$PlayerModalityStatsImplFromJson(
  Map<String, dynamic> json,
) => _$PlayerModalityStatsImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  modality: $enumDecode(_$FootballModalityEnumMap, json['modality']),
  skillLevel:
      $enumDecodeNullable(_$SkillLevelEnumMap, json['skillLevel']) ??
      SkillLevel.principiante,
  preferredPosition: json['preferredPosition'] as String?,
  matchesPlayed: (json['matchesPlayed'] as num?)?.toInt() ?? 0,
  goals: (json['goals'] as num?)?.toInt() ?? 0,
  assists: (json['assists'] as num?)?.toInt() ?? 0,
  ratingAvg: (json['ratingAvg'] as num?)?.toDouble() ?? 0.0,
  isActive: json['isActive'] as bool? ?? true,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$PlayerModalityStatsImplToJson(
  _$PlayerModalityStatsImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'modality': _$FootballModalityEnumMap[instance.modality]!,
  'skillLevel': _$SkillLevelEnumMap[instance.skillLevel]!,
  'preferredPosition': instance.preferredPosition,
  'matchesPlayed': instance.matchesPlayed,
  'goals': instance.goals,
  'assists': instance.assists,
  'ratingAvg': instance.ratingAvg,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$SkillLevelEnumMap = {
  SkillLevel.principiante: 'principiante',
  SkillLevel.intermedio: 'intermedio',
  SkillLevel.avanzado: 'avanzado',
  SkillLevel.profesional: 'profesional',
};
