import 'package:flutter/material.dart';

/// App-wide color constants for Voclio voice-to-text productivity app
/// This class provides a centralized color palette for consistent theming
/// Colors are chosen to be professional, comfortable for long use, and suitable for productivity apps
class AppColors {
  // Primary brand colors - Professional blue theme for productivity
  static const Color primary = Color(0xFF2196F3); // Professional blue for productivity apps
  static const Color primaryLight = Color(0xFF64B5F6); // Light blue, easy on the eyes
  static const Color primaryDark = Color(0xFF1976D2); // Dark blue, professional
  
  // Secondary colors - Green accent for success and productivity
  static const Color accent = Color(0xFF4CAF50); // Green for success and productivity
  static const Color accentLight = Color(0xFF81C784); // Light green, comfortable
  static const Color accentDark = Color(0xFF388E3C); // Dark green, professional
  
  // Neutral colors - Basic color palette
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFF5F5F5);
  static const Color greyDark = Color(0xFF424242);
  
  // Text colors - For different text contexts
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);
  
  // Background colors - For different background contexts
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF303030);
  
  // Status colors - For different states and feedback
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Gradient definitions - Professional gradients for UI elements
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
      Color(0xFF64B5F6), // Light blue, comfortable
      Color(0xFF2196F3), // Professional blue, primary
      Color(0xFFFFFFFF), // White
    ],
    stops: [0.0, 0.3, 1.0],
  );
}
