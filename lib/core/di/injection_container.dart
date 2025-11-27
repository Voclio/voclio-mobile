import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Domain
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/send_otp_usecase.dart';
import '../../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';

// Data
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/datasources/auth_local_datasource_impl.dart';
import '../../features/auth/data/datasources/auth_remote_datasource_impl.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';

// Presentation
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// App
import '../app/app_cubit.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Data sources
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<SendOTPUseCase>(
    () => SendOTPUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<VerifyOTPUseCase>(
    () => VerifyOTPUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<ForgotPasswordUseCase>(
    () => ForgotPasswordUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<ResetPasswordUseCase>(
    () => ResetPasswordUseCase(getIt<AuthRepository>()),
  );

  // BLoC
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: getIt<LoginUseCase>(),
      registerUseCase: getIt<RegisterUseCase>(),
      sendOTPUseCase: getIt<SendOTPUseCase>(),
      verifyOTPUseCase: getIt<VerifyOTPUseCase>(),
      forgotPasswordUseCase: getIt<ForgotPasswordUseCase>(),
      resetPasswordUseCase: getIt<ResetPasswordUseCase>(),
    ),
  );

  // App Cubit
  getIt.registerLazySingleton<AppCubit>(
    () => AppCubit(prefs: getIt<SharedPreferences>()),
  );
}
