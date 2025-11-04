class TeamInvitationModel {
  final String id;
  final String teamId;
  final String inviterUserId;
  final String invitedUserId;
  final String status; // pending | accepted | rejected | expired | cancelled
  final DateTime createdAt;
  final DateTime? respondedAt;

  TeamInvitationModel({
    required this.id,
    required this.teamId,
    required this.inviterUserId,
    required this.invitedUserId,
    required this.status,
    required this.createdAt,
    this.respondedAt,
  });

  factory TeamInvitationModel.fromMap(Map<String, dynamic> map) {
    return TeamInvitationModel(
      id: (map['id'] ?? '').toString(),
      teamId: (map['team_id'] ?? '').toString(),
      inviterUserId: (map['inviter_user_id'] ?? '').toString(),
      invitedUserId: (map['invited_user_id'] ?? '').toString(),
      status: (map['status'] ?? 'pending').toString(),
      createdAt:
          DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.now(),
      respondedAt:
          map['responded_at'] != null
              ? DateTime.tryParse(map['responded_at'].toString())
              : null,
    );
  }
}

// Vista enriquecida para UI
class TeamInvitationView {
  final TeamInvitationModel invitation;
  final String teamName;
  final String inviterName;

  TeamInvitationView({
    required this.invitation,
    required this.teamName,
    required this.inviterName,
  });
}
