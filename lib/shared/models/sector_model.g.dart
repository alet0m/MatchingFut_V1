// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sector_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SectorModelImpl _$$SectorModelImplFromJson(Map<String, dynamic> json) =>
    _$SectorModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      comunaId: json['comunaId'] as String,
      description: json['description'] as String?,
      currentChampionId: json['currentChampionId'] as String?,
      totalMatches: (json['totalMatches'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$SectorModelImplToJson(_$SectorModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'comunaId': instance.comunaId,
      'description': instance.description,
      'currentChampionId': instance.currentChampionId,
      'totalMatches': instance.totalMatches,
      'createdAt': instance.createdAt.toIso8601String(),
    };
