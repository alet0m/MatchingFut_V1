// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cancha_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CanchaModelImpl _$$CanchaModelImplFromJson(Map<String, dynamic> json) =>
    _$CanchaModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      comunaId: json['comunaId'] as String?,
      address: json['address'] as String?,
      fieldType: json['fieldType'] as String?,
      surfaceType: json['surfaceType'] as String?,
      hasLighting: json['hasLighting'] as bool? ?? false,
      capacity: (json['capacity'] as num?)?.toInt(),
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble(),
      contactPhone: json['contactPhone'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$CanchaModelImplToJson(_$CanchaModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'comunaId': instance.comunaId,
      'address': instance.address,
      'fieldType': instance.fieldType,
      'surfaceType': instance.surfaceType,
      'hasLighting': instance.hasLighting,
      'capacity': instance.capacity,
      'hourlyRate': instance.hourlyRate,
      'contactPhone': instance.contactPhone,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
    };
