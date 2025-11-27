import 'package:flutter/material.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';

/// Custom linear gradient button widget for Voclio app
/// Provides consistent gradient button styling across the app
/// Uses app colors for gradient effects
class CustomLinearButton extends StatelessWidget {
  const CustomLinearButton({
    required this.onPressed,
    required this.child,
    this.height,
    this.width,
    super.key,
  });

  /// Callback function when button is pressed
  final VoidCallback onPressed;
  
  /// Child widget to display inside the button
  final Widget child;
  
  /// Height of the button
  final double? height;
  
  /// Width of the button
  final double? width;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: context.colors.primary,
      onTap: onPressed,
      child: Container(
        height: height ?? 44,
        width: width ?? 44,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          gradient: LinearGradient(
            colors: [
              context.colors.primary!,
              context.colors.accentDark!,
            ],
            begin: const Alignment(0.46, -0.89),
            end: const Alignment(-0.46, 0.89),
          ),
        ),
        child: Center(child: child),
      ),
    );
  }
}
