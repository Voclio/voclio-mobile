/// Runtime API configuration for the mobile app.
class ApiConfig {
  ApiConfig._();

  static const String _defaultBaseUrl = 'https://voclio-backend.build8.dev/api';

  /// Override at build time:
  /// `--dart-define=API_BASE_URL=https://your-api.example.com/api`
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
    return _defaultBaseUrl;
  }
}
