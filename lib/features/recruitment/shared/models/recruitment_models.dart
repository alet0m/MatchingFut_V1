class RecruitmentPost {
  final String id;
  final String authorId;
  final String postType; // 'team_seeking_player' o 'player_seeking_team'
  final String title;
  final String description;

  // Para equipos buscando jugadores
  final String? teamId;
  final String? positionNeeded;
  final String? experienceLevel;
  final int? ageRangeMin;
  final int? ageRangeMax;
  final String? trainingSchedule;

  // Para jugadores buscando equipos
  final String? playerPosition;
  final String? playerExperience;
  final String? availability;
  final String? preferredComuna;

  // Datos generales
  final String comuna;
  final String contactMethod;
  final String? contactInfo;
  final bool isActive;
  final bool featured;
  final DateTime expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Datos del autor (join)
  final String authorName;
  final String? authorPhotoUrl;

  // Datos del equipo (si aplica)
  final String? teamName;
  final String? teamTag;
  final String? teamLogoUrl;

  RecruitmentPost({
    required this.id,
    required this.authorId,
    required this.postType,
    required this.title,
    required this.description,
    this.teamId,
    this.positionNeeded,
    this.experienceLevel,
    this.ageRangeMin,
    this.ageRangeMax,
    this.trainingSchedule,
    this.playerPosition,
    this.playerExperience,
    this.availability,
    this.preferredComuna,
    required this.comuna,
    this.contactMethod = 'app',
    this.contactInfo,
    this.isActive = true,
    this.featured = false,
    required this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    required this.authorName,
    this.authorPhotoUrl,
    this.teamName,
    this.teamTag,
    this.teamLogoUrl,
  });

  bool get isTeamPost => postType == 'team_seeking_player';
  bool get isPlayerPost => postType == 'player_seeking_team';

  String get displayTitle =>
      isTeamPost
          ? 'Se busca: $positionNeeded'
          : 'Jugador disponible: $playerPosition';

  String get positionDisplay =>
      isTeamPost
          ? positionNeeded ?? 'Cualquier posición'
          : playerPosition ?? 'Posición flexible';

  factory RecruitmentPost.fromJson(Map<String, dynamic> json) {
    return RecruitmentPost(
      id: json['id'],
      authorId: json['author_id'],
      postType: json['post_type'],
      title: json['title'],
      description: json['description'],
      teamId: json['team_id'],
      positionNeeded: json['position_needed'],
      experienceLevel: json['experience_level'],
      ageRangeMin: json['age_range_min'],
      ageRangeMax: json['age_range_max'],
      trainingSchedule: json['training_schedule'],
      playerPosition: json['player_position'],
      playerExperience: json['player_experience'],
      availability: json['availability'],
      preferredComuna: json['preferred_comuna'],
      comuna: json['comuna'],
      contactMethod: json['contact_method'] ?? 'app',
      contactInfo: json['contact_info'],
      isActive: json['is_active'] ?? true,
      featured: json['featured'] ?? false,
      expiresAt: DateTime.parse(json['expires_at']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      authorName: json['author']['display_name'] ?? 'Usuario',
      authorPhotoUrl: json['author']['photo_url'],
      teamName: json['team']?['name'],
      teamTag: json['team']?['tag'],
      teamLogoUrl: json['team']?['logo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author_id': authorId,
      'post_type': postType,
      'title': title,
      'description': description,
      'team_id': teamId,
      'position_needed': positionNeeded,
      'experience_level': experienceLevel,
      'age_range_min': ageRangeMin,
      'age_range_max': ageRangeMax,
      'training_schedule': trainingSchedule,
      'player_position': playerPosition,
      'player_experience': playerExperience,
      'availability': availability,
      'preferred_comuna': preferredComuna,
      'comuna': comuna,
      'contact_method': contactMethod,
      'contact_info': contactInfo,
      'is_active': isActive,
      'featured': featured,
      'expires_at': expiresAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class PlayerProfile {
  final String id;
  final String userId;
  final List<String> preferredPositions;
  final List<String> secondaryPositions;
  final String? preferredFoot;
  final int? height;
  final int? weight;
  final DateTime? birthDate;
  final String experienceLevel;
  final int yearsPlaying;
  final List<String> previousTeams;
  final List<String> achievements;
  final int speedRating;
  final int techniqueRating;
  final int strengthRating;
  final int enduranceRating;
  final List<String> availableDays;
  final List<String> preferredTimeSlots;
  final List<String> preferredComunas;
  final bool lookingForTeam;
  final bool openToOffers;
  final String profileVisibility;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Datos del usuario (join)
  final String userName;
  final String? userPhotoUrl;
  final String? userBio;

  PlayerProfile({
    required this.id,
    required this.userId,
    this.preferredPositions = const [],
    this.secondaryPositions = const [],
    this.preferredFoot,
    this.height,
    this.weight,
    this.birthDate,
    this.experienceLevel = 'intermedio',
    this.yearsPlaying = 0,
    this.previousTeams = const [],
    this.achievements = const [],
    this.speedRating = 5,
    this.techniqueRating = 5,
    this.strengthRating = 5,
    this.enduranceRating = 5,
    this.availableDays = const [],
    this.preferredTimeSlots = const [],
    this.preferredComunas = const [],
    this.lookingForTeam = false,
    this.openToOffers = true,
    this.profileVisibility = 'public',
    required this.createdAt,
    required this.updatedAt,
    required this.userName,
    this.userPhotoUrl,
    this.userBio,
  });

  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    final difference = now.difference(birthDate!);
    return (difference.inDays / 365).floor();
  }

  double get overallRating {
    return (speedRating + techniqueRating + strengthRating + enduranceRating) /
        4.0;
  }

  String get primaryPosition =>
      preferredPositions.isNotEmpty ? preferredPositions.first : 'Flexible';

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      id: json['id'],
      userId: json['user_id'],
      preferredPositions:
          json['preferred_positions'] != null
              ? List<String>.from(json['preferred_positions'])
              : [],
      secondaryPositions:
          json['secondary_positions'] != null
              ? List<String>.from(json['secondary_positions'])
              : [],
      preferredFoot: json['preferred_foot'],
      height: json['height'],
      weight: json['weight'],
      birthDate:
          json['birth_date'] != null
              ? DateTime.parse(json['birth_date'])
              : null,
      experienceLevel: json['experience_level'] ?? 'intermedio',
      yearsPlaying: json['years_playing'] ?? 0,
      previousTeams:
          json['previous_teams'] != null
              ? List<String>.from(json['previous_teams'])
              : [],
      achievements:
          json['achievements'] != null
              ? List<String>.from(json['achievements'])
              : [],
      speedRating: json['speed_rating'] ?? 5,
      techniqueRating: json['technique_rating'] ?? 5,
      strengthRating: json['strength_rating'] ?? 5,
      enduranceRating: json['endurance_rating'] ?? 5,
      availableDays:
          json['available_days'] != null
              ? List<String>.from(json['available_days'])
              : [],
      preferredTimeSlots:
          json['preferred_time_slots'] != null
              ? List<String>.from(json['preferred_time_slots'])
              : [],
      preferredComunas:
          json['preferred_comunas'] != null
              ? List<String>.from(json['preferred_comunas'])
              : [],
      lookingForTeam: json['looking_for_team'] ?? false,
      openToOffers: json['open_to_offers'] ?? true,
      profileVisibility: json['profile_visibility'] ?? 'public',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      userName: json['user']['display_name'] ?? 'Usuario',
      userPhotoUrl: json['user']['photo_url'],
      userBio: json['user']['bio'],
    );
  }
}

class RecruitmentApplication {
  final String id;
  final String postId;
  final String applicantId;
  final String? message;
  final String status;
  final Map<String, dynamic>? playerStats;
  final String? preferredPosition;
  final String? availabilityDetails;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Datos del aplicante (join)
  final String applicantName;
  final String? applicantPhotoUrl;

  RecruitmentApplication({
    required this.id,
    required this.postId,
    required this.applicantId,
    this.message,
    this.status = 'pending',
    this.playerStats,
    this.preferredPosition,
    this.availabilityDetails,
    required this.createdAt,
    required this.updatedAt,
    required this.applicantName,
    this.applicantPhotoUrl,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';

  factory RecruitmentApplication.fromJson(Map<String, dynamic> json) {
    return RecruitmentApplication(
      id: json['id'],
      postId: json['post_id'],
      applicantId: json['applicant_id'],
      message: json['message'],
      status: json['status'] ?? 'pending',
      playerStats: json['player_stats'],
      preferredPosition: json['preferred_position'],
      availabilityDetails: json['availability_details'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      applicantName: json['applicant']['display_name'] ?? 'Usuario',
      applicantPhotoUrl: json['applicant']['photo_url'],
    );
  }
}
