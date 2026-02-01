import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_request.dart';
import '../../domain/entities/auth_response.dart';
import '../../domain/entities/otp_request.dart';
import '../../domain/entities/otp_response.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/google_sign_in_usecase.dart';
import '../../domain/usecases/facebook_sign_in_usecase.dart';
import '../../domain/usecases/change_password_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final SendOTPUseCase _sendOTPUseCase;
  final VerifyOTPUseCase _verifyOTPUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final LogoutUseCase _logoutUseCase;
  final GoogleSignInUseCase _googleSignInUseCase;
  final FacebookSignInUseCase _facebookSignInUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required SendOTPUseCase sendOTPUseCase,
    required VerifyOTPUseCase verifyOTPUseCase,
    required ForgotPasswordUseCase forgotPasswordUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required LogoutUseCase logoutUseCase,
    required GoogleSignInUseCase googleSignInUseCase,
    required FacebookSignInUseCase facebookSignInUseCase,
    required ChangePasswordUseCase changePasswordUseCase,
  }) : _loginUseCase = loginUseCase,
       _registerUseCase = registerUseCase,
       _sendOTPUseCase = sendOTPUseCase,
       _verifyOTPUseCase = verifyOTPUseCase,
       _forgotPasswordUseCase = forgotPasswordUseCase,
       _resetPasswordUseCase = resetPasswordUseCase,
       _updateProfileUseCase = updateProfileUseCase,
       _logoutUseCase = logoutUseCase,
       _googleSignInUseCase = googleSignInUseCase,
       _facebookSignInUseCase = facebookSignInUseCase,
       _changePasswordUseCase = changePasswordUseCase,
       super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<SendOTPEvent>(_onSendOTP);
    on<VerifyOTPEvent>(_onVerifyOTP);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<ResetPasswordEvent>(_onResetPassword);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<LogoutEvent>(_onLogout);
    on<RefreshAuthEvent>(_onRefresh);
    on<GoogleSignInEvent>(_onGoogleSignIn);
    on<FacebookSignInEvent>(_onFacebookSignIn);
    on<ChangePasswordEvent>(_onChangePassword);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _loginUseCase(event.request);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (response) => emit(AuthSuccess(response)),
    );
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _registerUseCase(event.request);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (response) => emit(AuthSuccess(response)),
    );
  }

  Future<void> _onSendOTP(SendOTPEvent event, Emitter<AuthState> emit) async {
    emit(OTPLoading());
    final result = await _sendOTPUseCase(event.email, event.type);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (response) => emit(OTPSent(response)),
    );
  }

  Future<void> _onVerifyOTP(
    VerifyOTPEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(OTPLoading());
    final result = await _verifyOTPUseCase(event.request);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (response) => emit(OTPVerified(response)),
    );
  }

  Future<void> _onForgotPassword(
    ForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _forgotPasswordUseCase(event.email);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(ForgotPasswordSent()),
    );
  }

  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _resetPasswordUseCase(event.token, event.newPassword);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(PasswordResetSuccess()),
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _updateProfileUseCase(event.name, event.phoneNumber);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (response) => emit(AuthSuccess(response)),
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _logoutUseCase();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthInitial()),
    );
  }

  Future<void> _onGoogleSignIn(
    GoogleSignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _googleSignInUseCase();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (response) => emit(AuthSuccess(response)),
    );
  }

  Future<void> _onFacebookSignIn(
    FacebookSignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _facebookSignInUseCase();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (response) => emit(AuthSuccess(response)),
    );
  }

  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _changePasswordUseCase(
      event.currentPassword,
      event.newPassword,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(PasswordResetSuccess()), // Or a new state "PasswordChangedSuccess"
    );
  }

  Future<void> _onRefresh(
    RefreshAuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthInitial());
  }
}
