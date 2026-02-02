import '../../domain/entities/auth_request.dart';

class AuthRequestModel extends AuthRequest {
  const AuthRequestModel({
    required super.email,
    required super.password,
    super.fullName,
    super.phoneNumber,
    super.otp,
  });

  factory AuthRequestModel.fromJson(Map<String, dynamic> json) {
    return AuthRequestModel(
      email: json['email'] as String,
      password: json['password'] as String,
      fullName: json['name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      otp: json['otp'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'password_confirmation': password,
      if (fullName != null) 'name': fullName,
      if (fullName != null) 'full_name': fullName,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (otp != null) 'otp': otp,
      if (otp != null) 'otp_code': otp,
    };
  }

  factory AuthRequestModel.fromEntity(AuthRequest request) {
    return AuthRequestModel(
      email: request.email,
      password: request.password,
      fullName: request.fullName,
      phoneNumber: request.phoneNumber,
      otp: request.otp,
    );
  }
}
