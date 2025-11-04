// Plain Dart model for team messages

/// Team message model for clan/team chat
/// Minimal plain Dart model to avoid codegen requirements.
class TeamMessage {
  final String id;
  final String teamId;
  final String userId;
  final String content;
  final DateTime createdAt;
  final DateTime? editedAt;
  // UI-only flags (not persisted):
  final bool optimistic; // true if locally created before server ack
  final bool sending; // true while RPC in-flight
  final bool failed; // true if send/update failed

  const TeamMessage({
    required this.id,
    required this.teamId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.editedAt,
    this.optimistic = false,
    this.sending = false,
    this.failed = false,
  });

  TeamMessage copyWith({
    String? id,
    String? teamId,
    String? userId,
    String? content,
    DateTime? createdAt,
    DateTime? editedAt,
    bool? optimistic,
    bool? sending,
    bool? failed,
  }) {
    return TeamMessage(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
      optimistic: optimistic ?? this.optimistic,
      sending: sending ?? this.sending,
      failed: failed ?? this.failed,
    );
  }

  static TeamMessage fromJson(Map<String, dynamic> json) {
    return TeamMessage(
      id: json['id'] as String,
      teamId: json['team_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      editedAt:
          json['edited_at'] != null
              ? DateTime.tryParse(json['edited_at'] as String)
              : null,
      optimistic: false,
      sending: false,
      failed: false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'team_id': teamId,
    'user_id': userId,
    'content': content,
    'created_at': createdAt.toIso8601String(),
    'edited_at': editedAt?.toIso8601String(),
  };

  @override
  String toString() => 'TeamMessage(id=$id, teamId=$teamId, userId=$userId)';
}
