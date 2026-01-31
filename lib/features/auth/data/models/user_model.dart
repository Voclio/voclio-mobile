import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.avatar,
    required super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle both 'user_id' (from API) and 'id' (possible local format)
    final userId = (json['user_id'] ?? json['id']).toString();

    // Handle both 'name' (from API) and 'fullName' (possible local format)
    final userName =
        (json['name'] ?? json['full_name'] ?? json['fullName']) as String;

    return UserModel(
      id: userId,
      email: json['email'] as String,
      fullName: userName,
      avatar: json['avatar'] as String?,
      // Provide default value if createdAt is not present
      createdAt:
          json['created_at'] != null || json['createdAt'] != null
              ? DateTime.parse(
                (json['created_at'] ?? json['createdAt']) as String,
              )
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null || json['updatedAt'] != null
              ? DateTime.parse(
                (json['updated_at'] ?? json['updatedAt']) as String,
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'avatar': avatar,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      avatar: user.avatar,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }
}
