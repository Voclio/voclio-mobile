import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:voclio_app/core/app/connectivily_control.dart';
import 'package:voclio_app/core/app/theme_controller.dart';
import 'package:voclio_app/core/app/app_cubit.dart';
import 'package:voclio_app/core/language/app_localizations_setup.dart';
import 'package:voclio_app/core/routes/App_routes.dart';
import 'package:voclio_app/core/styles/theme/app_theme.dart';
import 'package:voclio_app/core/di/injection_container.dart';
import 'package:voclio_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:voclio_app/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:voclio_app/features/calendar/presentation/bloc/calendar_cubit.dart';
import 'package:voclio_app/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:voclio_app/features/productivity/presentation/bloc/ai_suggestions_cubit.dart';

import 'package:voclio_app/core/common/screens/no_network_screen.dart';

class VoclioApp extends StatelessWidget {
  const VoclioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppCubit>(
      create: (context) => getIt<AppCubit>(),
      child: ValueListenableBuilder<bool>(
        valueListenable: ConnectivityControler.instance.isConected,
        builder: (context, isConnected, _) {
          return ValueListenableBuilder<bool>(
            valueListenable: ThemeController.instance.isDarkMode,
            builder: (context, isDarkMode, _) {
              return BlocBuilder<AppCubit, AppState>(
                buildWhen:
                    (previous, current) => previous.locale != current.locale,
                builder: (context, appState) {
                  return ScreenUtilInit(
                    designSize: const Size(375, 812),
                    minTextAdapt: true,
                    splitScreenMode: true,
                    builder: (context, child) {
                      return MultiBlocProvider(
                        providers: [
                          BlocProvider<AuthBloc>(
                            create: (context) => getIt<AuthBloc>(),
                          ),
                          BlocProvider<NotificationsCubit>(
                            create:
                                (context) =>
                                    getIt<NotificationsCubit>()
                                      ..loadNotifications(),
                          ),
                          BlocProvider<CalendarCubit>(
                            create:
                                (context) =>
                                    getIt<CalendarCubit>()..loadMonth(
                                      DateTime.now().year,
                                      DateTime.now().month,
                                    ),
                          ),
                          BlocProvider<DashboardCubit>(
                            create: (context) => getIt<DashboardCubit>(),
                          ),
                          BlocProvider<AiSuggestionsCubit>(
                            create:
                                (context) =>
                                    getIt<AiSuggestionsCubit>()
                                      ..loadAiSuggestions(),
                          ),
                        ],
                        child: MaterialApp.router(
                          debugShowCheckedModeBanner: false,
                          theme: themeLight(),
                          locale: appState.locale,
                          supportedLocales:
                              AppLocalizationsSetup.supportedLocales,
                          localizationsDelegates:
                              AppLocalizationsSetup.localizationsDelegates,
                          localeResolutionCallback:
                              AppLocalizationsSetup.localeResolutionCallback,
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
      ),
    );
  }
}
