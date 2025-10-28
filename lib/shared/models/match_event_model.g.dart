// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MatchEventImpl _$$MatchEventImplFromJson(Map<String, dynamic> json) =>
    _$MatchEventImpl(
      id: json['id'] as String,
      matchId: json['matchId'] as String,
      eventType: json['eventType'] as String,
      playerId: json['playerId'] as String?,
      teamId: json['teamId'] as String,
      minute: (json['minute'] as num).toInt(),
      description: json['description'] as String?,
      extraData: json['extraData'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$MatchEventImplToJson(_$MatchEventImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'matchId': instance.matchId,
      'eventType': instance.eventType,
      'playerId': instance.playerId,
      'teamId': instance.teamId,
      'minute': instance.minute,
      'description': instance.description,
      'extraData': instance.extraData,
      'createdAt': instance.createdAt.toIso8601String(),
    };
