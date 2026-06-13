import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:voclio_app/core/config/oauth_config.dart';
import 'package:voclio_app/core/routes/App_routes.dart';

/// Listens for `voclio://oauth/callback?code=...` and completes Google Calendar linking.
class CalendarOAuthLinkHandler extends StatefulWidget {
  final Widget child;

  const CalendarOAuthLinkHandler({super.key, required this.child});

  @override
  State<CalendarOAuthLinkHandler> createState() =>
      _CalendarOAuthLinkHandlerState();
}

class _CalendarOAuthLinkHandlerState extends State<CalendarOAuthLinkHandler> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  bool _handlingCallback = false;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleUri(initialUri);
      }
    } catch (_) {
      // Ignore malformed launch links.
    }

    _linkSubscription = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (_) {},
    );
  }

  void _handleUri(Uri uri) {
    if (_isCalendarOAuthCallback(uri)) {
      _handleOAuthUri(uri);
      return;
    }
    if (_isWidgetHomeLink(uri)) {
      AppRouter.router.go(AppRouter.home);
    }
  }

  bool _isWidgetHomeLink(Uri uri) {
    if (uri.scheme != OAuthConfig.calendarOAuthScheme) return false;
    return uri.host == 'home' || uri.path == '/home';
  }

  Future<void> _handleOAuthUri(Uri uri) async {
    if (_handlingCallback) return;
    if (!_isCalendarOAuthCallback(uri)) return;

    final code = uri.queryParameters['code'];
    if (code == null || code.isEmpty) return;

    _handlingCallback = true;
    try {
      AppRouter.router.go(
        '${AppRouter.calendar}?oauth_code=${Uri.encodeComponent(code)}',
      );
    } finally {
      _handlingCallback = false;
    }
  }

  bool _isCalendarOAuthCallback(Uri uri) {
    if (uri.scheme != OAuthConfig.calendarOAuthScheme) return false;
    if (uri.host != 'oauth') return false;
    return uri.path == '/callback' || uri.path.isEmpty;
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
