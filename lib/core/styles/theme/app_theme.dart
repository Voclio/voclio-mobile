import 'package:flutter/material.dart';
import 'package:voclio_app/core/styles/theme/color_extentions.dart';

import '../color/app_colors.dart';

ThemeData themeLight() {
  return ThemeData(
    extensions:  <ThemeExtension<dynamic>>[
      MyColors.light,
    ],

    scaffoldBackgroundColor: MyColors.light.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: MyColors.light.primary!,
      brightness: Brightness.light,
    ),
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        fontSize: 16,
        color: Colors.black,
      ),
    ),
  );
}

ThemeData themeDark() {
  return ThemeData(
    extensions: <ThemeExtension<dynamic>>[
      MyColors.dark,
    ],
    scaffoldBackgroundColor: MyColors.dark.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: MyColors.dark.primary!,
      brightness: Brightness.dark,
    ),
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        fontSize: 14,
        color: Colors.white,
      ),
    ),
  );
}
