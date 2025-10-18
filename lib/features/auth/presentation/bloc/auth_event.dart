part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final AuthRequest request;

  const LoginEvent(this.request);

  @override
  List<Object?> get props => [request];
}

class RegisterEvent extends AuthEvent {
  final AuthRequest request;

  const RegisterEvent(this.request);

  @override
  List<Object?> get props => [request];
}

class SendOTPEvent extends AuthEvent {
  final String email;
  final OTPType type;

  const SendOTPEvent(this.email, this.type);

  @override
  List<Object?> get props => [email, type];
}

class VerifyOTPEvent extends AuthEvent {
  final OTPRequest request;

  const VerifyOTPEvent(this.request);

  @override
  List<Object?> get props => [request];
}

class ForgotPasswordEvent extends AuthEvent {
  final String email;

  const ForgotPasswordEvent(this.email);

  @override
  List<Object?> get props => [email];
}

class ResetPasswordEvent extends AuthEvent {
  final String email;
  final String newPassword;
  final String otp;

  const ResetPasswordEvent(this.email, this.newPassword, this.otp);

  @override
  List<Object?> get props => [email, newPassword, otp];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

class RefreshAuthEvent extends AuthEvent {
  const RefreshAuthEvent();
}