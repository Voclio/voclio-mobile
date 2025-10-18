
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';

import '../inputs/text_app.dart';

/// Custom button widget for Voclio app
/// Provides consistent button styling and behavior across the app
/// Supports loading states and custom styling
class CustomButton extends StatelessWidget {
  const CustomButton({
    required this.onPressed,
    required this.text,
    required this.width,
    required this.height,
    super.key,
    this.lastRadius,
    this.threeRadius,
    this.backgroundColor,
    this.textColor,
    this.textAlign,
    this.isLoading = false,
    this.loadingWidth = 30,
    this.loadingHeight = 30,
  });

  /// Callback function when button is pressed
  final VoidCallback onPressed;
  
  /// Text content of the button
  final String text;
  
  /// Width of the button
  final double width;
  
  /// Height of the button
  final double height;
  
  /// Radius for top-left, top-right, and bottom-right corners
  final double? threeRadius;
  
  /// Radius for bottom-left corner
  final double? lastRadius;
  
  /// Background color of the button
  final Color? backgroundColor;
  
  /// Text color of the button
  final Color? textColor;
  
  /// Whether the button is in loading state
  final bool isLoading;
  
  /// Text alignment within the button
  final TextAlign? textAlign;
  
  /// Width of loading indicator
  final double? loadingWidth;
  
  /// Height of loading indicator
  final double? loadingHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(threeRadius ?? 20),
              topRight: Radius.circular(threeRadius ?? 20),
              bottomRight: Radius.circular(threeRadius ?? 20),
              bottomLeft: Radius.circular(lastRadius ?? 0),
            ),
          ),
        ),
        onPressed: onPressed,
        child: TextApp(
          theme: context.textStyle.copyWith(
            color: textColor ?? Colors.white,
            fontSize: 16.sp,
          ),
          text: text,
          textAlign: textAlign,
        ),
      ),
    );
  }
}
