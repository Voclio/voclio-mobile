class User {
  final String id;
  final String email;
  final String fullName;
  final String? avatar;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatar,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.email == email &&
        other.fullName == fullName &&
        other.avatar == avatar &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        fullName.hashCode ^
        avatar.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, fullName: $fullName, avatar: $avatar, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
