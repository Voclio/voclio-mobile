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
import 'package:voclio_app/features/auth/data/datasources/auth_remote_datasource_impl.dart'
    as auth_impl;

// Settings
import '../../features/settings/presentation/cubit/settings_cubit.dart';

// Tags
import '../../features/tags/domain/repositories/tag_repository.dart';
import '../../features/tags/domain/usecases/create_tag_usecase.dart';
import '../../features/tags/domain/usecases/delete_tag_usecase.dart';
import '../../features/tags/domain/usecases/get_tags_usecase.dart';
import '../../features/tags/domain/usecases/update_tag_usecase.dart';
import '../../features/tags/data/repositories/tag_repository_impl.dart';
import '../../features/tags/data/datasources/tag_remote_datasource.dart';
import '../../features/tags/presentation/bloc/tags_cubit.dart';

// Reminders
import '../../features/reminders/domain/repositories/reminder_repository.dart';
import '../../features/reminders/domain/usecases/create_reminder_usecase.dart';
import '../../features/reminders/domain/usecases/delete_reminder_usecase.dart';
import '../../features/reminders/domain/usecases/get_reminders_usecase.dart';
import '../../features/reminders/domain/usecases/snooze_reminder_usecase.dart';
import '../../features/reminders/domain/usecases/update_reminder_usecase.dart';
import '../../features/reminders/data/repositories/reminder_repository_impl.dart';
import '../../features/reminders/data/datasources/reminder_remote_datasource.dart';
import '../../features/reminders/presentation/cubit/reminders_cubit.dart';

// Notifications
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/domain/usecases/get_notifications_usecase.dart';
import '../../features/notifications/domain/usecases/mark_as_read_usecase.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/data/datasources/notification_remote_datasource.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';

// Productivity
import '../../features/productivity/domain/repositories/productivity_repository.dart';
import '../../features/productivity/domain/usecases/productivity_usecases.dart';
import '../../features/productivity/data/repositories/productivity_repository_impl.dart';
import '../../features/productivity/data/datasources/productivity_remote_datasource.dart';
import '../../features/productivity/presentation/bloc/productivity_cubit.dart';

// Dashboard
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart';
import '../../features/dashboard/domain/usecases/get_quick_stats_usecase.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import '../../features/dashboard/presentation/bloc/dashboard_cubit.dart';

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
import '../../features/auth/data/repositories/auth_repository_impl.dart';

// Presentation
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// App
import '../app/app_cubit.dart';
import '../api/api_client.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Core - API Client
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());

  // Data sources
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => auth_impl.AuthRemoteDataSourceImpl(),
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
    () => TaskRemoteDataSourceImpl(getIt(), apiClient: getIt<ApiClient>()),
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

  // Settings
  getIt.registerFactory<SettingsCubit>(
    () => SettingsCubit(prefs: getIt<SharedPreferences>()),
  );

  // Tags
  getIt.registerLazySingleton<TagRemoteDataSource>(
    () => TagRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<TagRepository>(
    () => TagRepositoryImpl(remoteDataSource: getIt<TagRemoteDataSource>()),
  );
  getIt.registerLazySingleton(() => GetTagsUseCase(getIt<TagRepository>()));
  getIt.registerLazySingleton(() => CreateTagUseCase(getIt<TagRepository>()));
  getIt.registerLazySingleton(() => UpdateTagUseCase(getIt<TagRepository>()));
  getIt.registerLazySingleton(() => DeleteTagUseCase(getIt<TagRepository>()));
  getIt.registerFactory<TagsCubit>(
    () => TagsCubit(
      getTagsUseCase: getIt(),
      createTagUseCase: getIt(),
      updateTagUseCase: getIt(),
      deleteTagUseCase: getIt(),
    ),
  );

  // Reminders
  getIt.registerLazySingleton<ReminderRemoteDataSource>(
    () => ReminderRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<ReminderRepository>(
    () => ReminderRepositoryImpl(
      remoteDataSource: getIt<ReminderRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton(
    () => GetRemindersUseCase(getIt<ReminderRepository>()),
  );
  getIt.registerLazySingleton(
    () => CreateReminderUseCase(getIt<ReminderRepository>()),
  );
  getIt.registerLazySingleton(
    () => UpdateReminderUseCase(getIt<ReminderRepository>()),
  );
  getIt.registerLazySingleton(
    () => DeleteReminderUseCase(getIt<ReminderRepository>()),
  );
  getIt.registerLazySingleton(
    () => SnoozeReminderUseCase(getIt<ReminderRepository>()),
  );
  getIt.registerFactory<RemindersCubit>(
    () => RemindersCubit(
      getRemindersUseCase: getIt(),
      createReminderUseCase: getIt(),
      updateReminderUseCase: getIt(),
      deleteReminderUseCase: getIt(),
      snoozeReminderUseCase: getIt(),
    ),
  );

  // Notifications
  getIt.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDataSource: getIt<NotificationRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton(
    () => GetNotificationsUseCase(getIt<NotificationRepository>()),
  );
  getIt.registerLazySingleton(
    () => MarkAsReadUseCase(getIt<NotificationRepository>()),
  );
  getIt.registerFactory<NotificationsCubit>(
    () => NotificationsCubit(
      getNotificationsUseCase: getIt(),
      markAsReadUseCase: getIt(),
    ),
  );

  // Productivity
  getIt.registerLazySingleton<ProductivityRemoteDataSource>(
    () => ProductivityRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<ProductivityRepository>(
    () => ProductivityRepositoryImpl(
      remoteDataSource: getIt<ProductivityRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton(
    () => StartFocusSessionUseCase(getIt<ProductivityRepository>()),
  );
  getIt.registerLazySingleton(
    () => EndFocusSessionUseCase(getIt<ProductivityRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetStreakUseCase(getIt<ProductivityRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetAchievementsUseCase(getIt<ProductivityRepository>()),
  );
  getIt.registerFactory<ProductivityCubit>(
    () => ProductivityCubit(
      startFocusSessionUseCase: getIt(),
      endFocusSessionUseCase: getIt(),
      getStreakUseCase: getIt(),
      getAchievementsUseCase: getIt(),
    ),
  );

  // Dashboard
  getIt.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      remoteDataSource: getIt<DashboardRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton(
    () => GetDashboardStatsUseCase(getIt<DashboardRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetQuickStatsUseCase(getIt<DashboardRepository>()),
  );
  getIt.registerFactory<DashboardCubit>(
    () => DashboardCubit(
      getDashboardStatsUseCase: getIt(),
      getQuickStatsUseCase: getIt(),
    ),
  );
}
