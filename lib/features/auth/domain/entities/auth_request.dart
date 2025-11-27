class AuthRequest {
  final String email;
  final String password;
  final String? fullName;

  const AuthRequest({
    required this.email,
    required this.password,
    this.fullName,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthRequest &&
        other.email == email &&
        other.password == password &&
        other.fullName == fullName;
  }

  @override
  int get hashCode {
    return email.hashCode ^ password.hashCode ^ fullName.hashCode;
  }

  @override
  String toString() {
    return 'AuthRequest(email: $email, password: $password, fullName: $fullName)';
  }
}
