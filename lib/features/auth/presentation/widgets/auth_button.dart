import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import '../../../../core/common/animation/animate_do.dart';
import '../../../../core/styles/fonts/font_weight_helper.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Color? backgroundColor;
  final Color? textColor;

  const AuthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    final effectiveBackgroundColor = backgroundColor ?? colors.primary!;
    final effectiveTextColor = textColor ?? Colors.white;

    return CustomFadeInUp(
      duration: 600,
      child: SizedBox(
        width: double.infinity,
        height: isSmall ? 50.h : 56.h,
        child: ElevatedButton(
          onPressed: isEnabled && !isLoading ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: effectiveBackgroundColor,
            disabledBackgroundColor: effectiveBackgroundColor.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isSmall ? 10.r : 12.r),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          child: isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: isSmall ? 18.w : 20.w,
                      height: isSmall ? 18.h : 20.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
                      ),
                    ),
                    SizedBox(width: isSmall ? 8.w : 12.w),
                    Text(
                      'Loading...',
                      style: context.textStyle.copyWith(
                        fontSize: isSmall ? 12.sp : 14.sp,
                        fontWeight: FontWeightHelper.medium,
                        color: effectiveTextColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                )
              : Text(
                  text,
                  style: context.textStyle.copyWith(
                    fontSize: isSmall ? 14.sp : 16.sp,
                    fontWeight: FontWeightHelper.semiBold,
                    color: effectiveTextColor,
                  ),
                ),
        ),
      ),
    );
  }
}
