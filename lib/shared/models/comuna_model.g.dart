// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comuna_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ComunaModelImpl _$$ComunaModelImplFromJson(Map<String, dynamic> json) =>
    _$ComunaModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      regionId: json['regionId'] as String,
      isActive: json['isActive'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ComunaModelImplToJson(_$ComunaModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'regionId': instance.regionId,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
    };
