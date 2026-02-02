import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/productivity_entities.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/productivity_cubit.dart';
import '../bloc/productivity_state.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProductivityCubit>()..loadProductivityData(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Theme.of(context).primaryColor,
              size: 20.sp,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Achievements',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A2E),
            ),
          ),
        ),
        body: BlocBuilder<ProductivityCubit, ProductivityState>(
          builder: (context, state) {
            if (state is ProductivityLoading || state is ProductivityInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProductivityDataLoaded) {
              // Merge base milestones with backend achievements
              final allAchievements = _getMergedAchievements(
                state.achievements,
              );

              return RefreshIndicator(
                onRefresh:
                    () =>
                        context
                            .read<ProductivityCubit>()
                            .loadProductivityData(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    // Streak Section
                    _buildStreakCard(context, state.streak),

                    // Achievements Header
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Goal Milestones',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                          Text(
                            '${state.achievements.where((a) => a.isUnlocked).length}/${allAchievements.length}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 0.82,
                      ),
                      itemCount: allAchievements.length,
                      itemBuilder: (context, index) {
                        final achievement = allAchievements[index];
                        return _buildAchievementCard(achievement);
                      },
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              );
            }

            if (state is ProductivityError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48.sp,
                      color: Colors.red[300],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      state.message,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<ProductivityCubit>()
                            .loadProductivityData();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 32.w,
                          vertical: 12.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
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

  List<AchievementEntity> _getMergedAchievements(
    List<AchievementEntity> backendAchievements,
  ) {
    // Define base systemic milestones that should always appear
    final baseMilestones = [
      const AchievementEntity(
        id: 'streak_3',
        title: '3 Day Heat',
        description: 'Maintain a 3-day focus streak',
        icon: '🔥',
        isUnlocked: false,
      ),
      const AchievementEntity(
        id: 'first_focus',
        title: 'First Focus',
        description: 'Complete your first focus session',
        icon: '🎯',
        isUnlocked: false,
      ),
      const AchievementEntity(
        id: 'early_bird',
        title: 'Morning Bird',
        description: 'Start a session before 8:00 AM',
        icon: '🌅',
        isUnlocked: false,
      ),
      const AchievementEntity(
        id: 'focus_master',
        title: 'Focus Master',
        description: 'Finish a 60-minute focus session',
        icon: '👑',
        isUnlocked: false,
      ),
      const AchievementEntity(
        id: 'task_warrior',
        title: 'Task Warrior',
        description: 'Complete 10 tasks in one day',
        icon: '⚔️',
        isUnlocked: false,
      ),
      const AchievementEntity(
        id: 'night_owl',
        title: 'Night Owl',
        description: 'Complete a session after 11:00 PM',
        icon: '🦉',
        isUnlocked: false,
      ),
    ];

    // If backend provides achievements, merge them or use them to unlock base ones
    if (backendAchievements.isEmpty) {
      return baseMilestones;
    }

    // Merge logic: Use backend as source of truth, but ensure base milestones exist
    final Map<String, AchievementEntity> merged = {};
    for (var m in baseMilestones) {
      merged[m.id] = m;
    }
    for (var b in backendAchievements) {
      merged[b.id] = b;
    }

    return merged.values.toList();
  }

  Widget _buildStreakCard(BuildContext context, StreakEntity streak) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, const Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Streak',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        '${streak.currentStreak}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.local_fire_department_rounded,
                        color: Colors.orange[400],
                        size: 32.sp,
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    Text(
                      'Best Streak',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 11.sp,
                      ),
                    ),
                    Text(
                      '${streak.longestStreak} days',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: (streak.currentStreak % 7) / 7,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8.h,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Keep going! ${7 - (streak.currentStreak % 7)} days to next milestone',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(AchievementEntity achievement) {
    final isUnlocked = achievement.isUnlocked;

    return Container(
      decoration: BoxDecoration(
        color: isUnlocked ? Colors.white : Colors.grey[100],
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isUnlocked ? Colors.amber.shade300 : Colors.grey.shade200,
          width: isUnlocked ? 2 : 1,
        ),
        boxShadow:
            isUnlocked
                ? [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.15),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ]
                : [],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Achievement Icon with Glow
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color:
                        isUnlocked
                            ? Colors.amber.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.05),
                    shape: BoxShape.circle,
                    boxShadow:
                        isUnlocked
                            ? [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ]
                            : [],
                  ),
                  child: ColorFiltered(
                    colorFilter:
                        isUnlocked
                            ? const ColorFilter.mode(
                              Colors.transparent,
                              BlendMode.multiply,
                            )
                            : const ColorFilter.matrix([
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0,
                              0,
                              0,
                              1,
                              0,
                            ]),
                    child: Text(
                      achievement.icon,
                      style: TextStyle(
                        fontSize: 36.sp,
                        color: isUnlocked ? null : Colors.grey[400],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  achievement.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color:
                        isUnlocked ? const Color(0xFF1A1A2E) : Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  achievement.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey[600],
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isUnlocked) ...[
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: Colors.amber.shade200,
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.stars_rounded,
                          color: Colors.amber[700],
                          size: 12.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'UNLOCKED',
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[800],
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Locked status indicator
          if (!isUnlocked)
            Positioned(
              top: 12.r,
              right: 12.r,
              child: Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 14.sp,
                  color: Colors.grey[400],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
