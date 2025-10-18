
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';

import '../../../../core/common/animation/animate_do.dart';
import '../../../../core/common/inputs/text_app.dart';
import '../../../../core/styles/fonts/font_weight_helper.dart';


class AuthTitleInfo extends StatelessWidget {
  const AuthTitleInfo({
    required this.title, 
    this.showLogo = true,
    super.key
  });
  final String title;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    
    return CustomFadeInUp(
      duration: 500,
      child: Column(
        children: [
          // Logo with Voclio text
          if (showLogo) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: isSmall ? 60.w : 80.w,
                  height: isSmall ? 60.h : 80.h,
                  child: Image.asset(
                    'assets/images/Microphone Icon.png',
                    fit: BoxFit.contain,
                    color: context.colors.primary,
                    colorBlendMode: BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: isSmall ? 12.w : 16.w),
                TextApp(
                  text: 'Voclio',
                  textAlign: TextAlign.center,
                  theme: context.textStyle.copyWith(
                    fontSize: isSmall ? 24.sp : 32.sp,
                    fontWeight: FontWeightHelper.bold,
                    color: context.colors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmall ? 16.h : 20.h),
          ],
          // Title
          TextApp(
            text: title,
            textAlign: TextAlign.center,
            theme: context.textStyle.copyWith(
                fontSize: isSmall ? 24.sp : 30.sp,
                fontWeight: FontWeightHelper.bold,
                color: context.colors.textColor
            ),
          ),
        ],
      ),
    );
  }
}
