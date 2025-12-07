import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/change_password_screen.dart';
import '../../features/auth/domain/entities/otp_request.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/dashboard/presentation/bloc/dashboard_cubit.dart';
import '../../features/reminders/presentation/screens/reminders_screen.dart';
import '../di/injection_container.dart';
import '../../features/productivity/presentation/screens/focus_timer_screen.dart';
import '../../features/productivity/presentation/screens/achievements_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/tags/presentation/screens/tags_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/calendar/presentation/screens/monthly_calendar_screen.dart';
import '../../features/voice/presentation/screens/voice_recorder_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../splash/Voclio_splash_screen.dart';

class AppRouter {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String changePassword = '/change-password';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String reminders = '/reminders';
  static const String focusTimer = '/focus-timer';
  static const String achievements = '/achievements';
  static const String notifications = '/notifications';
  static const String tags = '/tags';
  static const String settings = '/settings';
  static const String calendar = '/calendar';
  static const String voiceRecorder = '/voice-recorder';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const VoclioSplashScreen(),
      ),
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: login, builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: otp,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          final type = state.uri.queryParameters['type'] ?? 'registration';
          return OTPScreen(
            email: email,
            type:
                type == 'forgotPassword'
                    ? OTPType.forgotPassword
                    : OTPType.registration,
          );
        },
      ),
      GoRoute(
        path: forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: resetPassword,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return ResetPasswordScreen(email: email);
        },
      ),
      GoRoute(path: home, builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: dashboard,
        builder:
            (context, state) => BlocProvider(
              create: (context) => getIt<DashboardCubit>(),
              child: const DashboardScreen(),
            ),
      ),
      GoRoute(
        path: reminders,
        builder: (context, state) => const RemindersScreen(),
      ),
      GoRoute(
        path: focusTimer,
        builder: (context, state) => const FocusTimerScreen(),
      ),
      GoRoute(
        path: achievements,
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(path: tags, builder: (context, state) => const TagsScreen()),
      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: changePassword,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: calendar,
        builder: (context, state) => const MonthlyCalendarScreen(),
      ),
      GoRoute(
        path: voiceRecorder,
        builder: (context, state) => const VoiceRecorderScreen(),
      ),
    ],
  );
}
