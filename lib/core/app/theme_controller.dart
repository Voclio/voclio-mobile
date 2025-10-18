import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme controller for managing dark/light mode in Voclio app
/// Uses singleton pattern to ensure single instance across the app
/// Persists theme preference using SharedPreferences for user experience
class ThemeController {
  ThemeController._();

  /// Singleton instance of ThemeController
  static final ThemeController instance = ThemeController._();

  /// Notifier for theme changes - true for dark mode, false for light mode
  ValueNotifier<bool> isDarkMode = ValueNotifier(false);

  /// Key for storing theme preference in SharedPreferences
  static const String _themeKey = 'is_dark_mode';

  /// Initialize theme controller and load saved preference
  /// Should be called during app startup
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool(_themeKey) ?? false;
  }

  /// Toggle between dark and light mode
  /// Saves the new preference to SharedPreferences
  Future<void> toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode.value);
  }

  /// Set specific theme mode
  /// Saves the preference to SharedPreferences
  /// [isDark] - true for dark mode, false for light mode
  Future<void> setTheme(bool isDark) async {
    isDarkMode.value = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode.value);
  }
}
