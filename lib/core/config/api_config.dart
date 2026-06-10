import 'dart:io';

/// Runtime API configuration for the mobile app.
class ApiConfig {
  ApiConfig._();

  /// Override at build time: `--dart-define=API_BASE_URL=http://192.168.1.5:3000/api`
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;

    // Android emulator → host machine localhost
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';
    }

    // iOS simulator / macOS / desktop
    return 'http://127.0.0.1:3000/api';
  }
}
