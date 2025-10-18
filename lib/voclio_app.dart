import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:voclio_app/core/app/connectivily_control.dart';
import 'package:voclio_app/core/language/app_localizations_setup.dart';
import 'package:voclio_app/core/routes/app_routes.dart';
import 'package:voclio_app/core/styles/theme/app_theme.dart';

import 'core/common/screens/no_network_screen.dart';


class VoclioApp extends StatelessWidget {
  const VoclioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ConnectivityControler.instance.isConected,
      builder: (context, isConnected, _) {
        return ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              theme:   themeLight(),
              locale: const Locale('en'),
              supportedLocales: AppLocalizationsSetup.supportedLocales,
              localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
              localeResolutionCallback:
              AppLocalizationsSetup.localeResolutionCallback,
              routerConfig: AppRouter.router,
              builder: (context, child) {
                if (!isConnected) {
                  return const NoNetworkScreen();
                }
                return child!;
              },
            );
          },
        );
      },
    );
  }
}
