import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../splash/Voclio_splash_screen.dart';

class AppRouter {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
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

    ],
  );
}
