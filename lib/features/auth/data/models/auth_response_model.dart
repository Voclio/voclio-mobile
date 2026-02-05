import '../../domain/entities/auth_response.dart';
import 'user_model.dart';

class AuthResponseModel extends AuthResponse {
  const AuthResponseModel({
    required super.user,
    required super.token,
    required super.refreshToken,
    required super.expiresAt,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    // Check if the response is wrapped in a "data" field (standard API response)
    final data =
        json['data'] != null ? json['data'] as Map<String, dynamic> : json;

    // Extract user
    final userMap =
        data['user'] != null
            ? data['user'] as Map<String, dynamic>
            : <String, dynamic>{};

    // Extract tokens
    final tokensMap =
        data['tokens'] != null
            ? data['tokens'] as Map<String, dynamic>
            : data; // Fallback if flat

    final accessToken =
        (tokensMap['access_token'] ?? tokensMap['token'] ?? '') as String;
    final refreshToken =
        (tokensMap['refresh_token'] ?? tokensMap['refreshToken'] ?? '')
            as String;

    // Calculate expiration
    // Default to 7 days if not provided for longer session persistence
    final expiresIn = tokensMap['expires_in'] as int? ?? 604800;
    final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));

    // Handle case where userMap might be empty if API response structure is unexpected
    // If userMap is empty, UserModel.fromJson will use the default values we just added.
    return AuthResponseModel(
      user: UserModel.fromJson(userMap),
      token: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': (user as UserModel).toJson(),
      'token': token,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  factory AuthResponseModel.fromEntity(AuthResponse response) {
    return AuthResponseModel(
      user: UserModel.fromEntity(response.user),
      token: response.token,
      refreshToken: response.refreshToken,
      expiresAt: response.expiresAt,
    );
  }
}
