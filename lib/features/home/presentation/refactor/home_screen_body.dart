import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import '../../../../core/app/linaer_container.dart';
import '../widjets/home_dashboard.dart';
import '../widjets/home_list_tile.dart';
import '../widjets/home_task_list.dart';
import '../widjets/menu_list_view.dart';

class HomeScreenBody extends StatefulWidget {
  const HomeScreenBody({super.key});

  @override
  State<HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<HomeScreenBody> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: LinearContainer(
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              //  الجزء الثابت الأعلى
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Home Info
                    HomeListTile(),
                    SizedBox(height: 15.h),

                    // Dashboard
                    HomeDashboard(),
                    SizedBox(height: 15.h),

                    // Menu List
                    MenuListView(),
                    SizedBox(height: 15.h),

                    // Section Title
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      child: Text(
                        'Recent Items',
                        style: context.textStyle.copyWith(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: context.colors.textColor,
                          fontFamily: 'poppins',
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),

              //  قائمة الـ Tasks قابلة للسكرول
              SliverList.separated(
                itemCount: 10,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) => const HomeTasksList(),
              ),

              //  Padding في النهاية عشان ما تتغطاش  BottomBar
              SliverToBoxAdapter(
                child: SizedBox(height: 100.h),
              ),
            ],
          ),
        ),
      ),

      // ✅ Bottom Navigation Bar
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15.r),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: context.colors.primary,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.house),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.tasks),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.calendarCheck),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.user),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
