import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/productivity_cubit.dart';
import '../bloc/productivity_state.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProductivityCubit>()..loadAchievements(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Achievements')),
        body: BlocBuilder<ProductivityCubit, ProductivityState>(
          builder: (context, state) {
            if (state is ProductivityLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AchievementsLoaded) {
              if (state.achievements.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events, size: 64.sp, color: Colors.grey),
                      SizedBox(height: 16.h),
                      Text(
                        'No achievements yet',
                        style: TextStyle(fontSize: 18.sp, color: Colors.grey),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Complete tasks to unlock achievements!',
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: EdgeInsets.all(16.w),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 0.85,
                ),
                itemCount: state.achievements.length,
                itemBuilder: (context, index) {
                  final achievement = state.achievements[index];
                  return Card(
                    elevation: achievement.isUnlocked ? 4 : 1,
                    color: achievement.isUnlocked ? null : Colors.grey[300],
                    child: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Opacity(
                            opacity: achievement.isUnlocked ? 1.0 : 0.3,
                            child: Text(
                              achievement.icon,
                              style: TextStyle(fontSize: 40.sp),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            achievement.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color:
                                  achievement.isUnlocked
                                      ? Colors.black
                                      : Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Flexible(
                            child: Text(
                              achievement.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (achievement.isUnlocked) ...[
                            SizedBox(height: 6.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                'Unlocked',
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            }

            if (state is ProductivityError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProductivityCubit>().loadAchievements();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
