import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import '../../../../core/common/animation/animate_do.dart';
import '../../../../core/styles/fonts/font_weight_helper.dart';

class AuthLinkButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? textColor;

  const AuthLinkButton({
    super.key,
    required this.text,
    this.onPressed,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    final effectiveTextColor = textColor ?? colors.primary!;

    return CustomFadeInUp(
      duration: 600,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 12.w : 16.w,
            vertical: isSmall ? 6.h : 8.h,
          ),
        ),
        child: Text(
          text,
          style: context.textStyle.copyWith(
            fontSize: isSmall ? 12.sp : 14.sp,
            fontWeight: FontWeightHelper.medium,
            color: effectiveTextColor,
            decoration: TextDecoration.underline,
            decorationColor: effectiveTextColor,
          ),
        ),
      ),
    );
  }
}
