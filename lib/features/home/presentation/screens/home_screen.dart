import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import 'package:voclio_app/core/routes/App_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // TODO: Implement logout
              context.goRoute(AppRouter.login);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home,
              size: 100.w,
              color: context.colors.primary,
            ),
            SizedBox(height: 20.h),
            Text(
              'Welcome to Voclio!',
              style: context.textStyle.copyWith(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: context.colors.textColor,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'You are successfully logged in.',
              style: context.textStyle.copyWith(
                fontSize: 16.sp,
                color: context.colors.textColor?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
