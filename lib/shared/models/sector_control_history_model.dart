// import 'package:freezed_annotation/freezed_annotation.dart';
// Temporalmente desactivando freezed hasta ejecutar build_runner
// part 'sector_control_history_model.freezed.dart';
// part 'sector_control_history_model.g.dart';

class SectorControlHistoryModel {
  final String id;
  final String sectorId;
  final String teamId;
  final DateTime controlStart;
  final DateTime? controlEnd;
  final int? eloAtStart;
  final int? eloAtEnd;
  final int? totalDays;
  final String? matchId;
  final String? lossMatchId;
  final DateTime createdAt;

  const SectorControlHistoryModel({
    required this.id,
    required this.sectorId,
    required this.teamId,
    required this.controlStart,
    this.controlEnd,
    this.eloAtStart,
    this.eloAtEnd,
    this.totalDays,
    this.matchId,
    this.lossMatchId,
    required this.createdAt,
  });

  factory SectorControlHistoryModel.fromJson(Map<String, dynamic> json) {
    return SectorControlHistoryModel(
      id: json['id'] as String,
      sectorId: json['sectorId'] as String,
      teamId: json['teamId'] as String,
      controlStart: DateTime.parse(json['controlStart'] as String),
      controlEnd:
          json['controlEnd'] != null
              ? DateTime.parse(json['controlEnd'] as String)
              : null,
      eloAtStart: json['eloAtStart'] as int?,
      eloAtEnd: json['eloAtEnd'] as int?,
      totalDays: json['totalDays'] as int?,
      matchId: json['matchId'] as String?,
      lossMatchId: json['lossMatchId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sectorId': sectorId,
      'teamId': teamId,
      'controlStart': controlStart.toIso8601String(),
      'controlEnd': controlEnd?.toIso8601String(),
      'eloAtStart': eloAtStart,
      'eloAtEnd': eloAtEnd,
      'totalDays': totalDays,
      'matchId': matchId,
      'lossMatchId': lossMatchId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
