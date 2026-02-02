class OTPRequest {
  final String email;
  final String otp;
  final OTPType type;

  const OTPRequest({
    required this.email,
    required this.otp,
    required this.type,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OTPRequest &&
        other.email == email &&
        other.otp == otp &&
        other.type == type;
  }

  @override
  int get hashCode {
    return email.hashCode ^ otp.hashCode ^ type.hashCode;
  }

  @override
  String toString() {
    return 'OTPRequest(email: $email, otp: $otp, type: $type)';
  }
}

enum OTPType { registration, forgotPassword, resetPassword, login }

extension OTPTypeExtension on OTPType {
  String get toShortString {
    switch (this) {
      case OTPType.registration:
        return 'registration';
      case OTPType.forgotPassword:
        return 'forgotPassword';
      case OTPType.resetPassword:
        return 'resetPassword';
      case OTPType.login:
        return 'login';
    }
  }
}
