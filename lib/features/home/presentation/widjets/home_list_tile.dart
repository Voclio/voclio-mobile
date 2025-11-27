import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/language/lang_keys.dart';

import '../../../../core/common/inputs/text_app.dart';
import '../../../../core/styles/fonts/font_weight_helper.dart';
class HomeListTile extends StatelessWidget {
  const HomeListTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(26.r),
        child: Image.asset('assets/images/onboarding.png')
      ),
      title: Text(
        context.translate(LangKeys.welcoming),
        style: context.textStyle.copyWith(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: context.colors.grey,
        ),
      ),
      subtitle: Text(
        'Youssef',
        style: context.textStyle.copyWith(
          fontSize: 22.sp,
          fontWeight: FontWeight.bold,
          color: context.colors.grey,        ),
      ),
      trailing: IntrinsicWidth(
        child: Row(
          children: [
            SizedBox(
              width: 45.w,
              height: 45.h,
              child: Image.asset(
                'assets/images/Microphone Icon.png',
                fit: BoxFit.contain,
                color: context.colors.primary,
                colorBlendMode: BlendMode.srcIn,
              ),
            ),
            TextApp(
              text: 'Voclio',
              textAlign: TextAlign.center,
              theme: context.textStyle.copyWith(
                fontSize: 27.sp,
                fontWeight: FontWeightHelper.bold,
                color: context.colors.primary,
              ),
            ),
          ],
        ),
      ),

    );
  }
}
