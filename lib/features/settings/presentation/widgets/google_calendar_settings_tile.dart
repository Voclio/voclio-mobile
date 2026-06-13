import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:voclio_app/core/common/dialogs/voclio_dialog.dart';
import 'package:voclio_app/core/config/oauth_config.dart';
import 'package:voclio_app/core/icons/app_icons.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_tokens.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_widgets.dart';
import 'package:voclio_app/features/calendar/data/datasources/calendar_remote_datasource.dart';
import 'package:voclio_app/features/calendar/domain/entities/google_calendar_entity.dart';
import 'package:voclio_app/features/calendar/presentation/bloc/calendar_cubit.dart';

class GoogleCalendarSettingsTile extends StatefulWidget {
  const GoogleCalendarSettingsTile({super.key});

  @override
  State<GoogleCalendarSettingsTile> createState() =>
      _GoogleCalendarSettingsTileState();
}

class _GoogleCalendarSettingsTileState extends State<GoogleCalendarSettingsTile> {
  GoogleCalendarStatusEntity? _status;
  bool _loading = true;
  bool _busy = false;

  CalendarRemoteDataSource get _dataSource =>
      GetIt.I<CalendarRemoteDataSource>();

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    setState(() => _loading = true);
    try {
      final status = await _dataSource.getGoogleCalendarStatus();
      if (mounted) {
        setState(() {
          _status = status;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _status = const GoogleCalendarStatusEntity(
            connected: false,
            syncEnabled: false,
            syncStatus: 'error',
          );
          _loading = false;
        });
      }
    }
  }

  Future<void> _syncCalendarCubit() async {
    try {
      await GetIt.I<CalendarCubit>().checkGoogleCalendarStatus();
    } catch (_) {}
  }

  Future<void> _connect() async {
    setState(() => _busy = true);
    try {
      final urlEntity = await _dataSource.getGoogleConnectUrl(
        isMobile: true,
        customScheme: OAuthConfig.calendarOAuthScheme,
      );

      if (urlEntity.authUrl.isEmpty) {
        throw StateError('Empty auth URL');
      }

      final uri = Uri.parse(urlEntity.authUrl);
      if (!await canLaunchUrl(uri)) {
        throw StateError('Could not open Google sign-in');
      }

      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Calendar connect failed: $e'),
            backgroundColor: HomeSystemTokens.coral,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _disconnect() async {
    final confirmed = await VoclioDialog.showConfirm(
      context: context,
      title: 'Disconnect Google Meet?',
      message:
          'Google Calendar events and Meet links will no longer sync in Voclio.',
      confirmText: 'Disconnect',
      cancelText: 'Cancel',
    );

    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await _dataSource.disconnectGoogleCalendar();
      await _syncCalendarCubit();
      await _loadStatus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Google Meet disconnected'),
            backgroundColor: HomeSystemTokens.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Disconnect failed: $e'),
            backgroundColor: HomeSystemTokens.coral,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showConnectedMenu() {
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: HomeSystemTokens.green.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    AppIcons.videocam_rounded,
                    color: HomeSystemTokens.green,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Google Meet Connected',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _status?.calendarName ?? 'Primary Calendar',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(AppIcons.refresh, color: HomeSystemTokens.purple),
              title: const Text('Refresh connection'),
              onTap: () async {
                Navigator.pop(ctx);
                await _loadStatus();
                await _syncCalendarCubit();
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(AppIcons.link_off, color: HomeSystemTokens.coral),
              title: Text(
                'Disconnect',
                style: TextStyle(color: HomeSystemTokens.coral),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _disconnect();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onTap() {
    if (_busy || _loading) return;

    if (_status?.isConnected == true) {
      _showConnectedMenu();
    } else {
      _connect();
    }
  }

  @override
  Widget build(BuildContext context) {
    final connected = _status?.isConnected ?? false;
    final calendarName = _status?.calendarName?.trim();

    return HomeMenuTile(
      icon: AppIcons.videocam_rounded,
      title: 'Google Meet',
      subtitle: _loading
          ? 'Checking connection...'
          : connected
          ? calendarName?.isNotEmpty == true
              ? '$calendarName · Connected'
              : 'Connected'
          : 'Sync Calendar events and Meet links',
      iconColor: connected ? HomeSystemTokens.green : HomeSystemTokens.blue,
      onTap: _busy || _loading ? null : _onTap,
      trailing: _loading || _busy
          ? SizedBox(
              width: 22.w,
              height: 22.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: HomeSystemTokens.purple,
              ),
            )
          : connected
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: HomeSystemTokens.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    AppIcons.check_circle,
                    size: 12.sp,
                    color: HomeSystemTokens.green,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Connected',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: HomeSystemTokens.green,
                    ),
                  ),
                ],
              ),
            )
          : Text(
              'Connect',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: HomeSystemTokens.purple,
              ),
            ),
      showDivider: false,
    );
  }
}
