import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String fullName,
    String? nickname,
    DateTime? dateOfBirth,
    int? age,
    String? comunaId,
    String? sectorName,
    String? profileImageUrl,
    @Default(false) bool isEmailVerified,
    @Default(false) bool hasCompletedOnboarding,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
