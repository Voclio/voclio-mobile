import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_tokens.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_widgets.dart';
import 'package:voclio_app/core/icons/app_icons.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeSecondaryScaffold(
      title: 'About',
      subtitle: 'Voclio · Productivity companion',
      icon: AppIcons.info_outline_rounded,
      accent: HomeSystemTokens.blue,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
        child: Column(
          children: [
            HomeSectionCard(
              padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 20.w),
              child: Column(
                children: [
                  Container(
                    width: 88.r,
                    height: 88.r,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          HomeSystemTokens.purple,
                          HomeSystemTokens.purple.withValues(alpha: 0.75),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(22.r),
                      boxShadow: HomeSystemTokens.cardShadow(opacity: 0.08),
                    ),
                    child: Icon(AppIcons.mic_rounded, color: Colors.white, size: 42.sp),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Voclio',
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w800,
                      color: HomeSystemTokens.ink,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: HomeSystemTokens.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            HomeSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your voice-powered productivity hub',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: HomeSystemTokens.ink,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Voclio helps you capture ideas, manage tasks, and stay focused — with voice notes, smart reminders, and a calm home-style dashboard.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.55,
                      color: HomeSystemTokens.inkSoft,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            HomeSettingsGroup(
              title: 'Connect',
              children: [
                HomeMenuTile(
                  icon: AppIcons.language_rounded,
                  iconColor: HomeSystemTokens.blue,
                  title: 'Website',
                  subtitle: 'voclio.app',
                  showDivider: false,
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Text(
              '© ${DateTime.now().year} Voclio. All rights reserved.',
              style: TextStyle(fontSize: 12.sp, color: HomeSystemTokens.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}
