class PlayerProfileModel {
  final String id;
  final String userId;
  final String? nickname;
  final int yearsPlaying;
  final String? preferredPosition;
  final String? dominantFoot;
  final String? skillLevel;
  final int? height;
  final int? weight;
  final String? preferredGameType;
  final List<String> availableDays;
  final String? preferredTime;
  final List<String> goals;
  final int currentElo;
  final String? comunaId; // Comuna donde vive el jugador
  final DateTime createdAt;
  final DateTime updatedAt;

  const PlayerProfileModel({
    required this.id,
    required this.userId,
    this.nickname,
    this.yearsPlaying = 1,
    this.preferredPosition,
    this.dominantFoot,
    this.skillLevel,
    this.height,
    this.weight,
    this.preferredGameType,
    this.availableDays = const [],
    this.preferredTime,
    this.goals = const [],
    this.currentElo = 1200,
    this.comunaId, // Comuna donde vive el jugador
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlayerProfileModel.fromJson(Map<String, dynamic> json) {
    return PlayerProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      nickname: json['nickname'] as String?,
      yearsPlaying: json['years_playing'] as int? ?? 1,
      preferredPosition: json['preferred_position'] as String?,
      dominantFoot: json['dominant_foot'] as String?,
      skillLevel: json['skill_level'] as String?,
      height: json['height'] as int?,
      weight: json['weight'] as int?,
      preferredGameType: json['preferred_game_type'] as String?,
      availableDays:
          (json['available_days'] as List<dynamic>?)
              ?.map((day) => day as String)
              .toList() ??
          [],
      preferredTime: json['preferred_time'] as String?,
      goals:
          (json['goals'] as List<dynamic>?)
              ?.map((goal) => goal as String)
              .toList() ??
          [],
      currentElo: json['current_elo'] as int? ?? 1200,
      comunaId: json['comuna_id'] as String?, // Comuna del jugador
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nickname': nickname,
      'years_playing': yearsPlaying,
      'preferred_position': preferredPosition,
      'dominant_foot': dominantFoot,
      'skill_level': skillLevel,
      'height': height,
      'weight': weight,
      'preferred_game_type': preferredGameType,
      'available_days': availableDays,
      'preferred_time': preferredTime,
      'goals': goals,
      'current_elo': currentElo,
      'comuna_id': comunaId, // Comuna del jugador
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  PlayerProfileModel copyWith({
    String? id,
    String? userId,
    String? nickname,
    int? yearsPlaying,
    String? preferredPosition,
    String? dominantFoot,
    String? skillLevel,
    int? height,
    int? weight,
    String? preferredGameType,
    List<String>? availableDays,
    String? preferredTime,
    List<String>? goals,
    int? currentElo,
    String? comunaId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlayerProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      yearsPlaying: yearsPlaying ?? this.yearsPlaying,
      preferredPosition: preferredPosition ?? this.preferredPosition,
      dominantFoot: dominantFoot ?? this.dominantFoot,
      skillLevel: skillLevel ?? this.skillLevel,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      preferredGameType: preferredGameType ?? this.preferredGameType,
      availableDays: availableDays ?? this.availableDays,
      preferredTime: preferredTime ?? this.preferredTime,
      goals: goals ?? this.goals,
      currentElo: currentElo ?? this.currentElo,
      comunaId: comunaId ?? this.comunaId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
