import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_tokens.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_widgets.dart';
import 'package:voclio_app/core/icons/app_icons.dart';

class NoNetworkScreen extends StatelessWidget {
  const NoNetworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeSystemTokens.canvas,
      body: HomeEmptyState(
        icon: AppIcons.wifi_off_rounded,
        title: 'No connection',
        message: 'Please check your internet connection and try again.',
        accent: HomeSystemTokens.coral,
      ),
    );
  }
}
