import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Language controller for managing app language in Voclio app
/// Uses singleton pattern to ensure single instance across the app
/// English-only app language with persistence.
class LanguageController {
  LanguageController._();

  /// Singleton instance of LanguageController
  static final LanguageController instance = LanguageController._();

  /// Notifier for language changes - current locale
  ValueNotifier<Locale> currentLocale = ValueNotifier(const Locale('en'));

  /// Key for storing language preference in SharedPreferences
  static const String _languageKey = 'selected_language';

  /// Initialize language controller and load saved preference
  /// Should be called during app startup
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
  if (prefs.getString(_languageKey) != 'en') {
      await prefs.setString(_languageKey, 'en');
    }
    currentLocale.value = const Locale('en');
  }

  /// Change app language to specific locale
  /// Saves the preference to SharedPreferences
  Future<void> changeLanguage(Locale locale) async {
    currentLocale.value = const Locale('en');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, 'en');
  }

  bool get isEnglish => true;
}
