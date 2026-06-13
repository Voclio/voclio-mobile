import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:voclio_app/core/config/oauth_config.dart';

/// Shared Google Sign-In client for auth (keeps iOS OAuth session across attempts).
class GoogleSignInService {
  GoogleSignInService._();

  static final GoogleSignInService instance = GoogleSignInService._();

  GoogleSignIn? _client;

  GoogleSignIn get client {
    _client ??= GoogleSignIn(
      scopes: const ['email', 'profile'],
      serverClientId: OAuthConfig.googleWebClientId,
      clientId: Platform.isIOS
          ? OAuthConfig.effectiveIosClientId
          : Platform.isAndroid
              ? OAuthConfig.effectiveAndroidClientId
              : null,
    );
    return _client!;
  }

  Future<GoogleSignInAccount?> signInInteractive() async {
    final googleSignIn = client;

    final cachedUser = await googleSignIn.signInSilently();
    if (cachedUser != null) {
      return cachedUser;
    }

    return googleSignIn.signIn();
  }

  Future<void> signOut() async {
    await client.signOut();
  }
}
