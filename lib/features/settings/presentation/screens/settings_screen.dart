import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection_container.dart';
import '../cubit/settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SettingsCubit>()..loadSettings(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                // Theme Setting
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Enable dark theme'),
                  value: state.isDarkMode,
                  onChanged: (value) {
                    context.read<SettingsCubit>().toggleTheme(value);
                  },
                ),
                const Divider(),

                // Language Setting
                ListTile(
                  title: const Text('Language'),
                  subtitle: Text(state.language == 'ar' ? 'Arabic' : 'English'),
                  trailing: DropdownButton<String>(
                    value: state.language,
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'ar', child: Text('العربية')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        context.read<SettingsCubit>().changeLanguage(value);
                      }
                    },
                  ),
                ),
                const Divider(),

                // Notifications Setting
                SwitchListTile(
                  title: const Text('Notifications'),
                  subtitle: const Text('Enable push notifications'),
                  value: state.notificationsEnabled,
                  onChanged: (value) {
                    context.read<SettingsCubit>().toggleNotifications(value);
                  },
                ),
                const Divider(),

                // Timezone Setting
                ListTile(
                  title: const Text('Timezone'),
                  subtitle: Text(state.timezone),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Show timezone picker
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
