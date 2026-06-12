import 'package:flutter/material.dart';
import 'package:voclio_app/core/extentions/color_extentions.dart';

/// Light theme configuration for Voclio app
/// Uses professional blue and green colors suitable for productivity applications
/// Provides a clean, modern look that's easy on the eyes for long usage
ThemeData themeLight() {
  return ThemeData(
    // Custom color extensions for consistent theming
    extensions: <ThemeExtension<dynamic>>[MyColors.light],

    // Scaffold background color
    scaffoldBackgroundColor: MyColors.light.background,

    // Color scheme generated from primary color
    colorScheme: ColorScheme.fromSeed(
      seedColor: MyColors.light.primary!,
      brightness: Brightness.light,
    ),

    // Default text theme for the app
    textTheme: const TextTheme(
      displaySmall: TextStyle(fontSize: 16, color: Colors.black),
    ),
  );
}
