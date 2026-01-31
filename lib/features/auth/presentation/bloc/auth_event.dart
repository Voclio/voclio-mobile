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
  final String token;
  final String newPassword;
  const ResetPasswordEvent(this.token, this.newPassword);
  @override
  List<Object?> get props => [token, newPassword];
}

class UpdateProfileEvent extends AuthEvent {
  final String name;
  final String phoneNumber;
  const UpdateProfileEvent({required this.name, required this.phoneNumber});
  @override
  List<Object?> get props => [name, phoneNumber];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

class RefreshAuthEvent extends AuthEvent {
  const RefreshAuthEvent();
}