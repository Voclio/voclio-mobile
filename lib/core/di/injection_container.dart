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
import 'package:voclio_app/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:voclio_app/features/settings/data/datasources/settings_remote_datasource.dart';
import 'package:voclio_app/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:voclio_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:voclio_app/features/settings/domain/usecases/settings_usecases.dart';

// Tags
import 'package:voclio_app/features/tags/domain/repositories/tag_repository.dart';
import 'package:voclio_app/features/tags/domain/usecases/create_tag_usecase.dart';
import 'package:voclio_app/features/tags/domain/usecases/delete_tag_usecase.dart';
import 'package:voclio_app/features/tags/domain/usecases/get_tags_usecase.dart';
import 'package:voclio_app/features/tags/domain/usecases/update_tag_usecase.dart';
import 'package:voclio_app/features/tags/data/repositories/tag_repository_impl.dart';
import 'package:voclio_app/features/tags/data/datasources/tag_remote_datasource.dart';
import 'package:voclio_app/features/tags/presentation/bloc/tags_cubit.dart';

// Reminders
import 'package:voclio_app/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:voclio_app/features/reminders/domain/usecases/create_reminder_usecase.dart';
import 'package:voclio_app/features/reminders/domain/usecases/delete_reminder_usecase.dart';
import 'package:voclio_app/features/reminders/domain/usecases/get_reminders_usecase.dart';
import 'package:voclio_app/features/reminders/domain/usecases/snooze_reminder_usecase.dart';
import 'package:voclio_app/features/reminders/domain/usecases/update_reminder_usecase.dart';
import 'package:voclio_app/features/reminders/data/repositories/reminder_repository_impl.dart';
import 'package:voclio_app/features/reminders/data/datasources/reminder_remote_datasource.dart';
import 'package:voclio_app/features/reminders/presentation/cubit/reminders_cubit.dart';

// Notifications
import 'package:voclio_app/features/notifications/domain/repositories/notification_repository.dart';
import 'package:voclio_app/features/notifications/domain/usecases/notification_usecases.dart';
import 'package:voclio_app/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:voclio_app/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:voclio_app/features/notifications/presentation/cubit/notifications_cubit.dart';

// Productivity
import 'package:voclio_app/features/productivity/domain/repositories/productivity_repository.dart';
import 'package:voclio_app/features/productivity/domain/usecases/productivity_usecases.dart';
import 'package:voclio_app/features/productivity/domain/usecases/get_ai_suggestions_usecase.dart';
import 'package:voclio_app/features/productivity/data/repositories/productivity_repository_impl.dart';
import 'package:voclio_app/features/productivity/data/datasources/productivity_remote_datasource.dart';
import 'package:voclio_app/features/productivity/presentation/bloc/productivity_cubit.dart';
import 'package:voclio_app/features/productivity/presentation/bloc/ai_suggestions_cubit.dart';

// Dashboard
import 'package:voclio_app/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:voclio_app/features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart';
import 'package:voclio_app/features/dashboard/domain/usecases/get_quick_stats_usecase.dart';
import 'package:voclio_app/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:voclio_app/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:voclio_app/features/dashboard/presentation/bloc/dashboard_cubit.dart';

// Calendar
import 'package:voclio_app/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:voclio_app/features/calendar/domain/usecases/calendar_usecases.dart';
import 'package:voclio_app/features/calendar/data/repositories/calendar_repository_impl.dart';
import 'package:voclio_app/features/calendar/data/datasources/calendar_remote_datasource.dart';
import 'package:voclio_app/features/calendar/presentation/bloc/calendar_cubit.dart';

// Domain
import 'package:voclio_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:voclio_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:voclio_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:voclio_app/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:voclio_app/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:voclio_app/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:voclio_app/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:voclio_app/features/auth/domain/usecases/update_profile_usecase.dart';

// Data
import 'package:voclio_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:voclio_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:voclio_app/features/auth/data/datasources/auth_local_datasource_impl.dart';
import 'package:voclio_app/features/auth/data/repositories/auth_repository_impl.dart';

// Presentation
import 'package:voclio_app/features/auth/presentation/bloc/auth_bloc.dart';

import 'package:voclio_app/core/app/app_cubit.dart';
import 'package:voclio_app/core/api/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // Core - API Client
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(storage: getIt<FlutterSecureStorage>()),
  );

  // Data sources
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      getIt<SharedPreferences>(),
      getIt<FlutterSecureStorage>(),
    ),
  );
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => auth_impl.AuthRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
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
  getIt.registerLazySingleton<UpdateProfileUseCase>(
    () => UpdateProfileUseCase(getIt<AuthRepository>()),
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
      updateProfileUseCase: getIt<UpdateProfileUseCase>(),
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
  getIt.registerLazySingleton<SettingsRemoteDataSource>(
    () => SettingsRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      remoteDataSource: getIt<SettingsRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton(
    () => GetSettingsUseCase(getIt<SettingsRepository>()),
  );
  getIt.registerLazySingleton(
    () => UpdateSettingsUseCase(getIt<SettingsRepository>()),
  );
  getIt.registerFactory<SettingsCubit>(
    () => SettingsCubit(
      getSettingsUseCase: getIt<GetSettingsUseCase>(),
      updateSettingsUseCase: getIt<UpdateSettingsUseCase>(),
      prefs: getIt<SharedPreferences>(),
    ),
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
  getIt.registerLazySingleton(
    () => MarkAllAsReadUseCase(getIt<NotificationRepository>()),
  );
  getIt.registerLazySingleton(
    () => DeleteNotificationUseCase(getIt<NotificationRepository>()),
  );
  getIt.registerLazySingleton(
    () => DeleteAllNotificationsUseCase(getIt<NotificationRepository>()),
  );
  getIt.registerFactory<NotificationsCubit>(
    () => NotificationsCubit(
      getNotificationsUseCase: getIt<GetNotificationsUseCase>(),
      markAsReadUseCase: getIt<MarkAsReadUseCase>(),
      markAllAsReadUseCase: getIt<MarkAllAsReadUseCase>(),
      deleteNotificationUseCase: getIt<DeleteNotificationUseCase>(),
      deleteAllNotificationsUseCase: getIt<DeleteAllNotificationsUseCase>(),
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
  getIt.registerLazySingleton<StartFocusSessionUseCase>(
    () => StartFocusSessionUseCase(getIt<ProductivityRepository>()),
  );
  getIt.registerLazySingleton<EndFocusSessionUseCase>(
    () => EndFocusSessionUseCase(getIt<ProductivityRepository>()),
  );
  getIt.registerLazySingleton<GetStreakUseCase>(
    () => GetStreakUseCase(getIt<ProductivityRepository>()),
  );
  getIt.registerLazySingleton<GetAchievementsUseCase>(
    () => GetAchievementsUseCase(getIt<ProductivityRepository>()),
  );
  getIt.registerLazySingleton<GetAiSuggestionsUseCase>(
    () => GetAiSuggestionsUseCase(getIt<ProductivityRepository>()),
  );
  getIt.registerFactory<ProductivityCubit>(
    () => ProductivityCubit(
      startFocusSessionUseCase: getIt<StartFocusSessionUseCase>(),
      endFocusSessionUseCase: getIt<EndFocusSessionUseCase>(),
      getStreakUseCase: getIt<GetStreakUseCase>(),
      getAchievementsUseCase: getIt<GetAchievementsUseCase>(),
    ),
  );
  getIt.registerFactory<AiSuggestionsCubit>(
    () => AiSuggestionsCubit(
      getAiSuggestionsUseCase: getIt<GetAiSuggestionsUseCase>(),
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

  // Calendar
  getIt.registerLazySingleton<CalendarRemoteDataSource>(
    () => CalendarRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<CalendarRepository>(
    () => CalendarRepositoryImpl(
      remoteDataSource: getIt<CalendarRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton(
    () => GetCalendarMonthUseCase(repository: getIt<CalendarRepository>()),
  );
  getIt.registerLazySingleton<CalendarCubit>(
    () => CalendarCubit(
      getCalendarMonthUseCase: getIt<GetCalendarMonthUseCase>(),
    ),
  );
}
