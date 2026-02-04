import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:developer' as developer;
import '../../domain/entities/auth_request.dart';
import '../../domain/entities/auth_response.dart';
import '../../domain/entities/otp_request.dart';
import '../../domain/entities/otp_response.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/resend_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/google_sign_in_usecase.dart';
import '../../domain/usecases/facebook_sign_in_usecase.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final SendOTPUseCase _sendOTPUseCase;
  final ResendOTPUseCase _resendOTPUseCase;
  final VerifyOTPUseCase _verifyOTPUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final GetProfileUseCase _getProfileUseCase;
  final LogoutUseCase _logoutUseCase;
  final GoogleSignInUseCase _googleSignInUseCase;
  final FacebookSignInUseCase _facebookSignInUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required SendOTPUseCase sendOTPUseCase,
    required ResendOTPUseCase resendOTPUseCase,
    required VerifyOTPUseCase verifyOTPUseCase,
    required ForgotPasswordUseCase forgotPasswordUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required GetProfileUseCase getProfileUseCase,
    required LogoutUseCase logoutUseCase,
    required GoogleSignInUseCase googleSignInUseCase,
    required FacebookSignInUseCase facebookSignInUseCase,
    required ChangePasswordUseCase changePasswordUseCase,
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
  }) : _loginUseCase = loginUseCase,
       _registerUseCase = registerUseCase,
       _sendOTPUseCase = sendOTPUseCase,
       _resendOTPUseCase = resendOTPUseCase,
       _verifyOTPUseCase = verifyOTPUseCase,
       _forgotPasswordUseCase = forgotPasswordUseCase,
       _resetPasswordUseCase = resetPasswordUseCase,
       _updateProfileUseCase = updateProfileUseCase,
       _getProfileUseCase = getProfileUseCase,
       _logoutUseCase = logoutUseCase,
       _googleSignInUseCase = googleSignInUseCase,
       _facebookSignInUseCase = facebookSignInUseCase,
       _changePasswordUseCase = changePasswordUseCase,
       _checkAuthStatusUseCase = checkAuthStatusUseCase,
       super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<SendOTPEvent>(_onSendOTP);
    on<ResendOTPEvent>(_onResendOTP);
    on<VerifyOTPEvent>(_onVerifyOTP);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<ResetPasswordEvent>(_onResetPassword);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<GetProfileEvent>(_onGetProfile);
    on<LogoutEvent>(_onLogout);
    on<RefreshAuthEvent>(_onRefresh);
    on<GoogleSignInEvent>(_onGoogleSignIn);
    on<FacebookSignInEvent>(_onFacebookSignIn);
    on<ChangePasswordEvent>(_onChangePassword);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _checkAuthStatusUseCase();
    result.fold(
      (failure) => emit(AuthInitial()), // Treat error as not logged in
      (response) {
        if (response != null) {
          emit(AuthSuccess(response));
        } else {
          emit(AuthInitial());
        }
      },
    );
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
    developer.log(
      'Registering user: ${event.request.email} with OTP: ${event.request.otp}',
      name: 'AuthBloc',
    );
    emit(AuthLoading());
    final result = await _registerUseCase(event.request);

    result.fold(
      (failure) {
        developer.log(
          'Registration failed: ${failure.message}',
          name: 'AuthBloc',
        );
        emit(AuthError(failure.message));
      },
      (response) {
        developer.log(
          'Registration response received. Success: ${response.token.isNotEmpty}',
          name: 'AuthBloc',
        );
        if (response.token.isNotEmpty) {
          developer.log(
            'Registration Complete: Emitting AuthSuccess',
            name: 'AuthBloc',
          );
          emit(AuthSuccess(response));
        } else {
          developer.log(
            'Registration Step 1: Emitting RegistrationPending',
            name: 'AuthBloc',
          );
          emit(RegistrationPending(response));
        }
      },
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
    result.fold((failure) => emit(AuthError(failure.message)), (response) {
      if (response.token != null && response.token!.isNotEmpty) {
        developer.log(
          'OTP Verified with Login Token: Emitting AuthSuccess',
          name: 'AuthBloc',
        );
        // Create an AuthResponse from binary data
        final authResponse = AuthResponse(
          user: response.user!,
          token: response.token!,
          refreshToken: response.refreshToken ?? '',
          expiresAt: response.expiresAt,
        );
        emit(AuthSuccess(authResponse));
      } else {
        emit(OTPVerified(response));
      }
    });
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
    emit(PasswordResetLoading());
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
    // Save current state in case update fails
    final previousState = state;

    emit(AuthLoading());
    final result = await _updateProfileUseCase(event.name, event.phoneNumber);
    result.fold((failure) {
      // If we had a valid auth state before, restore it and show error
      // This prevents redirecting to login on update failure
      if (previousState is AuthSuccess) {
        // Emit error with preserved user data
        emit(ProfileUpdateError(failure.message, previousState.response));
      } else {
        emit(AuthError(failure.message));
      }
    }, (response) => emit(AuthSuccess(response)));
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
    // Store previous state to restore after password change
    final previousState = state;
    emit(AuthLoading());
    final result = await _changePasswordUseCase(
      event.currentPassword,
      event.newPassword,
    );
    result.fold(
      (failure) {
        // Restore previous state on error if it was AuthSuccess
        if (previousState is AuthSuccess) {
          emit(previousState);
          emit(ProfileUpdateError(failure.message, previousState.response));
        } else {
          emit(AuthError(failure.message));
        }
      },
      (_) {
        emit(PasswordChangedSuccess());
        // Restore AuthSuccess state so profile screen shows user data
        if (previousState is AuthSuccess) {
          emit(previousState);
        }
      },
    );
  }

  Future<void> _onRefresh(
    RefreshAuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthInitial());
  }

  Future<void> _onResendOTP(
    ResendOTPEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(OTPLoading());
    final result = await _resendOTPUseCase(event.email, event.type);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (response) => emit(OTPSent(response)),
    );
  }

  Future<void> _onGetProfile(
    GetProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    // Save current state in case profile fetch fails
    final previousState = state;

    emit(AuthLoading());
    final result = await _getProfileUseCase();
    result.fold((failure) {
      // If we had a valid auth state before, don't show error
      // Just restore previous state (user can still use cached data)
      if (previousState is AuthSuccess) {
        emit(previousState);
      } else {
        // Only emit error if no previous auth state
        emit(AuthError(failure.message));
      }
    }, (response) => emit(AuthSuccess(response)));
  }
}
