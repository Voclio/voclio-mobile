/// OAuth client IDs for social sign-in.
///
/// Override at build time:
/// `--dart-define=GOOGLE_WEB_CLIENT_ID=...`
/// `--dart-define=GOOGLE_IOS_CLIENT_ID=...`
class OAuthConfig {
  OAuthConfig._();

  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue:
        '297833675857-l20bvp3gepaeqgcaibm1vc0voni5f8od.apps.googleusercontent.com',
  );

  /// iOS OAuth client ID from Google Cloud Console (iOS app type).
  static const String googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue:
        '297833675857-hf7evedrus19v8t497su1levitkrbli5.apps.googleusercontent.com',
  );

  static String get effectiveIosClientId => googleIosClientId;

  /// Deep link scheme for Google Calendar OAuth callback.
  static const String calendarOAuthScheme = 'voclio';

  static String get calendarOAuthRedirectUri =>
      '$calendarOAuthScheme://oauth/callback';

  /// Reversed iOS client ID for `CFBundleURLSchemes` in Info.plist.
  static String? get googleIosUrlScheme {
    final clientId = effectiveIosClientId;

    final prefix = clientId.replaceAll(
      RegExp(r'\.apps\.googleusercontent\.com$'),
      '',
    );
    return 'com.googleusercontent.apps.$prefix';
  }
}
