// Modelo de amistad simplificado
class FriendshipModel {
  final String id;
  final String userId;
  final String friendId;
  final String status; // pending, accepted, rejected
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Datos del amigo (cuando se obtiene la vista)
  final String? friendEmail;
  final String? friendFullName;
  final String? friendProfileImage;

  const FriendshipModel({
    required this.id,
    required this.userId,
    required this.friendId,
    this.status = 'pending',
    required this.createdAt,
    this.updatedAt,
    this.friendEmail,
    this.friendFullName,
    this.friendProfileImage,
  });

  factory FriendshipModel.fromJson(Map<String, dynamic> json) {
    return FriendshipModel(
      id: json['id'],
      userId: json['user_id'],
      friendId: json['friend_id'],
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      friendEmail: json['friend_email'],
      friendFullName: json['friend_full_name'],
      friendProfileImage: json['friend_profile_image'],
    );
  }
}

class FriendModel {
  final String userId;
  final String email;
  final String fullName;
  final String? profileImageUrl;
  final String status;
  final DateTime? friendshipDate;
  final DateTime? acceptedAt; // ✅ Agregar acceptedAt
  final bool isOnline;

  const FriendModel({
    required this.userId,
    required this.email,
    required this.fullName,
    this.profileImageUrl,
    this.status = 'accepted',
    this.friendshipDate,
    this.acceptedAt,
    this.isOnline = false,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      userId: json['friend_user_id'],
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? 'Sin nombre',
      profileImageUrl: json['profile_image_url'],
      status: json['status'] ?? 'accepted',
      friendshipDate:
          json['friendship_date'] != null
              ? DateTime.parse(json['friendship_date'])
              : null,
      acceptedAt:
          json['accepted_at'] != null
              ? DateTime.parse(json['accepted_at'])
              : null,
      isOnline: json['is_online'] ?? false,
    );
  }
}
