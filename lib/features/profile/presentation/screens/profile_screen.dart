import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:voclio_app/core/routes/App_routes.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_tokens.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_widgets.dart';
import 'edit_profile_screen.dart';
import 'privacy_policy_screen.dart';
import 'about_screen.dart';
import 'package:voclio_app/core/icons/app_icons.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeSecondaryScaffold(
      title: 'Profile',
      subtitle: 'Manage your account',
      icon: AppIcons.person_rounded,
      accent: HomeSystemTokens.purple,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
        child: Column(
          children: [
            HomeSectionCard(
              child: Column(
                children: [
                  Container(
                    width: 100.r,
                    height: 100.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          HomeSystemTokens.purple,
                          HomeSystemTokens.purple.withValues(alpha: 0.7),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: HomeSystemTokens.purple.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(AppIcons.person, size: 50.sp, color: Colors.white),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'User Name',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: HomeSystemTokens.ink,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'user@example.com',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: HomeSystemTokens.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            HomeSettingsGroup(
              title: 'Quick Access',
              children: [
                HomeMenuTile(
                  icon: AppIcons.dashboard_outlined,
                  title: 'Dashboard',
                  subtitle: 'Activity & productivity stats',
                  iconColor: HomeSystemTokens.purple,
                  onTap: () => context.push(AppRouter.dashboard),
                ),
                HomeMenuTile(
                  icon: AppIcons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Manage your notifications',
                  iconColor: HomeSystemTokens.blue,
                  onTap: () => context.push(AppRouter.notifications),
                ),
                HomeMenuTile(
                  icon: AppIcons.emoji_events_outlined,
                  title: 'Achievements',
                  subtitle: 'View your milestones',
                  iconColor: HomeSystemTokens.orange,
                  onTap: () => context.push(AppRouter.achievements),
                ),
                HomeMenuTile(
                  icon: AppIcons.settings_outlined,
                  title: 'Settings',
                  subtitle: 'App preferences & account',
                  iconColor: HomeSystemTokens.inkSoft,
                  onTap: () => context.push(AppRouter.settings),
                  showDivider: false,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            HomeSettingsGroup(
              title: 'Account',
              children: [
                HomeMenuTile(
                  icon: AppIcons.edit_outlined,
                  title: 'Edit Profile',
                  iconColor: HomeSystemTokens.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),
                HomeMenuTile(
                  icon: AppIcons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  iconColor: HomeSystemTokens.inkSoft,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                ),
                HomeMenuTile(
                  icon: AppIcons.info_outline,
                  title: 'About',
                  iconColor: HomeSystemTokens.inkSoft,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutScreen(),
                      ),
                    );
                  },
                ),
                HomeMenuTile(
                  icon: AppIcons.logout_rounded,
                  title: 'Logout',
                  iconColor: HomeSystemTokens.coral,
                  showDivider: false,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text(
                          'Are you sure you want to logout?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              // Add logout logic
                            },
                            child: const Text(
                              'Logout',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
