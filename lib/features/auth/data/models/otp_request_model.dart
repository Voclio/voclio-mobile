import '../../domain/entities/otp_request.dart';

class OTPRequestModel extends OTPRequest {
  const OTPRequestModel({
    required super.email,
    required super.otp,
    required super.type,
  });

  factory OTPRequestModel.fromJson(Map<String, dynamic> json) {
    return OTPRequestModel(
      email: json['email'] as String,
      otp: json['otp'] as String,
      type: OTPType.values.firstWhere(
        (e) => e.toString() == 'OTPType.${json['type']}',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
      'otp_code': otp,
      'type': type.toShortString,
    };
  }

  factory OTPRequestModel.fromEntity(OTPRequest request) {
    return OTPRequestModel(
      email: request.email,
      otp: request.otp,
      type: request.type,
    );
  }
}
