part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final AuthResponse response;

  const AuthSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class OTPLoading extends AuthState {}

class OTPSent extends AuthState {
  final OTPResponse response;

  const OTPSent(this.response);

  @override
  List<Object?> get props => [response];
}

class OTPVerified extends AuthState {
  final OTPResponse response;

  const OTPVerified(this.response);

  @override
  List<Object?> get props => [response];
}

class ForgotPasswordSent extends AuthState {}

class PasswordResetSuccess extends AuthState {}
