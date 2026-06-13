import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:voclio_app/core/config/oauth_config.dart';
import 'package:voclio_app/core/routes/App_routes.dart';
import 'package:voclio_app/features/calendar/presentation/bloc/calendar_cubit.dart';
import 'package:voclio_app/features/calendar/presentation/bloc/calendar_state.dart';

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
    final messenger = ScaffoldMessenger.maybeOf(context);
    final cubit = context.read<CalendarCubit>();

    try {
      await cubit.handleOAuthCallback(code);
      if (!mounted) return;

      if (cubit.state is GoogleCalendarConnected ||
          cubit.state is CalendarLoaded) {
        messenger?.showSnackBar(
          const SnackBar(
            content: Text('Google Calendar connected successfully'),
          ),
        );
      } else if (cubit.state is CalendarError) {
        messenger?.showSnackBar(
          SnackBar(
            content: Text((cubit.state as CalendarError).message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger?.showSnackBar(
        SnackBar(
          content: Text('Failed to connect Google Calendar: $e'),
          backgroundColor: Colors.red,
        ),
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
