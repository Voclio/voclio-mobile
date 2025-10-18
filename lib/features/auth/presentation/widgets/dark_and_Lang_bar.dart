import 'package:flutter/material.dart';
import 'package:voclio_app/core/app/theme_controller.dart';
import 'package:voclio_app/core/app/language_controller.dart';

import '../../../../core/common/animation/animate_do.dart';
import '../../../../core/common/animation/smooth_toggle_animation.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';


class DarkAndLangBar extends StatelessWidget {
  const DarkAndLangBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeController.instance.isDarkMode,
      builder: (context, isDarkMode, child) {
        return ValueListenableBuilder<Locale>(
          valueListenable: LanguageController.instance.currentLocale,
          builder: (context, locale, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Dark Mode Button with Smooth Animation
                CustomFadeInRight(
                  duration: 600,
                  child: GestureDetector(
                    onTap: () async {
                      await ThemeController.instance.toggleTheme();
                    },
                    child: SmoothContainerTransition(
                      isActive: isDarkMode,
                      activeColor: Colors.white.withOpacity(0.2),
                      inactiveColor: Colors.white.withOpacity(0.1),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      borderRadius: 25,
                      child: Container(
                        width: 50.w,
                        height: 50.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: SmoothToggleAnimation(
                            isActive: isDarkMode,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.elasticOut,
                            rotationAngle: 0.5,
                            scaleEffect: true,
                            child: Icon(
                              isDarkMode
                                  ? Icons.light_mode_rounded
                                  : Icons.dark_mode_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Language Button with Smooth Animation
                CustomFadeInLeft(
                  duration: 600,
                  child: GestureDetector(
                    onTap: () async {
                      await LanguageController.instance.toggleLanguage();
                    },
                    child: SmoothContainerTransition(
                      isActive: LanguageController.instance.isArabic,
                      activeColor: Colors.white.withOpacity(0.2),
                      inactiveColor: Colors.white.withOpacity(0.1),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      borderRadius: 25,
                      child: Container(
                        width: 100.w,
                        height: 50.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SmoothToggleAnimation(
                              isActive: LanguageController.instance.isArabic,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.elasticOut,
                              rotationAngle: 0.25,
                              child: Icon(
                                Icons.language_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SmoothTextTransition(
                              text: LanguageController.instance.isArabic ? 'EN' : 'AR',
                              isActive: LanguageController.instance.isArabic,
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeInOut,
                              textColor: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
