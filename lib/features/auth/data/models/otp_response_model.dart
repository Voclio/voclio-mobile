import '../../domain/entities/otp_response.dart';

class OTPResponseModel extends OTPResponse {
  const OTPResponseModel({
    required super.success,
    required super.message,
    super.sessionId,
    required super.expiresAt,
  });

  factory OTPResponseModel.fromJson(Map<String, dynamic> json) {
    return OTPResponseModel(
      success: json['success'] as bool,
      message: json['message'] as String,
      sessionId: json['sessionId'] as String?,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      if (sessionId != null) 'sessionId': sessionId,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  factory OTPResponseModel.fromEntity(OTPResponse response) {
    return OTPResponseModel(
      success: response.success,
      message: response.message,
      sessionId: response.sessionId,
      expiresAt: response.expiresAt,
    );
  }
}
