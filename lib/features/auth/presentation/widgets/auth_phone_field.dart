import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import '../../../../core/common/animation/animate_do.dart';

class AuthPhoneField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final String? Function(PhoneNumber?)? validator;
  final void Function(PhoneNumber)? onChanged;
  final bool enabled;
  final String initialCountryCode;

  const AuthPhoneField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.initialCountryCode = 'EG', // Default to Egypt
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final primaryColor = colors.primary ?? Theme.of(context).primaryColor;
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return CustomFadeInUp(
      duration: 600,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: IntlPhoneField(
          controller: controller,
          enabled: enabled,
          initialCountryCode: initialCountryCode,
          disableLengthCheck: false,
          showDropdownIcon: true,
          dropdownIconPosition: IconPosition.trailing,
          flagsButtonPadding: EdgeInsets.only(left: 16.w),
          dropdownIcon: Icon(
            Icons.arrow_drop_down,
            color: primaryColor,
          ),
          style: TextStyle(
            fontSize: isSmall ? 14.sp : 16.sp,
            color: const Color(0xFF1A1A2E),
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            labelStyle: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade400,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 18.h,
            ),
          ),
          onChanged: onChanged,
          validator: validator,
        ),
      ),
    );
  }
}
