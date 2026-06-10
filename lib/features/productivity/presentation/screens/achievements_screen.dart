import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_tokens.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_widgets.dart';
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
      child: HomeSecondaryScaffold(
        title: 'Achievements',
        subtitle: 'Track your milestones',
        icon: Icons.emoji_events_rounded,
        accent: HomeSystemTokens.orange,
        body: BlocBuilder<ProductivityCubit, ProductivityState>(
          builder: (context, state) {
            if (state is ProductivityLoading || state is ProductivityInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProductivityDataLoaded) {
              final allAchievements = _getMergedAchievements(
                state.achievements,
              );

              return RefreshIndicator(
                onRefresh: () =>
                    context.read<ProductivityCubit>().loadProductivityData(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 32.h),
                  children: [
                    _buildStreakCard(context, state.streak),
                    SizedBox(height: 8.h),
                    HomeSectionTitle(
                      title: 'Goal Milestones',
                      trailing:
                          '${state.achievements.where((a) => a.isUnlocked).length}/${allAchievements.length}',
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 0.82,
                      ),
                      itemCount: allAchievements.length,
                      itemBuilder: (context, index) {
                        return _buildAchievementCard(allAchievements[index]);
                      },
                    ),
                  ],
                ),
              );
            }

            if (state is ProductivityError) {
              return HomeEmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Something went wrong',
                message: state.message,
                actionLabel: 'Retry',
                accent: HomeSystemTokens.coral,
                onAction: () {
                  context.read<ProductivityCubit>().loadProductivityData();
                },
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

    if (backendAchievements.isEmpty) {
      return baseMilestones;
    }

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
    return HomeSectionCard(
      padding: EdgeInsets.all(24.w),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [HomeSystemTokens.purple, Color(0xFF6366F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(HomeSystemTokens.radiusMd),
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
                        color: Colors.white.withValues(alpha: 0.9),
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
                          color: HomeSystemTokens.orange,
                          size: 32.sp,
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Best Streak',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
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
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 8.h,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Keep going! ${7 - (streak.currentStreak % 7)} days to next milestone',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(AchievementEntity achievement) {
    final isUnlocked = achievement.isUnlocked;

    return HomeSectionCard(
      padding: EdgeInsets.all(16.w),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? HomeSystemTokens.orange.withValues(alpha: 0.1)
                      : HomeSystemTokens.inkMuted.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: ColorFiltered(
                  colorFilter: isUnlocked
                      ? const ColorFilter.mode(
                          Colors.transparent,
                          BlendMode.multiply,
                        )
                      : const ColorFilter.matrix([
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0, 0, 0, 1, 0,
                        ]),
                  child: Text(
                    achievement.icon,
                    style: TextStyle(
                      fontSize: 36.sp,
                      color: isUnlocked ? null : HomeSystemTokens.inkMuted,
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
                  color: isUnlocked
                      ? HomeSystemTokens.ink
                      : HomeSystemTokens.inkSoft,
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
                  color: HomeSystemTokens.inkMuted,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (isUnlocked) ...[
                SizedBox(height: 10.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: HomeSystemTokens.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.stars_rounded,
                        color: HomeSystemTokens.orange,
                        size: 12.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'UNLOCKED',
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.bold,
                          color: HomeSystemTokens.orange,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (!isUnlocked)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: HomeSystemTokens.canvas,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 14.sp,
                  color: HomeSystemTokens.inkMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
