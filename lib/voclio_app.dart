import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:voclio_app/core/app/connectivily_control.dart';
import 'package:voclio_app/core/app/theme_controller.dart';
import 'package:voclio_app/core/app/language_controller.dart';
import 'package:voclio_app/core/language/app_localizations_setup.dart';
import 'package:voclio_app/core/routes/app_routes.dart';
import 'package:voclio_app/core/styles/theme/app_theme.dart';
import 'package:voclio_app/core/di/injection_container.dart';
import 'package:voclio_app/features/auth/presentation/bloc/auth_bloc.dart';

import 'core/common/screens/no_network_screen.dart';


class VoclioApp extends StatelessWidget {
  const VoclioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ConnectivityControler.instance.isConected,
      builder: (context, isConnected, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: ThemeController.instance.isDarkMode,
          builder: (context, isDarkMode, _) {
            return ValueListenableBuilder<Locale>(
              valueListenable: LanguageController.instance.currentLocale,
              builder: (context, locale, _) {
                return ScreenUtilInit(
                  designSize: const Size(375, 812),
                  minTextAdapt: true,
                  splitScreenMode: true,
                  builder: (context, child) {
                    return BlocProvider<AuthBloc>(
                      create: (context) => getIt<AuthBloc>(),
                      child: MaterialApp.router(
                        debugShowCheckedModeBanner: false,
                        theme: isDarkMode ?themeDark(): themeLight(),
                        darkTheme: themeDark(),
                        locale: locale,
                        supportedLocales: AppLocalizationsSetup.supportedLocales,
                        localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
                        localeResolutionCallback: AppLocalizationsSetup.localeResolutionCallback,
                        routerConfig: AppRouter.router,
                        builder: (context, child) {
                          if (!isConnected) {
                            return const NoNetworkScreen();
                          }
                          return child!;
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
