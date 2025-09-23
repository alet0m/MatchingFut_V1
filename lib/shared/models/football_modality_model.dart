// import 'package:freezed_annotation/freezed_annotation.dart';
// Temporalmente desactivando freezed hasta ejecutar build_runner
// part 'football_modality_model.freezed.dart';
// part 'football_modality_model.g.dart';

class FootballModalityModel {
  final int id;
  final String name;
  final String code;
  final int playersPerTeam;
  final int minPlayers;
  final int maxPlayers;
  final int fieldPlayers;
  final String? description;
  final String? colorHex;

  const FootballModalityModel({
    required this.id,
    required this.name,
    required this.code,
    required this.playersPerTeam,
    required this.minPlayers,
    required this.maxPlayers,
    required this.fieldPlayers,
    this.description,
    this.colorHex,
  });

  factory FootballModalityModel.fromJson(Map<String, dynamic> json) {
    return FootballModalityModel(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String,
      playersPerTeam: json['playersPerTeam'] as int,
      minPlayers: json['minPlayers'] as int,
      maxPlayers: json['maxPlayers'] as int,
      fieldPlayers: json['fieldPlayers'] as int,
      description: json['description'] as String?,
      colorHex: json['colorHex'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'playersPerTeam': playersPerTeam,
      'minPlayers': minPlayers,
      'maxPlayers': maxPlayers,
      'fieldPlayers': fieldPlayers,
      'description': description,
      'colorHex': colorHex,
    };
  }
}
