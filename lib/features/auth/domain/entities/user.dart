class User {
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final String? avatar;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
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
        other.name == name &&
        other.phoneNumber == phoneNumber &&
        other.avatar == avatar &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        name.hashCode ^
        phoneNumber.hashCode ^
        avatar.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, phoneNumber: $phoneNumber, avatar: $avatar, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
