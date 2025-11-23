
import 'package:flutter/material.dart';
import 'package:voclio_app/core/extentions/color_extentions.dart';
import '../language/app_localizations.dart';
import 'package:go_router/go_router.dart';

/// BuildContext extensions for Voclio app
/// Provides convenient access to colors, translations, text styles, and navigation
/// Makes the code cleaner and more readable throughout the app
extension AppExtensions on BuildContext {
  /// Get custom colors from theme
  /// Returns MyColors instance with all app-specific colors
  MyColors get colors => Theme.of(this).extension<MyColors>()!;

  /// Translate a language key to current locale text
  /// [langKey] - the key from language JSON files
  /// Returns the translated string for current language
  String translate(String langKey) {
    return AppLocalizations.of(this)!.translate(langKey)!;
  }

  /// Get default text style from theme
  /// Returns the displaySmall text style from current theme
  TextStyle get textStyle => Theme.of(this).textTheme.displaySmall!;

  // Navigation methods using GoRouter
  
  /// Navigate to a new route (push)
  /// [route] - the route path to navigate to
  /// Allows going back to previous screen
  void pushRoute(String route) {
    push(route);
  }

  /// Navigate to a new route (replace current)
  /// [route] - the route path to navigate to
  /// Cannot go back to previous screen
  void goRoute(String route) {
    go(route);
  }

  /// Go back to previous screen
  /// Equivalent to Navigator.pop()
  void popRoute() {
    pop();
  }

  /// Navigate to new route and clear navigation stack
  /// [route] - the route path to navigate to
  /// Perfect for starting from a specific screen and preventing back navigation
  void pushAndRemoveUntilRoute(String route) {
    go(route); // GoRouter automatically clears previous routes
  }
}
