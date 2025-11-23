import 'package:flutter/material.dart';

/// Custom color theme extension for Voclio app
/// This class extends ThemeData to provide custom colors for both light and dark themes
/// Used throughout the app for consistent color management
class MyColors extends ThemeExtension<MyColors> {
  const MyColors({

    required this.primary,

    required this.accent,
    required this.accentLight,
    required this.accentDark,
    required this.white,
    required this.black,
    required this.grey,
    required this.greyLight,
    required this.greyDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.textLight,
    required this.background,
    required this.backgroundLight,
    required this.backgroundDark,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });

  // Core brand colors

  final Color? primary;

  
  // Accent colors for secondary elements
  final Color? accent;
  final Color? accentLight;
  final Color? accentDark;
  
  // Basic colors
  final Color? white;
  final Color? black;
  final Color? grey;
  final Color? greyLight;
  final Color? greyDark;
  
  // Text colors for different contexts
  final Color? textPrimary;
  final Color? textSecondary;
  final Color? textLight;
  
  // Background colors
  final Color? background;
  final Color? backgroundLight;
  final Color? backgroundDark;
  
  // Status colors for different states
  final Color? success;
  final Color? warning;
  final Color? error;
  final Color? info;

  /// Creates a copy of this color theme with some properties overridden
  @override
  ThemeExtension<MyColors> copyWith({

    Color? primary,

    Color? accent,
    Color? accentLight,
    Color? accentDark,
    Color? white,
    Color? black,
    Color? grey,
    Color? greyLight,
    Color? greyDark,
    Color? textPrimary,
    Color? textSecondary,
    Color? textLight,
    Color? background,
    Color? backgroundLight,
    Color? backgroundDark,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
  }) {
    return MyColors(
      primary: primary ?? this.primary,
      accent: accent ?? this.accent,
      accentLight: accentLight ?? this.accentLight,
      accentDark: accentDark ?? this.accentDark,
      white: white ?? this.white,
      black: black ?? this.black,
      grey: grey ?? this.grey,
      greyLight: greyLight ?? this.greyLight,
      greyDark: greyDark ?? this.greyDark,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textLight: textLight ?? this.textLight,
      background: background ?? this.background,
      backgroundLight: backgroundLight ?? this.backgroundLight,
      backgroundDark: backgroundDark ?? this.backgroundDark,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
    );
  }

  /// Interpolates between two color themes for smooth transitions
  @override
  ThemeExtension<MyColors> lerp(
      covariant ThemeExtension<MyColors>? other,
      double t,
      ) {
    if (other is! MyColors) return this;

    return MyColors(
      primary: Color.lerp(primary, other.primary, t),

      accent: Color.lerp(accent, other.accent, t),
      accentLight: Color.lerp(accentLight, other.accentLight, t),
      accentDark: Color.lerp(accentDark, other.accentDark, t),
      white: Color.lerp(white, other.white, t),
      black: Color.lerp(black, other.black, t),
      grey: Color.lerp(grey, other.grey, t),
      greyLight: Color.lerp(greyLight, other.greyLight, t),
      greyDark: Color.lerp(greyDark, other.greyDark, t),
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t),
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t),
      textLight: Color.lerp(textLight, other.textLight, t),
      background: Color.lerp(background, other.background, t),
      backgroundLight: Color.lerp(backgroundLight, other.backgroundLight, t),
      backgroundDark: Color.lerp(backgroundDark, other.backgroundDark, t),
      success: Color.lerp(success, other.success, t),
      warning: Color.lerp(warning, other.warning, t),
      error: Color.lerp(error, other.error, t),
      info: Color.lerp(info, other.info, t),

    );
  }

  /// Light theme configuration - Professional blue and green colors
  /// Suitable for productivity and voice-to-text applications
  static const MyColors light = MyColors(
    primary: Color(0xFF9B87C8), // Professional blue for productivity apps
    accent: Color(0xFF4CAF50), // Green for success and productivity
    accentLight: Color(0xFF81C784), // Light green, comfortable
    accentDark: Color(0xFF388E3C), // Dark green, professional
    white: Color(0xFFFFFFFF),
    black: Color(0xFF000000),
    grey: Color(0xFF6B6B7E),
    greyLight: Color(0xFFF5F5F5),
    greyDark: Color(0xFF424242),
    textPrimary: Color(0xFF212121),
    textSecondary: Color(0xFF757575),
    textLight: Color(0xFFFFFFFF),
    background: Color(0xFFFFFFFF),
    backgroundLight: Color(0xFFFAFAFA),
    backgroundDark: Color(0xFF303030),
    success: Color(0xFF4CAF50),
    warning: Color(0xFFFF9800),
    error: Color(0xFFF44336),
    info: Color(0xFF2196F3),
  );

  /// Dark theme configuration - Same professional colors with dark backgrounds
  /// Maintains consistency with light theme while providing dark mode support
  // static const MyColors dark = MyColors(
  //   primary: Color(0xFF2196F3), // Same professional blue
  //   primaryLight: Color(0xFF64B5F6), // Same light blue
  //   primaryDark: Color(0xFF1976D2), // Same dark blue
  //   textColor: Color(0xFF64B5F6), // Light blue text for visibility in dark mode
  //   accent: Color(0xFF4CAF50), // Same green for success and productivity
  //   accentLight: Color(0xFF81C784), // Same light green
  //   accentDark: Color(0xFF388E3C), // Same dark green
  //   white: Color(0xFFFFFFFF),
  //   black: Color(0xFF000000),
  //   grey: Color(0xFF424242), // Medium grey for dark mode
  //   greyLight: Color(0xFF616161), // Light grey for dark mode
  //   greyDark: Color(0xFF212121), // Dark grey for dark mode
  //   textPrimary: Color(0xFFFFFFFF), // White for primary text
  //   textSecondary: Color(0xFFB0B0B0), // Grey for secondary text
  //   textLight: Color(0xFFFFFFFF), // White for light text
  //   background: Color(0xFF121212), // Dark background
  //   backgroundLight: Color(0xFF1E1E1E), // Slightly lighter dark background
  //   backgroundDark: Color(0xFF000000), // Very dark background
  //   success: Color(0xFF4CAF50), // Green for success
  //   warning: Color(0xFFFF9800), // Orange for warnings
  //   error: Color(0xFFF44336), // Red for errors
  //   info: Color(0xFF2196F3), // Blue for information
  // );
}
