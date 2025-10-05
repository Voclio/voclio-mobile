import 'package:flutter/material.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';

import '../../../../core/common/animation/animate_do.dart';
import '../../../../core/common/buttons/custom_linear_button.dart';
import '../../../../core/common/inputs/text_app.dart';

import '../../../../core/language/lang_keys.dart';
import '../../../../core/styles/fonts/font_weight_helper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class DarkAndLangBar extends StatelessWidget {
  const DarkAndLangBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // dark mode buttom
        CustomFadeInRight(
          duration: 600,
          child: CustomLinearButton(
            width: 50.w,
            onPressed: () {},
            child: Icon(
              Icons.dark_mode_rounded,
              color: Colors.white,
            ),
          ),
        ),

        // language buttom
        CustomFadeInLeft(
          duration: 600,
          child: CustomLinearButton(
            width: 100.w,
            onPressed: () {},
            child: TextApp(
              text: context.translate(LangKeys.language),
              theme: context.textStyle.copyWith(
                fontSize: 16.sp,
                color: Colors.white,
                fontWeight: FontWeightHelper.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
