import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/di/injection_container.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_tokens.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_widgets.dart';
import 'package:voclio_app/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:voclio_app/features/settings/presentation/widgets/google_calendar_settings_tile.dart';
import 'package:voclio_app/features/settings/presentation/widgets/timezone_picker_sheet.dart';
import 'package:voclio_app/features/widget_config/presentation/bloc/widget_config_cubit.dart';
import 'package:voclio_app/features/widget_config/presentation/bloc/widget_config_state.dart';
import 'package:voclio_app/features/widget_config/presentation/widgets/widget_setup_dialog.dart';
import 'package:voclio_app/core/icons/app_icons.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsCubit>(
      create: (context) => getIt<SettingsCubit>()..loadSettings(),
      child: BlocListener<SettingsCubit, SettingsState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: HomeSystemTokens.coral,
              ),
            );
            context.read<SettingsCubit>().clearError();
          }
        },
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            final busy = state.isLoading;

            return HomeSecondaryScaffold(
              title: 'Settings',
              subtitle: 'Customize your experience',
              icon: AppIcons.settings_rounded,
              accent: HomeSystemTokens.purple,
              showBack: false,
              body: ListView(
                      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                      children: [
                        HomeSettingsGroup(
                          title: 'Home',
                          children: [
                            BlocBuilder<WidgetConfigCubit, WidgetConfigState>(
                              builder: (context, widgetState) {
                                final count = widgetState.enabledWidgets.length;
                                return HomeMenuTile(
                                  icon: AppIcons.widgets_outlined,
                                  title: 'Home Widgets',
                                  subtitle:
                                      '$count widget${count == 1 ? '' : 's'} enabled',
                                  iconColor: HomeSystemTokens.purple,
                                  onTap: busy
                                      ? null
                                      : () => _openHomeWidgetsSettings(context),
                                  showDivider: false,
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        HomeSettingsGroup(
                          title: 'Integrations',
                          children: const [
                            GoogleCalendarSettingsTile(),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        HomeSettingsGroup(
                          title: 'Appearance',
                          children: [
                            _buildTimezoneTile(context, state.timezone, busy),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        HomeSettingsGroup(
                          title: 'Notifications',
                          children: [
                            _buildSwitchTile(
                              context,
                              'In-app Notifications',
                              'Alerts inside Voclio',
                              AppIcons.notifications_active_outlined,
                              HomeSystemTokens.blue,
                              state.pushEnabled,
                              busy
                                  ? null
                                  : (val) => context
                                      .read<SettingsCubit>()
                                      .updateNotificationPreference(
                                        pushEnabled: val,
                                      ),
                            ),
                            _buildSwitchTile(
                              context,
                              'Email Notifications',
                              'Master switch for email updates',
                              AppIcons.email_outlined,
                              HomeSystemTokens.green,
                              state.emailEnabled,
                              busy
                                  ? null
                                  : (val) => context
                                      .read<SettingsCubit>()
                                      .updateNotificationPreference(
                                        emailEnabled: val,
                                      ),
                            ),
                            _buildDisabledTile(
                              context,
                              'WhatsApp Notifications',
                              'Coming soon',
                              AppIcons.message_outlined,
                              HomeSystemTokens.orange,
                              showDivider: false,
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        HomeSettingsGroup(
                          title: 'Email Preferences',
                          children: [
                            _buildSwitchTile(
                              context,
                              'Reminders via Email',
                              'Email when a reminder is due',
                              AppIcons.alarm_rounded,
                              HomeSystemTokens.orange,
                              state.emailForReminders,
                              busy || !state.emailEnabled
                                  ? null
                                  : (val) => context
                                      .read<SettingsCubit>()
                                      .updateNotificationPreference(
                                        emailForReminders: val,
                                      ),
                            ),
                            _buildDisabledTile(
                              context,
                              'Tasks via Email',
                              'Coming soon',
                              AppIcons.task_alt_rounded,
                              HomeSystemTokens.purple,
                              showDivider: false,
                            ),
                          ],
                        ),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openHomeWidgetsSettings(BuildContext context) async {
    final saved = await WidgetSetupDialog.show(
      context,
      isEditMode: true,
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Home widgets updated'),
          backgroundColor: HomeSystemTokens.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildTimezoneTile(
    BuildContext context,
    String currentTz,
    bool busy,
  ) {
    return HomeMenuTile(
      icon: AppIcons.public_outlined,
      title: 'Timezone',
      iconColor: HomeSystemTokens.orange,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 150.w),
            child: Text(
              currentTz.replaceAll('_', ' '),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: HomeSystemTokens.inkMuted,
                fontSize: 13.sp,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Icon(
            AppIcons.chevron_right_rounded,
            size: 22.sp,
            color: HomeSystemTokens.inkMuted,
          ),
        ],
      ),
      onTap: busy
          ? null
          : () async {
              final selected = await TimezonePickerSheet.show(context, currentTz);
              if (selected != null && context.mounted) {
                context.read<SettingsCubit>().updateTimezone(selected);
              }
            },
      showDivider: false,
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    bool value,
    ValueChanged<bool>? onChanged, {
    bool showDivider = true,
  }) {
    return HomeMenuTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      iconColor: iconColor,
      showDivider: showDivider,
      trailing: Switch(
        value: value,
        activeTrackColor: HomeSystemTokens.purple,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDisabledTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor, {
    bool showDivider = true,
  }) {
    return Opacity(
      opacity: 0.55,
      child: HomeMenuTile(
        icon: icon,
        title: title,
        subtitle: subtitle,
        iconColor: iconColor,
        showDivider: showDivider,
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: HomeSystemTokens.canvas,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            'Soon',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: HomeSystemTokens.inkMuted,
            ),
          ),
        ),
      ),
    );
  }
}
