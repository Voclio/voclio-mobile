import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voclio_app/features/notes/data/repositories/fake_note_repo.dart';
import 'package:voclio_app/features/notes/domain/repositories/note_repository.dart';
import 'package:voclio_app/features/notes/domain/usecases/add_note_use_case.dart';
import 'package:voclio_app/features/notes/domain/usecases/delete_note_use_case.dart';
import 'package:voclio_app/features/notes/domain/usecases/get_all_notes_use_case.dart';
import 'package:voclio_app/features/notes/domain/usecases/get_note_use_case.dart';
import 'package:voclio_app/features/notes/domain/usecases/update_note_use_case.dart';
import 'package:voclio_app/features/notes/presentation/bloc/notes_cubit.dart';
import 'package:voclio_app/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:voclio_app/features/tasks/data/repositories/fake_repo.dart';
import 'package:voclio_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:voclio_app/features/tasks/domain/usecases/create_task_use_case.dart';
import 'package:voclio_app/features/tasks/domain/usecases/delete_task_use_case.dart';
import 'package:voclio_app/features/tasks/domain/usecases/get_all_tasks_use_case.dart';
import 'package:voclio_app/features/tasks/domain/usecases/get_task_use_case.dart';
import 'package:voclio_app/features/tasks/domain/usecases/update_task_use_case.dart';
import 'package:voclio_app/features/tasks/presentation/bloc/tasks_cubit.dart';

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

  getIt.registerLazySingleton<TaskRemoteDataSource>(
    () => TaskRemoteDataSourceImpl(getIt()),
  );

  getIt.registerLazySingleton<TaskRepository>(() => FakeRepo());

  getIt.registerLazySingleton(() => GetAllTasksUseCase(getIt()));
  getIt.registerLazySingleton(() => GetTaskUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateTaskUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateTaskUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteTaskUseCase(getIt()));

  getIt.registerFactory(
    () => TasksCubit(
      deletaTaskUseCase: getIt(),
      updateTaskUseCase: getIt(),
      getAllTasksUseCase: getIt(),
      getTaskUseCase: getIt(),
      createTaskUseCase: getIt(),
    ),
  );
  getIt.registerLazySingleton<NoteRepository>(() => FakeNoteRepository());
  getIt.registerLazySingleton(() => GetAllNotesUseCase(getIt()));
  getIt.registerLazySingleton(() => GetNoteUseCase(getIt()));
  getIt.registerLazySingleton(() => AddNoteUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateNoteUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteNoteUseCase(getIt()));
  getIt.registerFactory(
    () => NotesCubit(
      addNoteUseCase: getIt(),
      getAllNotesUseCase: getIt(),
      getNoteUseCase: getIt(),
      updateNoteUseCase: getIt(),
      deleteNoteUseCase: getIt(),
    ),
  );
}
