import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import '../../../../core/common/animation/animate_do.dart';
import '../../../../core/styles/fonts/font_weight_helper.dart';

class VoclioLogo extends StatelessWidget {
  final double? size;
  final Color? logoColor;
  final Color? textColor;
  final bool showText;

  const VoclioLogo({
    super.key,
    this.size,
    this.logoColor,
    this.textColor,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmall = screenSize.height < 700;
    final effectiveSize = size ?? (isSmall ? 60.w : 80.w);
    final effectiveLogoColor = logoColor ?? context.colors.primary!;
    final effectiveTextColor = textColor ?? context.colors.primary!;

    return CustomFadeInUp(
      duration: 600,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: effectiveSize,
            height: effectiveSize,
            child: Image.asset(
              'assets/images/Microphone Icon.png',
              fit: BoxFit.contain,
              color: effectiveLogoColor,
              colorBlendMode: BlendMode.srcIn,
            ),
          ),
          if (showText) ...[
            SizedBox(width: isSmall ? 12.w : 16.w),
            Text(
              'Voclio',
              style: context.textStyle.copyWith(
                fontSize: isSmall ? 24.sp : 32.sp,
                fontWeight: FontWeightHelper.bold,
                color: effectiveTextColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class VoclioLogoSmall extends StatelessWidget {
  final Color? color;
  final double? size;

  const VoclioLogoSmall({
    super.key,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmall = screenSize.height < 700;
    final effectiveSize = size ?? (isSmall ? 24.w : 32.w);
    final effectiveColor = color ?? context.colors.primary!;

    return Container(
      width: effectiveSize,
      height: effectiveSize,
      child: Image.asset(
        'assets/images/Microphone Icon.png',
        fit: BoxFit.contain,
        color: effectiveColor,
        colorBlendMode: BlendMode.srcIn,
      ),
    );
  }
}
