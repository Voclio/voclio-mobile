import 'dart:io';

/// OAuth client IDs for social sign-in.
///
/// Override at build time:
/// `--dart-define=GOOGLE_WEB_CLIENT_ID=...`
/// `--dart-define=GOOGLE_IOS_CLIENT_ID=...`
/// `--dart-define=GOOGLE_ANDROID_CLIENT_ID=...`
class OAuthConfig {
  OAuthConfig._();

  /// Must match `applicationId` in android/app/build.gradle.kts.
  static const String androidPackageName = 'com.example.voclio_app';

  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue:
        '297833675857-l20bvp3gepaeqgcaibm1vc0voni5f8od.apps.googleusercontent.com',
  );

  /// Android OAuth client ID from Google Cloud Console (Android app type).
  static const String googleAndroidClientId = String.fromEnvironment(
    'GOOGLE_ANDROID_CLIENT_ID',
    defaultValue:
        '297833675857-ulcm52du2poobg5um5lvhba1t1fvb8cc.apps.googleusercontent.com',
  );

  /// iOS OAuth client ID from Google Cloud Console (iOS app type).
  static const String googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue:
        '297833675857-hf7evedrus19v8t497su1levitkrbli5.apps.googleusercontent.com',
  );

  static String get effectiveIosClientId => googleIosClientId;

  static String get effectiveAndroidClientId => googleAndroidClientId;

  static String? get googleClientId {
    if (Platform.isIOS) return effectiveIosClientId;
    if (Platform.isAndroid) return effectiveAndroidClientId;
    return null;
  }

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
