import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.phoneNumber,
    super.avatar,
    required super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle both 'user_id' (from API) and 'id' (possible local format)
    final userId = (json['user_id'] ?? json['id'] ?? '').toString();

    // Handle both 'name' (from API) and 'fullName' (possible local format)
    final userName =
        (json['name'] ??
                json['full_name'] ??
                json['fullName'] ??
                'Unknown User')
            as String;

    return UserModel(
      id: userId,
      email: (json['email'] ?? '') as String,
      name: userName,
      phoneNumber: json['phone_number'] as String?,
      avatar: json['avatar'] as String?,
      // Provide default value if createdAt is not present
      createdAt:
          json['created_at'] != null || json['createdAt'] != null
              ? DateTime.tryParse(
                    (json['created_at'] ?? json['createdAt']).toString(),
                  ) ??
                  DateTime.now()
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null || json['updatedAt'] != null
              ? DateTime.tryParse(
                (json['updated_at'] ?? json['updatedAt']).toString(),
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone_number': phoneNumber,
      'avatar': avatar,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      phoneNumber: user.phoneNumber,
      avatar: user.avatar,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }
}
