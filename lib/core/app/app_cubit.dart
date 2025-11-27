import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  final SharedPreferences _prefs;
  
  static const String _languageKey = 'selected_language';

  AppCubit({required SharedPreferences prefs})
      : _prefs = prefs,
        super(AppInitial(const Locale('en'))) {
    _loadLanguage();
  }

  /// Load saved language preference
  Future<void> _loadLanguage() async {
    final languageCode = _prefs.getString(_languageKey) ?? 'en';
    emit(AppLanguageChanged(Locale(languageCode)));
  }

  /// Change app language to specific locale
  /// Emits state to trigger screen rebuild
  Future<void> changeLanguage(Locale locale) async {
    await _prefs.setString(_languageKey, locale.languageCode);
    emit(AppLanguageChanged(locale));
  }

  /// Toggle between Arabic and English languages
  Future<void> toggleLanguage() async {
    final newLocale = state.locale.languageCode == 'en' 
        ? const Locale('ar') 
        : const Locale('en');
    await changeLanguage(newLocale);
  }

  /// Get current locale
  Locale get currentLocale => state.locale;

  /// Check if current language is Arabic
  bool get isArabic => state.locale.languageCode == 'ar';
  
  /// Check if current language is English
  bool get isEnglish => state.locale.languageCode == 'en';
}

