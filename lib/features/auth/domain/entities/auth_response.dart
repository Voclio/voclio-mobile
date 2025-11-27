import 'user.dart';

class AuthResponse {
  final User user;
  final String token;
  final String refreshToken;
  final DateTime expiresAt;

  const AuthResponse({
    required this.user,
    required this.token,
    required this.refreshToken,
    required this.expiresAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthResponse &&
        other.user == user &&
        other.token == token &&
        other.refreshToken == refreshToken &&
        other.expiresAt == expiresAt;
  }

  @override
  int get hashCode {
    return user.hashCode ^
        token.hashCode ^
        refreshToken.hashCode ^
        expiresAt.hashCode;
  }

  @override
  String toString() {
    return 'AuthResponse(user: $user, token: $token, refreshToken: $refreshToken, expiresAt: $expiresAt)';
  }
}
