// Modelo de amistad actualizado para ser compatible con ambas estructuras de base de datos
class FriendshipModel {
  final String id;
  final String userId; // Puede ser requester_id o user_id según la estructura
  final String
  friendId; // Puede ser receiver_id o friend_id según la estructura
  final String status; // pending, accepted, rejected, blocked
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? acceptedAt;

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
    this.acceptedAt,
    this.friendEmail,
    this.friendFullName,
    this.friendProfileImage,
  });

  factory FriendshipModel.fromJson(Map<String, dynamic> json) {
    return FriendshipModel(
      id: json['id'],
      // Manejar ambas estructuras posibles
      userId: json['user_id'] ?? json['requester_id'] ?? '',
      friendId: json['friend_id'] ?? json['receiver_id'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      acceptedAt:
          json['accepted_at'] != null
              ? DateTime.parse(json['accepted_at'])
              : null,
      friendEmail: json['friend_email'] ?? json['sender_email'],
      friendFullName: json['friend_full_name'] ?? json['sender_name'],
      friendProfileImage: json['friend_profile_image'] ?? json['sender_image'],
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
  final DateTime? acceptedAt;
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
      profileImageUrl: json['profile_image_url'] ?? json['profile_picture_url'],
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
