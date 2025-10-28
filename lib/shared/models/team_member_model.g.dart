// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_member_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TeamMemberModelImpl _$$TeamMemberModelImplFromJson(
  Map<String, dynamic> json,
) => _$TeamMemberModelImpl(
  id: json['id'] as String,
  teamId: json['teamId'] as String,
  userId: json['userId'] as String,
  position: json['position'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  joinedAt: DateTime.parse(json['joinedAt'] as String),
);

Map<String, dynamic> _$$TeamMemberModelImplToJson(
  _$TeamMemberModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'teamId': instance.teamId,
  'userId': instance.userId,
  'position': instance.position,
  'isActive': instance.isActive,
  'joinedAt': instance.joinedAt.toIso8601String(),
};
