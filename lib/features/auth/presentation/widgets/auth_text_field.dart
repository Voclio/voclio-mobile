import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import '../../../../core/common/animation/animate_do.dart';

class AuthTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final IconData? prefixIcon;
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
    this.prefixIcon,
    this.validator,
    this.onChanged,
    this.enabled = true,
  });

  IconData _getDefaultIcon() {
    if (keyboardType == TextInputType.emailAddress) {
      return Icons.email_outlined;
    } else if (keyboardType == TextInputType.phone) {
      return Icons.phone_outlined;
    } else if (obscureText) {
      return Icons.lock_outline_rounded;
    } else if (label.toLowerCase().contains('name')) {
      return Icons.person_outline_rounded;
    }
    return Icons.text_fields_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final primaryColor = colors.primary ?? Theme.of(context).primaryColor;
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    final icon = prefixIcon ?? _getDefaultIcon();

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
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          onChanged: onChanged,
          enabled: enabled,
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
            hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey.shade400),
            prefixIcon: Container(
              margin: EdgeInsets.all(12.r),
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: primaryColor, size: 20.sp),
            ),
            suffixIcon: suffixIcon,
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
        ),
      ),
    );
  }
}
