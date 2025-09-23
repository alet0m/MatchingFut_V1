import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_member_model.freezed.dart';
part 'team_member_model.g.dart';

@freezed
class TeamMemberModel with _$TeamMemberModel {
  const factory TeamMemberModel({
    required String id,
    required String teamId,
    required String userId,
    String? position,
    @Default(true) bool isActive,
    required DateTime joinedAt,
  }) = _TeamMemberModel;

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) =>
      _$TeamMemberModelFromJson(json);
}
