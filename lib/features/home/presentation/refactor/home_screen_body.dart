import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import '../../../../core/app/linaer_container.dart';
import '../widjets/home_dashboard.dart';
import '../widjets/home_list_tile.dart';

class HomeScreenBody extends StatelessWidget {
  const HomeScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LinearContainer(
        child: SafeArea(
          child: Column(
            children: [
              // Home header Info
              HomeListTile(),
              SizedBox(height: 15.h),
              // Home Dashboard
              HomeDashboard(),
            ],
          ),
        ),
      ),
    );
  }
}
