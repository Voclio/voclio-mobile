import '../../domain/entities/auth_request.dart';

class AuthRequestModel extends AuthRequest {
  const AuthRequestModel({
    required super.email,
    required super.password,
    super.fullName,
    super.phoneNumber,
  });

  factory AuthRequestModel.fromJson(Map<String, dynamic> json) {
    return AuthRequestModel(
      email: json['email'] as String,
      password: json['password'] as String,
      fullName: json['name'] as String?,
      phoneNumber: json['phone_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      if (fullName != null) 'name': fullName,
      if (phoneNumber != null) 'phone_number': phoneNumber,
    };
  }

  factory AuthRequestModel.fromEntity(AuthRequest request) {
    return AuthRequestModel(
      email: request.email,
      password: request.password,
      fullName: request.fullName,
      phoneNumber: request.phoneNumber,
    );
  }
}
