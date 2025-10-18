import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/domain/entities/otp_request.dart';
import '../../features/home/presentation/screens/home_screen.dart';
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
  static const String home = '/home';

  static final GoRouter router = GoRouter(
    initialLocation: splash,

    routes: [
      GoRoute(
        path: splash,
        builder:
            (context, state) => const VoclioSplashScreen(),
      ),
      GoRoute(
        path: onboarding,
        builder:
            (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: login,
        builder:
            (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        builder:
            (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: otp,
        builder:
            (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          final type = state.uri.queryParameters['type'] ?? 'registration';
          return OTPScreen(
            email: email,
            type: type == 'forgotPassword' 
                ? OTPType.forgotPassword 
                : OTPType.registration,
          );
        },
      ),
      GoRoute(
        path: forgotPassword,
        builder:
            (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: resetPassword,
        builder:
            (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return ResetPasswordScreen(email: email);
        },
      ),
      GoRoute(
        path: home,
        builder:
            (context, state) => const HomeScreen(),
      ),
    ],
  );
}
