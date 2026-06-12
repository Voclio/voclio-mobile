import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/constants/app_assets.dart';
import 'package:voclio_app/core/icons/app_icons.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_tokens.dart';

enum VoclioDialogType { info, success, error, warning, confirm }

class VoclioDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoclioDialogType type;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;

  const VoclioDialog({
    super.key,
    required this.title,
    required this.message,
    this.type = VoclioDialogType.info,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    VoclioDialogType type = VoclioDialogType.info,
    String? primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Voclio Dialog',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return VoclioDialog(
          title: title,
          message: message,
          type: type,
          primaryButtonText: primaryButtonText,
          secondaryButtonText: secondaryButtonText,
          onPrimaryPressed: onPrimaryPressed,
          onSecondaryPressed: onSecondaryPressed,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
    );
  }

  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
    bool barrierDismissible = true,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      type: VoclioDialogType.success,
      primaryButtonText: buttonText,
      barrierDismissible: barrierDismissible,
      onPrimaryPressed: () {
        Navigator.of(context).pop();
        onPressed?.call();
      },
    );
  }

  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
    bool barrierDismissible = true,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      type: VoclioDialogType.error,
      primaryButtonText: buttonText,
      barrierDismissible: barrierDismissible,
      onPrimaryPressed: () {
        Navigator.of(context).pop();
        onPressed?.call();
      },
    );
  }

  static Future<bool?> showConfirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      type: VoclioDialogType.confirm,
      primaryButtonText: confirmText,
      secondaryButtonText: cancelText,
      barrierDismissible: barrierDismissible,
      onPrimaryPressed: () {
        Navigator.of(context).pop(true);
        onConfirm?.call();
      },
      onSecondaryPressed: () {
        Navigator.of(context).pop(false);
        onCancel?.call();
      },
    );
  }

  Color get _accentColor {
    switch (type) {
      case VoclioDialogType.success:
        return HomeSystemTokens.green;
      case VoclioDialogType.error:
        return HomeSystemTokens.coral;
      case VoclioDialogType.warning:
        return HomeSystemTokens.orange;
      case VoclioDialogType.confirm:
      case VoclioDialogType.info:
        return HomeSystemTokens.purple;
    }
  }

  IconData? get _leadingIcon {
    switch (type) {
      case VoclioDialogType.success:
        return AppIcons.check_circle_rounded;
      case VoclioDialogType.error:
        return AppIcons.error_rounded;
      case VoclioDialogType.warning:
        return AppIcons.warning_rounded;
      case VoclioDialogType.info:
        return AppIcons.info_rounded;
      case VoclioDialogType.confirm:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _leadingIcon;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 40.w),
          constraints: BoxConstraints(maxWidth: 300.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DialogBrand(accent: _accentColor),
                SizedBox(height: 14.h),
                if (icon != null) ...[
                  Icon(icon, size: 26.sp, color: _accentColor),
                  SizedBox(height: 10.h),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: HomeSystemTokens.ink,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: HomeSystemTokens.inkSoft,
                    height: 1.45,
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    if (secondaryButtonText != null) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                              onSecondaryPressed ??
                              () => Navigator.of(context).pop(false),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 11.h),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: Text(
                            secondaryButtonText!,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: HomeSystemTokens.inkSoft,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                    ],
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            onPrimaryPressed ??
                            () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 11.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: Text(
                          primaryButtonText ?? 'OK',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogBrand extends StatelessWidget {
  const _DialogBrand({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: AppLogo(width: 28.w, height: 28.w),
            ),
            SizedBox(width: 6.w),
            Text(
              'Voclio',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: accent,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Divider(height: 1, color: Colors.grey.shade200),
      ],
    );
  }
}
