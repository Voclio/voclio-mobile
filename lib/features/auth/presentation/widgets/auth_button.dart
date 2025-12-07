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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          boxShadow:
              isEnabled && !isLoading
                  ? [
                    BoxShadow(
                      color: effectiveBackgroundColor.withOpacity(0.35),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                      spreadRadius: 0,
                    ),
                  ]
                  : [],
        ),
        child: SizedBox(
          width: double.infinity,
          height: isSmall ? 54.h : 60.h,
          child: ElevatedButton(
            onPressed: isEnabled && !isLoading ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: effectiveBackgroundColor,
              disabledBackgroundColor: effectiveBackgroundColor.withOpacity(
                0.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
            child:
                isLoading
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: isSmall ? 20.w : 22.w,
                          height: isSmall ? 20.h : 22.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              effectiveTextColor,
                            ),
                          ),
                        ),
                        SizedBox(width: isSmall ? 10.w : 12.w),
                        Text(
                          'Loading...',
                          style: context.textStyle.copyWith(
                            fontSize: isSmall ? 14.sp : 16.sp,
                            fontWeight: FontWeight.w600,
                            color: effectiveTextColor.withOpacity(0.8),
                          ),
                        ),
                      ],
                    )
                    : Text(
                      text,
                      style: context.textStyle.copyWith(
                        fontSize: isSmall ? 16.sp : 18.sp,
                        fontWeight: FontWeight.bold,
                        color: effectiveTextColor,
                        letterSpacing: 0.5,
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}
