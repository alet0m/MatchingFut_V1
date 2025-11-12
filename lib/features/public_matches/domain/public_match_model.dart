/// Lightweight model for the public_matches table (no codegen needed).
class PublicMatchModel {
  final String id;
  final String hostTeamId;
  final String? hostTeamName;
  final String? hostTeamTag;
  final String? title;
  final String? description;
  final DateTime? matchDate;
  final String? comunaId;
  final String? location;
  final String? modalityType;
  final int? minPlayers;
  final int? maxPlayers;
  final int? fieldPlayers;
  final int? minEloRange;
  final int? maxEloRange;
  final String status;
  final DateTime? createdAt;
  final String? createdBy;
  final String? matchId;

  const PublicMatchModel({
    required this.id,
    required this.hostTeamId,
    this.hostTeamName,
    this.hostTeamTag,
    this.title,
    this.description,
    this.matchDate,
    this.comunaId,
    this.location,
    this.modalityType,
    this.minPlayers,
    this.maxPlayers,
    this.fieldPlayers,
    this.minEloRange,
    this.maxEloRange,
    this.status = 'open',
    this.createdAt,
    this.createdBy,
    this.matchId,
  });

  factory PublicMatchModel.fromMap(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString());
    }

    return PublicMatchModel(
      id: json['id'] as String,
      hostTeamId: json['host_team_id'] as String,
      hostTeamName: json['host_team_name'] as String?,
      hostTeamTag: json['host_team_tag'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      matchDate: parseDate(json['match_date']),
      comunaId: json['comuna_id'] as String?,
      location: json['location'] as String?,
      modalityType: json['modality_type'] as String?,
      minPlayers: (json['min_players'] as num?)?.toInt(),
      maxPlayers: (json['max_players'] as num?)?.toInt(),
      fieldPlayers: (json['field_players'] as num?)?.toInt(),
      minEloRange: (json['min_elo_range'] as num?)?.toInt(),
      maxEloRange: (json['max_elo_range'] as num?)?.toInt(),
      status: (json['status'] as String?) ?? 'open',
      createdAt: parseDate(json['created_at']),
      createdBy: json['created_by'] as String?,
      matchId: json['match_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'host_team_id': hostTeamId,
    'host_team_name': hostTeamName,
    'host_team_tag': hostTeamTag,
    'title': title,
    'description': description,
    'match_date': matchDate?.toIso8601String(),
    'comuna_id': comunaId,
    'location': location,
    'modality_type': modalityType,
    'min_players': minPlayers,
    'max_players': maxPlayers,
    'field_players': fieldPlayers,
    'min_elo_range': minEloRange,
    'max_elo_range': maxEloRange,
    'status': status,
    'created_at': createdAt?.toIso8601String(),
    'created_by': createdBy,
    'match_id': matchId,
  };

  bool get isNew =>
      createdAt != null && DateTime.now().difference(createdAt!).inHours <= 24;

  bool get isSoon =>
      matchDate != null &&
      DateTime.now().difference(matchDate!).inHours >= -48 &&
      DateTime.now().isBefore(matchDate!);
}
