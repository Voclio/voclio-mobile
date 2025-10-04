import 'package:flutter/material.dart';

/// App-wide color constants for Voclio
class AppColors {
  // Primary brand colors
  static const Color primary = Color(0xFFF98006);
  static const Color primaryLight = Color(0xFFFFB347);
  static const Color primaryDark = Color(0xFFE5720A);
  
  // Secondary colors
  static const Color accent = Color(0xFFFFB347);
  static const Color accentLight = Color(0xFFFFD180);
  static const Color accentDark = Color(0xFFFF9800);
  
  // Neutral colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFF5F5F5);
  static const Color greyDark = Color(0xFF424242);
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);
  
  // Background colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF303030);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFB347),
      Color(0xFFF98006),
      Color(0xFFFFFFFF),
    ],
    stops: [0.0, 0.3, 1.0],
  );
}
