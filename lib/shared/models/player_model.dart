import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_model.freezed.dart';
part 'player_model.g.dart';

@freezed
class PlayerModel with _$PlayerModel {
  const factory PlayerModel({
    required String id,
    required String userId,
    required String teamId,
    required String name,
    String? email,
    String? position, // Portero, Defensa, Mediocampo, Delantero
    @Default(1200) int elo,
    @Default(0) int goalsScored,
    @Default(0) int assists,
    @Default(0) int yellowCards,
    @Default(0) int redCards,
    @Default(true) bool isActive,
    @Default(false) bool isCaptain,
    DateTime? joinedAt,
    DateTime? createdAt,
  }) = _PlayerModel;

  factory PlayerModel.fromJson(Map<String, dynamic> json) =>
      _$PlayerModelFromJson(json);
}
