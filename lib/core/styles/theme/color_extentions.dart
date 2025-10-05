import 'package:flutter/material.dart';

class MyColors extends ThemeExtension<MyColors> {
  const MyColors({
    required this.textColor,
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
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
  final Color? textColor;
  final Color? primary;
  final Color? primaryLight;
  final Color? primaryDark;
  final Color? accent;
  final Color? accentLight;
  final Color? accentDark;
  final Color? white;
  final Color? black;
  final Color? grey;
  final Color? greyLight;
  final Color? greyDark;
  final Color? textPrimary;
  final Color? textSecondary;
  final Color? textLight;
  final Color? background;
  final Color? backgroundLight;
  final Color? backgroundDark;
  final Color? success;
  final Color? warning;
  final Color? error;
  final Color? info;

  @override
  ThemeExtension<MyColors> copyWith({
    Color? textColor,
    Color? primary,
    Color? primaryLight,
    Color? primaryDark,
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
      textColor: textColor ?? this.textColor ,
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryDark: primaryDark ?? this.primaryDark,
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

  @override
  ThemeExtension<MyColors> lerp(
      covariant ThemeExtension<MyColors>? other,
      double t,
      ) {
    if (other is! MyColors) return this;

    return MyColors(

      primary: Color.lerp(primary, other.primary, t),
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t),
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t),
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
      textColor: Color.lerp(textColor, other.textColor, t),
    );
  }

  //  Light Theme
  static const MyColors light = MyColors(
    primary: Color(0xFFF98006),
    primaryLight: Color(0xFFFFB347),
    primaryDark: Color(0xFFE5720A),
    textColor : Color(0xFFF98006),
    accent: Color(0xFFFFB347),
    accentLight: Color(0xFFFFD180),
    accentDark: Color(0xFFFF9800),
    white: Color(0xFFFFFFFF),
    black: Color(0xFF000000),
    grey: Color(0xFF9E9E9E),
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

  //  Dark Theme
  static const MyColors dark = MyColors(
    primary: Color(0xFF4B4CED), // blueDark → لون أساسي
    primaryLight: Color(0xFF37B6E9), // blueLight → النسخة الفاتحة من الأساسي
    primaryDark: Color(0xFF242C3B), // mainColor → الغامق الأساسي
    textColor : Color(0xFFE0E0E0),
    accent: Color(0xFF37B6E9), // نفس blueLight كمساعد للألوان الثانوية
    accentLight: Color(0xFF4B4CED),
    accentDark: Color(0xFF2B3361), // navBarDark → accent غامق

    white: Color(0xFFFFFFFF),
    black: Color(0xFF000000),

    grey: Color(0xFF353F54), // black1 → رمادي متوسط
    greyLight: Color(0xFF4B4CED), // blueDark كظل فاتح
    greyDark: Color(0xFF222834), // black2 → رمادي غامق

    textPrimary: Color(0xFFFFFFFF), // أبيض واضح للنصوص
    textSecondary: Color(0xFFB0B0B0), // رمادي للنصوص الثانوية
    textLight: Color(0xFFE0E0E0),

    background: Color(0xFF222834), // الخلفية الداكنة الأساسية
    backgroundLight: Color(0xFF2B3361), // لمسة من لون الـ navBar
    backgroundDark: Color(0xFF121212),

    success: Color(0xFF37B6E9), // نفس الـ blueLight كرمز نجاح
    warning: Color(0xFFE5720A), // لون تحذيري متناسق
    error: Color(0xFFE57373), // لون الخطأ المعتاد
    info: Color(0xFF4B4CED), // الأزرق الغامق للمعلومات
  );


}
