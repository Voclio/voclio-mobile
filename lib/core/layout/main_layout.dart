import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import '../../features/home/presentation/refactor/home_screen_body.dart';
import '../../features/tasks/presentation/screens/tasks_screen.dart';
import '../../features/calendar/presentation/screens/monthly_calendar_screen.dart';
import '../../features/notes/presentation/screens/notes_screen.dart';
import '../../features/voice/presentation/screens/voice_recording_screen.dart';
import 'package:voclio_app/core/icons/app_icons.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  static final GlobalKey<State<MainLayout>> mainLayoutKey =
      GlobalKey<State<MainLayout>>();

  /// Switch main bottom-nav tab from anywhere (e.g. after voice actions).
  static void goToTab(int index) {
    final state = mainLayoutKey.currentState;
    if (state is _MainLayoutState) {
      state.changeTab(index);
    }
  }

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabAnimationController;
  late PageController _pageController;

  final Set<int> _mountedTabs = {0};

  final iconLabels = <String>['Home', 'Tasks', 'Calendar', 'Notes'];

  Widget _screenFor(int index) {
    switch (index) {
      case 0:
        return HomeScreenBody(onTabChange: changeTab);
      case 1:
        return const TasksScreen();
      case 2:
        return const MonthlyCalendarScreen();
      case 3:
        return const NotesScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    // إظهار المايك مباشرة عند فتح الشاشة
    _fabAnimationController.forward();
  }

  void changeTab(int index) {
    setState(() {
      _mountedTabs.add(index);
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: MainLayout.mainLayoutKey,
      backgroundColor: const Color(0xFFF5F6FA),
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _mountedTabs.add(index);
            _currentIndex = index;
          });
        },
        children: List.generate(
          iconLabels.length,
          (index) =>
              _mountedTabs.contains(index)
                  ? _screenFor(index)
                  : const SizedBox.shrink(),
        ),
      ),
      floatingActionButton: Container(
        width: 65.r,
        height: 65.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              theme.primaryColor,
              theme.primaryColor.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: theme.primaryColor.withValues(alpha: 0.2),
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
            splashColor: Colors.white.withValues(alpha: 0.3),
            child: Center(
              child: Icon(AppIcons.mic_filled, size: 32.sp, color: Colors.white),
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
              color: theme.primaryColor.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, -8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: AnimatedBottomNavigationBar.builder(
          itemCount: AppIcons.bottomNav.length,
          tabBuilder: (int index, bool isActive) {
            final color = isActive ? theme.primaryColor : Colors.grey.shade600;
            final icon = AppIcons.bottomNav[index].of(isActive);
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
                      icon,
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
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          shadow: const BoxShadow(color: Colors.transparent, blurRadius: 0),
          height: 65.h,
          elevation: 0,
        ),
      ),
    );
  }
}
