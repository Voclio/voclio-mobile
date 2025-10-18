class OTPResponse {
  final bool success;
  final String message;
  final String? sessionId;
  final DateTime expiresAt;

  const OTPResponse({
    required this.success,
    required this.message,
    this.sessionId,
    required this.expiresAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OTPResponse &&
        other.success == success &&
        other.message == message &&
        other.sessionId == sessionId &&
        other.expiresAt == expiresAt;
  }

  @override
  int get hashCode {
    return success.hashCode ^
        message.hashCode ^
        sessionId.hashCode ^
        expiresAt.hashCode;
  }

  @override
  String toString() {
    return 'OTPResponse(success: $success, message: $message, sessionId: $sessionId, expiresAt: $expiresAt)';
  }
}
