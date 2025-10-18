import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import 'package:voclio_app/core/app/theme_controller.dart';
import 'package:voclio_app/core/app/language_controller.dart';
import '../../../../core/common/animation/animate_do.dart';
import '../../../../core/common/animation/smooth_toggle_animation.dart';

class AuthTopControls extends StatelessWidget {
  const AuthTopControls({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeController.instance.isDarkMode,
      builder: (context, isDarkMode, child) {
        return ValueListenableBuilder<Locale>(
          valueListenable: LanguageController.instance.currentLocale,
          builder: (context, locale, child) {
            return _buildTopControls(context);
          },
        );
      },
    );
  }

  Widget _buildTopControls(BuildContext context) {
    final colors = context.colors;
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: isSmall ? 8.h : 12.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button placeholder (can be used for navigation)
          SizedBox(width: 50.w),
          
          // Toggle controls
          Row(
            children: [
              // Language Toggle Button
              CustomFadeInRight(
                duration: 600,
                child: GestureDetector(
                  onTap: () async {
                    await LanguageController.instance.toggleLanguage();
                  },
                  child: SmoothContainerTransition(
                    isActive: LanguageController.instance.isArabic,
                    activeColor: colors.primary!.withOpacity(0.2),
                    inactiveColor: colors.primary!.withOpacity(0.1),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    borderRadius: 20,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmall ? 10.w : 12.w,
                        vertical: isSmall ? 6.h : 8.h,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SmoothToggleAnimation(
                            isActive: LanguageController.instance.isArabic,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.elasticOut,
                            rotationAngle: 0.25,
                            child: Icon(
                              Icons.language_rounded,
                              color: colors.primary,
                              size: isSmall ? 16.sp : 18.sp,
                            ),
                          ),
                          SizedBox(width: isSmall ? 4.w : 6.w),
                          SmoothTextTransition(
                            text: LanguageController.instance.isArabic ? 'EN' : 'AR',
                            isActive: LanguageController.instance.isArabic,
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                            textColor: colors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: isSmall ? 8.w : 12.w),
              // Dark Mode Toggle Button
              CustomFadeInRight(
                duration: 700,
                child: GestureDetector(
                  onTap: () async {
                    await ThemeController.instance.toggleTheme();
                  },
                  child: SmoothContainerTransition(
                    isActive: ThemeController.instance.isDarkMode.value,
                    activeColor: colors.primary!.withOpacity(0.2),
                    inactiveColor: colors.primary!.withOpacity(0.1),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    borderRadius: 20,
                    child: Padding(
                      padding: EdgeInsets.all(isSmall ? 6.w : 8.w),
                      child: SmoothToggleAnimation(
                        isActive: ThemeController.instance.isDarkMode.value,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.elasticOut,
                        rotationAngle: 0.5,
                        scaleEffect: true,
                        child: Icon(
                          ThemeController.instance.isDarkMode.value
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          color: colors.primary,
                          size: isSmall ? 18.sp : 20.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
