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
    if (_prefs.getString(_languageKey) != 'en') {
      await _prefs.setString(_languageKey, 'en');
    }
    emit(const AppLanguageChanged(Locale('en')));
  }

  Future<void> changeLanguage(Locale locale) async {
    await _prefs.setString(_languageKey, 'en');
    emit(const AppLanguageChanged(Locale('en')));
  }

  Locale get currentLocale => const Locale('en');

  bool get isEnglish => true;
}
