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

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required SendOTPUseCase sendOTPUseCase,
    required VerifyOTPUseCase verifyOTPUseCase,
    required ForgotPasswordUseCase forgotPasswordUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
  }) : _loginUseCase = loginUseCase,
       _registerUseCase = registerUseCase,
       _sendOTPUseCase = sendOTPUseCase,
       _verifyOTPUseCase = verifyOTPUseCase,
       _forgotPasswordUseCase = forgotPasswordUseCase,
       _resetPasswordUseCase = resetPasswordUseCase,
       _updateProfileUseCase = updateProfileUseCase,
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
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _loginUseCase(event.request);
      emit(AuthSuccess(response));
    } catch (e) {
      // Clean up error message by removing exception wrappers
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      emit(AuthError(errorMessage));
    }
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _registerUseCase(event.request);
      emit(AuthSuccess(response));
    } catch (e) {
      // Clean up error message by removing exception wrappers
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      emit(AuthError(errorMessage));
    }
  }

  Future<void> _onSendOTP(SendOTPEvent event, Emitter<AuthState> emit) async {
    emit(OTPLoading());
    try {
      final response = await _sendOTPUseCase(event.email, event.type);
      emit(OTPSent(response));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyOTP(
    VerifyOTPEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(OTPLoading());
    try {
      final response = await _verifyOTPUseCase(event.request);
      emit(OTPVerified(response));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onForgotPassword(
    ForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _forgotPasswordUseCase(event.email);
      emit(ForgotPasswordSent());
    } catch (e) {
      // Clean up error message by removing exception wrappers
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      emit(AuthError(errorMessage));
    }
  }

  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _resetPasswordUseCase(event.token, event.newPassword);
      emit(PasswordResetSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _updateProfileUseCase(event.name, event.phoneNumber);
      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (response) => emit(AuthSuccess(response)),
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Add logout logic here if needed
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRefresh(
    RefreshAuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    // Simply reset to initial state to clear any errors
    emit(AuthInitial());
  }
}
