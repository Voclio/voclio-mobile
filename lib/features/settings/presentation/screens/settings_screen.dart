import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/di/injection_container.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_tokens.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_widgets.dart';
import 'package:voclio_app/features/settings/presentation/cubit/settings_cubit.dart';

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
          }
        },
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            return HomeSecondaryScaffold(
              title: 'Settings',
              subtitle: 'Customize your experience',
              icon: Icons.settings_rounded,
              accent: HomeSystemTokens.purple,
              showBack: false,
              body: state.isLoading && state.theme.isEmpty
                  ? Center(
                      child: CircularProgressIndicator(
                        color: HomeSystemTokens.purple,
                      ),
                    )
                  : ListView(
                      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                      children: [
                        HomeSettingsGroup(
                          title: 'Appearance',
                          children: [
                            _buildThemeTile(context, state.theme),
                            _buildLanguageTile(context, state.language),
                            _buildTimezoneTile(context, state.timezone),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        HomeSettingsGroup(
                          title: 'Notifications',
                          children: [
                            _buildSwitchTile(
                              context,
                              'Push Notifications',
                              'Receive alerts on your device',
                              Icons.notifications_active_outlined,
                              HomeSystemTokens.blue,
                              state.pushEnabled,
                              (val) => context
                                  .read<SettingsCubit>()
                                  .updateNotificationPreference(
                                    pushEnabled: val,
                                  ),
                            ),
                            _buildSwitchTile(
                              context,
                              'Email Notifications',
                              'Get updates in your inbox',
                              Icons.email_outlined,
                              HomeSystemTokens.green,
                              state.emailEnabled,
                              (val) => context
                                  .read<SettingsCubit>()
                                  .updateNotificationPreference(
                                    emailEnabled: val,
                                  ),
                            ),
                            _buildSwitchTile(
                              context,
                              'WhatsApp Notifications',
                              'Updates via WhatsApp',
                              Icons.message_outlined,
                              HomeSystemTokens.orange,
                              state.whatsappEnabled,
                              (val) => context
                                  .read<SettingsCubit>()
                                  .updateNotificationPreference(
                                    whatsappEnabled: val,
                                  ),
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
                              'Never miss a goal session',
                              Icons.alarm_rounded,
                              HomeSystemTokens.orange,
                              state.emailForReminders,
                              (val) => context
                                  .read<SettingsCubit>()
                                  .updateNotificationPreference(
                                    emailForReminders: val,
                                  ),
                            ),
                            _buildSwitchTile(
                              context,
                              'Tasks via Email',
                              'Daily task summaries',
                              Icons.task_alt_rounded,
                              HomeSystemTokens.purple,
                              state.emailForTasks,
                              (val) => context
                                  .read<SettingsCubit>()
                                  .updateNotificationPreference(
                                    emailForTasks: val,
                                  ),
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

  Widget _buildThemeTile(BuildContext context, String currentTheme) {
    return HomeMenuTile(
      icon: Icons.palette_outlined,
      title: 'Theme Mode',
      iconColor: HomeSystemTokens.purple,
      trailing: DropdownButton<String>(
        value: currentTheme,
        underline: const SizedBox(),
        style: TextStyle(
          fontSize: 14.sp,
          color: HomeSystemTokens.inkSoft,
          fontWeight: FontWeight.w500,
        ),
        items: const [
          DropdownMenuItem(value: 'light', child: Text('Light')),
          DropdownMenuItem(value: 'dark', child: Text('Dark')),
          DropdownMenuItem(value: 'auto', child: Text('System')),
        ],
        onChanged: (val) {
          if (val != null) context.read<SettingsCubit>().updateTheme(val);
        },
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context, String currentLang) {
    return HomeMenuTile(
      icon: Icons.language_outlined,
      title: 'Language',
      iconColor: HomeSystemTokens.green,
      trailing: DropdownButton<String>(
        value: currentLang,
        underline: const SizedBox(),
        style: TextStyle(
          fontSize: 14.sp,
          color: HomeSystemTokens.inkSoft,
          fontWeight: FontWeight.w500,
        ),
        items: const [
          DropdownMenuItem(value: 'en', child: Text('English')),
          DropdownMenuItem(value: 'ar', child: Text('العربية')),
        ],
        onChanged: (val) {
          if (val != null) context.read<SettingsCubit>().updateLanguage(val);
        },
      ),
    );
  }

  Widget _buildTimezoneTile(BuildContext context, String currentTz) {
    return HomeMenuTile(
      icon: Icons.public_outlined,
      title: 'Timezone',
      iconColor: HomeSystemTokens.orange,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            currentTz,
            style: TextStyle(
              color: HomeSystemTokens.inkMuted,
              fontSize: 13.sp,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(
            Icons.chevron_right_rounded,
            size: 22.sp,
            color: HomeSystemTokens.inkMuted,
          ),
        ],
      ),
      onTap: () {
        // Implement TZ picker
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
    ValueChanged<bool> onChanged, {
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
}
