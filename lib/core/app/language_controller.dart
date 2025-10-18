import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Language controller for managing app language in Voclio app
/// Uses singleton pattern to ensure single instance across the app
/// Supports Arabic and English languages with persistence
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
    final languageCode = prefs.getString(_languageKey) ?? 'en';
    currentLocale.value = Locale(languageCode);
  }

  /// Change app language to specific locale
  /// Saves the preference to SharedPreferences
  /// [locale] - the target locale (en or ar)
  Future<void> changeLanguage(Locale locale) async {
    currentLocale.value = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
  }

  /// Toggle between Arabic and English languages
  /// Saves the new preference to SharedPreferences
  Future<void> toggleLanguage() async {
    final newLocale = currentLocale.value.languageCode == 'en' 
        ? const Locale('ar') 
        : const Locale('en');
    await changeLanguage(newLocale);
  }

  /// Check if current language is Arabic
  bool get isArabic => currentLocale.value.languageCode == 'ar';
  
  /// Check if current language is English
  bool get isEnglish => currentLocale.value.languageCode == 'en';
}
