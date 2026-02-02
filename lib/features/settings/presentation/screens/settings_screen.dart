import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/di/injection_container.dart';
import 'package:voclio_app/features/settings/presentation/cubit/settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsCubit>(
      create: (context) => getIt<SettingsCubit>()..loadSettings(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text('Settings'),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1A1A2E),
        ),
        body: BlocListener<SettingsCubit, SettingsState>(
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              if (state.isLoading && state.theme.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                children: [
                  _buildSectionHeader('Appearance'),
                  _buildCard([
                    _buildThemeTile(context, state.theme),
                    _buildLanguageTile(context, state.language),
                    _buildTimezoneTile(context, state.timezone),
                  ]),
                  SizedBox(height: 24.h),

                  _buildSectionHeader('Notifications'),
                  _buildCard([
                    _buildSwitchTile(
                      context,
                      'Push Notifications',
                      'Receive alerts on your device',
                      Icons.notifications_active_outlined,
                      state.pushEnabled,
                      (val) => context
                          .read<SettingsCubit>()
                          .updateNotificationPreference(pushEnabled: val),
                    ),
                    _buildSwitchTile(
                      context,
                      'Email Notifications',
                      'Get updates in your inbox',
                      Icons.email_outlined,
                      state.emailEnabled,
                      (val) => context
                          .read<SettingsCubit>()
                          .updateNotificationPreference(emailEnabled: val),
                    ),
                    _buildSwitchTile(
                      context,
                      'WhatsApp Notifications',
                      'Updates via WhatsApp',
                      Icons.message_outlined,
                      state.whatsappEnabled,
                      (val) => context
                          .read<SettingsCubit>()
                          .updateNotificationPreference(whatsappEnabled: val),
                    ),
                  ]),
                  SizedBox(height: 24.h),

                  _buildSectionHeader('Email Preferences'),
                  _buildCard([
                    _buildSwitchTile(
                      context,
                      'Reminders via Email',
                      'Never miss a goal session',
                      Icons.alarm,
                      state.emailForReminders,
                      (val) => context
                          .read<SettingsCubit>()
                          .updateNotificationPreference(emailForReminders: val),
                    ),
                    _buildSwitchTile(
                      context,
                      'Tasks via Email',
                      'Daily task summaries',
                      Icons.task_alt,
                      state.emailForTasks,
                      (val) => context
                          .read<SettingsCubit>()
                          .updateNotificationPreference(emailForTasks: val),
                    ),
                  ]),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildThemeTile(BuildContext context, String currentTheme) {
    return ListTile(
      leading: const Icon(Icons.palette_outlined, color: Color(0xFF6366F1)),
      title: const Text('Theme Mode'),
      trailing: DropdownButton<String>(
        value: currentTheme,
        underline: const SizedBox(),
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
    return ListTile(
      leading: const Icon(Icons.language_outlined, color: Color(0xFF10B981)),
      title: const Text('Language'),
      trailing: DropdownButton<String>(
        value: currentLang,
        underline: const SizedBox(),
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
    return ListTile(
      leading: const Icon(Icons.public_outlined, color: Color(0xFFF59E0B)),
      title: const Text('Timezone'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            currentTz,
            style: TextStyle(color: Colors.grey[600], fontSize: 13.sp),
          ),
          SizedBox(width: 4.w),
          const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
        ],
      ),
      onTap: () {
        // Implement TZ picker
      },
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      secondary: Icon(icon, color: const Color(0xFF64748B)),
      title: Text(
        title,
        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
      ),
      value: value,
      activeColor: const Color(0xFF6366F1),
      onChanged: onChanged,
    );
  }
}
