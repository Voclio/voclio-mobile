import '../../domain/entities/otp_response.dart';

class OTPResponseModel extends OTPResponse {
  const OTPResponseModel({
    required super.success,
    required super.message,
    super.sessionId,
    required super.expiresAt,
  });

  factory OTPResponseModel.fromJson(Map<String, dynamic> json) {
    // Helper to parse bool from various types (bool, string, int)
    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      if (value is num) return value == 1;
      return true; // Default to true if unsure, assuming 200 OK means success
    }

    return OTPResponseModel(
      success: parseBool(json['success'] ?? json['status']),
      message: (json['message'] ?? json['msg'] ?? 'OTP Sent') as String,
      sessionId:
          (json['data'] != null
                  ? (json['data']['sessionId'] ??
                      json['data']['session_id'] ??
                      json['data']['reset_token'])
                  : (json['sessionId'] ??
                      json['session_id'] ??
                      json['reset_token']))
              as String?,
      expiresAt:
          json['expiresAt'] != null || json['expires_at'] != null
              ? DateTime.tryParse(
                    (json['expiresAt'] ?? json['expires_at']).toString(),
                  ) ??
                  DateTime.now().add(const Duration(minutes: 5))
              : DateTime.now().add(const Duration(minutes: 5)),
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
