import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import '../../../../core/common/animation/animate_do.dart';
import '../../../../core/common/inputs/text_app.dart';
import '../../../../core/styles/fonts/font_weight_helper.dart';

class AuthTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;

  const AuthTextField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    
    return CustomFadeInUp(
      duration: 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextApp(
            text: label,
            theme: context.textStyle.copyWith(
              fontSize: isSmall ? 14.sp : 16.sp,
              fontWeight: FontWeightHelper.medium,
              color: colors.textColor,
            ),
          ),
          SizedBox(height: isSmall ? 6.h : 8.h),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            validator: validator,
            onChanged: onChanged,
            enabled: enabled,
            style: context.textStyle.copyWith(
              fontSize: isSmall ? 14.sp : 16.sp,
              color: colors.textColor,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: context.textStyle.copyWith(
                fontSize: isSmall ? 12.sp : 14.sp,
                color: colors.textColor?.withOpacity(0.6),
              ),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: colors.background!.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isSmall ? 10.r : 12.r),
                borderSide: BorderSide(
                  color: colors.primary!.withOpacity(0.3),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isSmall ? 10.r : 12.r),
                borderSide: BorderSide(
                  color: colors.primary!.withOpacity(0.3),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isSmall ? 10.r : 12.r),
                borderSide: BorderSide(
                  color: colors.primary!,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isSmall ? 10.r : 12.r),
                borderSide: BorderSide(
                  color: Colors.red,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isSmall ? 10.r : 12.r),
                borderSide: BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isSmall ? 10.r : 12.r),
                borderSide: BorderSide(
                  color: colors.primary!.withOpacity(0.1),
                  width: 1,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: isSmall ? 14.w : 16.w,
                vertical: isSmall ? 14.h : 16.h,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
