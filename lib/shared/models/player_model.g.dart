// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlayerModelImpl _$$PlayerModelImplFromJson(Map<String, dynamic> json) =>
    _$PlayerModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      teamId: json['teamId'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      position: json['position'] as String?,
      elo: (json['elo'] as num?)?.toInt() ?? 1200,
      goalsScored: (json['goalsScored'] as num?)?.toInt() ?? 0,
      assists: (json['assists'] as num?)?.toInt() ?? 0,
      yellowCards: (json['yellowCards'] as num?)?.toInt() ?? 0,
      redCards: (json['redCards'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      isCaptain: json['isCaptain'] as bool? ?? false,
      joinedAt:
          json['joinedAt'] == null
              ? null
              : DateTime.parse(json['joinedAt'] as String),
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$PlayerModelImplToJson(_$PlayerModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'teamId': instance.teamId,
      'name': instance.name,
      'email': instance.email,
      'position': instance.position,
      'elo': instance.elo,
      'goalsScored': instance.goalsScored,
      'assists': instance.assists,
      'yellowCards': instance.yellowCards,
      'redCards': instance.redCards,
      'isActive': instance.isActive,
      'isCaptain': instance.isCaptain,
      'joinedAt': instance.joinedAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
    };
