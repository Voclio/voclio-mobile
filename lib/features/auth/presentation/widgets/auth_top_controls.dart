import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import 'package:voclio_app/core/app/theme_controller.dart';
import 'package:voclio_app/core/app/language_controller.dart';
import '../../../../core/common/animation/animate_do.dart';

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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        /// 🌍 Language Toggle
        _AnimatedButtonWrapper(
          isActive: LanguageController.instance.isArabic,
          duration: const Duration(milliseconds: 600),
          direction: LanguageController.instance.isArabic
              ? AnimationDirection.right
              : AnimationDirection.left,
          child: GestureDetector(
            onTap: () async {
              await LanguageController.instance.toggleLanguage();
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmall ? 12.w : 14.w,
                vertical: isSmall ? 6.h : 8.h,
              ),
              decoration: BoxDecoration(
                color: colors.primary!.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.language_rounded,
                    color: colors.primary,
                    size: isSmall ? 18.sp : 20.sp,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    LanguageController.instance.isArabic ? 'EN' : 'AR',
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: isSmall ? 14.sp : 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        /// 🌗 Theme Toggle
        _AnimatedButtonWrapper(
          isActive: ThemeController.instance.isDarkMode.value,
          duration: const Duration(milliseconds: 600),
          direction: ThemeController.instance.isDarkMode.value
              ? AnimationDirection.left
              : AnimationDirection.right,
          child: GestureDetector(
            onTap: () async {
              await ThemeController.instance.toggleTheme();
            },
            child: Container(
              padding: EdgeInsets.all(isSmall ? 8.w : 10.w),
              decoration: BoxDecoration(
                color: colors.primary!.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Icon(
                ThemeController.instance.isDarkMode.value
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                color: colors.primary,
                size: isSmall ? 20.sp : 22.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 🎬 Widget مخصص بيعمل أنيميشن ناعم في الاتجاه المطلوب
enum AnimationDirection { left, right }

class _AnimatedButtonWrapper extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final Duration duration;
  final AnimationDirection direction;

  const _AnimatedButtonWrapper({
    required this.child,
    required this.isActive,
    required this.duration,
    required this.direction,
  });

  @override
  State<_AnimatedButtonWrapper> createState() => _AnimatedButtonWrapperState();
}

class _AnimatedButtonWrapperState extends State<_AnimatedButtonWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    _setupAnimations();
    _controller.forward();
  }

  void _setupAnimations() {
    final beginOffset = widget.direction == AnimationDirection.right
        ? const Offset(0.3, 0)
        : const Offset(-0.3, 0);

    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _rotateAnimation = Tween<double>(
      begin: widget.direction == AnimationDirection.right ? 0.05 : -0.05,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant _AnimatedButtonWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: RotationTransition(
          turns: _rotateAnimation,
          child: widget.child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
