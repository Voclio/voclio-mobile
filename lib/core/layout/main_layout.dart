import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../features/home/presentation/refactor/home_screen_body.dart';
import '../../features/tasks/presentation/screens/tasks_screen.dart';
import '../../features/calendar/presentation/screens/calendar_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/voice/presentation/screens/voice_recording_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabAnimationController;

  final List<Widget> _screens = const [
    HomeScreenBody(),
    TasksScreen(),
    CalendarScreen(),
    ProfileScreen(),
  ];

  final iconList = <IconData>[
    Icons.home_rounded,
    Icons.task_alt_rounded,
    Icons.calendar_month_rounded,
    Icons.person_rounded,
  ];

  final iconLabels = <String>['Home', 'Tasks', 'Calendar', 'Profile'];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    // إظهار المايك مباشرة عند فتح الشاشة
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: _screens[_currentIndex],
      floatingActionButton: Container(
        width: 65.r,
        height: 65.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.2),
              blurRadius: 35,
              spreadRadius: 5,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VoiceRecordingScreen(),
                ),
              );
            },
            customBorder: const CircleBorder(),
            splashColor: Colors.white.withOpacity(0.3),
            child: Center(
              child: Icon(Icons.mic_rounded, size: 32.sp, color: Colors.white),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28.r),
            topRight: Radius.circular(28.r),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, -8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: AnimatedBottomNavigationBar.builder(
          itemCount: iconList.length,
          tabBuilder: (int index, bool isActive) {
            final color = isActive ? theme.primaryColor : Colors.grey.shade600;
            // Add horizontal padding to push tasks left and calendar right
            final horizontalPadding =
                index == 1
                    ? EdgeInsets.only(right: 20.w) // Tasks - push left
                    : index == 2
                    ? EdgeInsets.only(left: 20.w) // Calendar - push right
                    : EdgeInsets.zero;

            return Padding(
              padding: horizontalPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: isActive ? theme.primaryColor : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      iconList[index],
                      size: 22.sp,
                      color: isActive ? Colors.white : color,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    iconLabels[index],
                    style: TextStyle(
                      color: color,
                      fontSize: 11.sp,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          },
          backgroundColor: Colors.white,
          activeIndex: _currentIndex,
          splashColor: Colors.transparent,
          splashSpeedInMilliseconds: 0,
          notchSmoothness: NotchSmoothness.verySmoothEdge,
          gapLocation: GapLocation.center,
          leftCornerRadius: 28.r,
          rightCornerRadius: 28.r,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          shadow: const BoxShadow(color: Colors.transparent, blurRadius: 0),
          height: 65.h,
          elevation: 0,
        ),
      ),
    );
  }
}
