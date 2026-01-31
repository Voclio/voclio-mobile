class AuthRequest {
  final String email;
  final String password;
  final String? fullName;
  final String? phoneNumber;

  const AuthRequest({
    required this.email,
    required this.password,
    this.fullName,
    this.phoneNumber,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthRequest &&
        other.email == email &&
        other.password == password &&
        other.fullName == fullName &&
        other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode {
    return email.hashCode ^
        password.hashCode ^
        fullName.hashCode ^
        phoneNumber.hashCode;
  }

  @override
  String toString() {
    return 'AuthRequest(email: $email, password: $password, fullName: $fullName, phoneNumber: $phoneNumber)';
  }
}
