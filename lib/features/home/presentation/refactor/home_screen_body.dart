import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import '../../../../core/app/linaer_container.dart';
import '../widjets/home_dashboard.dart';
import '../widjets/home_list_tile.dart';

class HomeScreenBody extends StatefulWidget {
  const HomeScreenBody({super.key});

  @override
  State<HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<HomeScreenBody> {
  final PageController _controller = PageController();

  final List<String> images = const [
    'assets/images/freepik__modern-vector-illustration-of-person-speaking-into__23557.png',
    'assets/images/Banner.png',
    'assets/images/raw.png',
  ];

  int currentIndex = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(seconds: 5), (Timer t) {
      if (currentIndex < images.length - 1) {
        currentIndex++;
      } else {
        currentIndex = 0;
      }

      _controller.animateToPage(
        currentIndex,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LinearContainer(
        child: SafeArea(
          child: Column(
            children: [
              // Home header Info
              const HomeListTile(),
              SizedBox(height: 15.h),

              // 🔥 Auto Scrolling Banner 🔥
              SizedBox(
                height: 180.h,
                child: PageView.builder(
                  controller: _controller,
                  itemCount: images.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: Image.asset(
                          images[index],
                          width: 320.w,
                          height: 180.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
