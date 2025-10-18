
import 'package:flutter/material.dart';
import 'package:voclio_app/core/styles/theme/color_extentions.dart';
import '../language/app_localizations.dart';
import '../styles/color/app_colors.dart';
import 'package:go_router/go_router.dart';




extension AppExtensions on BuildContext {
  // colors
  MyColors get colors => Theme.of(this).extension<MyColors>()!;
// language
  String translate (String langKey){
    return AppLocalizations.of(this)!.translate(langKey)!;
  }

  // text
  TextStyle get textStyle => Theme.of(this).textTheme.displaySmall!;
  // routers
  /// - ينفع ترجع للصفحة اللي قبلها
  void pushRoute(String route) {
    push(route);
  }

  /// ✅ يبدل الصفحة الحالية باللي بعدها (زي pushReplacement في Navigator)
  /// - ماينفعش ترجع لللي قبلها
  void goRoute(String route) {
    go(route);
  }

  /// ✅ يرجع صفحة واحدة للخلف (زي Navigator.pop)
  void popRoute() {
    pop();
  }

  /// ✅ يروح لصفحة جديدة ويمسح كل اللي قبلها (زي pushAndRemoveUntil)
  /// - مثالي لو عايز تبدأ من صفحة معينة وتمنع الرجوع
  void pushAndRemoveUntilRoute(String route) {
    go(route); // go في GoRouter بيمسح اللي قبله أوتوماتيك
  }
}
