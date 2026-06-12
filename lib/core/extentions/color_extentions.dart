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
    primary: Color(0xFF7C5CFC),
    accent: Color(0xFF34C759),
    accentLight: Color(0xFF81C784),
    accentDark: Color(0xFF388E3C),
    white: Color(0xFFFFFFFF),
    black: Color(0xFF000000),
    grey: Color(0xFF424242),
    greyLight: Color(0xFFF5F6FA),
    greyDark: Color(0xFF1A1A1A),
    textPrimary: Color(0xFF111827),
    textSecondary: Color(0xFF9CA3AF),
    textLight: Color(0xFFFFFFFF),
    background: Color(0xFFF5F6FA),
    backgroundLight: Color(0xFFF5F6FA),
    backgroundDark: Color(0xFF303030),
    success: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFEF4444),
    info: Color(0xFF3B82F6),
  );
}
