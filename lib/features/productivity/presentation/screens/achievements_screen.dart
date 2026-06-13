import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_tokens.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_widgets.dart';
import '../../domain/entities/productivity_entities.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/productivity_cubit.dart';
import '../bloc/productivity_state.dart';
import 'package:voclio_app/core/icons/app_icons.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProductivityCubit>()..loadProductivityData(),
      child: HomeSecondaryScaffold(
        title: 'Achievements',
        subtitle: 'Track your milestones',
        icon: AppIcons.emoji_events_rounded,
        accent: HomeSystemTokens.orange,
        body: BlocBuilder<ProductivityCubit, ProductivityState>(
          builder: (context, state) {
            if (state is ProductivityLoading || state is ProductivityInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProductivityDataLoaded) {
              final achievements = state.achievements;
              final unlockedCount =
                  achievements.where((item) => item.isUnlocked).length;

              return RefreshIndicator(
                color: HomeSystemTokens.orange,
                onRefresh: () =>
                    context.read<ProductivityCubit>().loadProductivityData(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 32.h),
                  children: [
                    _buildStreakHero(state.streak),
                    SizedBox(height: 14.h),
                    _buildStatsRow(
                      streak: state.streak,
                      unlockedCount: unlockedCount,
                      totalCount: achievements.length,
                    ),
                    SizedBox(height: 22.h),
                    HomeSectionTitle(
                      title: 'Goal Milestones',
                      trailing: '$unlockedCount/${achievements.length}',
                    ),
                    SizedBox(height: 10.h),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 0.78,
                      ),
                      itemCount: achievements.length,
                      itemBuilder: (context, index) {
                        return _buildAchievementCard(achievements[index]);
                      },
                    ),
                  ],
                ),
              );
            }

            if (state is ProductivityError) {
              return HomeEmptyState(
                icon: AppIcons.error_outline_rounded,
                title: 'Something went wrong',
                message: state.message,
                actionLabel: 'Retry',
                accent: HomeSystemTokens.coral,
                onAction: () {
                  context.read<ProductivityCubit>().loadProductivityData();
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildStreakHero(StreakEntity streak) {
    final current = streak.currentStreak;
    final nextMilestone = current == 0 ? 1 : ((current ~/ 7) + 1) * 7;
    final progressInWeek = current == 0 ? 0.0 : (current % 7) / 7;
    final daysToMilestone = nextMilestone - current;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: HomeSystemTokens.purple.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Streak',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$current',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 44.sp,
                            fontWeight: FontWeight.w800,
                            height: 0.95,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Padding(
                          padding: EdgeInsets.only(bottom: 6.h),
                          child: Icon(
                            AppIcons.local_fire_department_rounded,
                            color: HomeSystemTokens.orange,
                            size: 30.sp,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Text(
                            current == 1 ? 'day' : 'days',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Best',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 11.sp,
                      ),
                    ),
                    Text(
                      '${streak.longestStreak}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'days',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildWeekDots(current),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(100.r),
            child: LinearProgressIndicator(
              value: progressInWeek,
              minHeight: 8.h,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            current == 0
                ? 'Complete a focus session today to start your streak'
                : daysToMilestone == 0
                    ? 'You hit a weekly milestone — keep the fire going!'
                    : '$daysToMilestone day${daysToMilestone == 1 ? '' : 's'} to $nextMilestone-day milestone',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.86),
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDots(int currentStreak) {
    final activeDays = currentStreak % 7 == 0 && currentStreak > 0
        ? 7
        : currentStreak % 7;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final isActive = index < activeDays;
        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 28.r,
              height: 28.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.12),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: HomeSystemTokens.orange.withValues(alpha: 0.45),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
              child: isActive
                  ? Icon(
                      AppIcons.local_fire_department_rounded,
                      size: 14.sp,
                      color: HomeSystemTokens.orange,
                    )
                  : null,
            ),
            SizedBox(height: 4.h),
            Text(
              ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index],
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatsRow({
    required StreakEntity streak,
    required int unlockedCount,
    required int totalCount,
  }) {
    return Row(
      children: [
        Expanded(
          child: _StatChip(
            icon: AppIcons.timer_outlined,
            label: 'Points',
            value: '${streak.totalPoints}',
            color: HomeSystemTokens.purple,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _StatChip(
            icon: AppIcons.emoji_events_outlined,
            label: 'Unlocked',
            value: '$unlockedCount/$totalCount',
            color: HomeSystemTokens.orange,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _StatChip(
            icon: AppIcons.bolt_rounded,
            label: 'Best',
            value: '${streak.longestStreak}d',
            color: HomeSystemTokens.green,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(AchievementEntity achievement) {
    final isUnlocked = achievement.isUnlocked;
    final progress = achievement.progress;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isUnlocked
              ? HomeSystemTokens.orange.withValues(alpha: 0.35)
              : HomeSystemTokens.inkMuted.withValues(alpha: 0.1),
          width: isUnlocked ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isUnlocked
                ? HomeSystemTokens.orange.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46.r,
                height: 46.r,
                decoration: BoxDecoration(
                  gradient: isUnlocked
                      ? LinearGradient(
                          colors: [
                            HomeSystemTokens.orange.withValues(alpha: 0.18),
                            HomeSystemTokens.purple.withValues(alpha: 0.12),
                          ],
                        )
                      : null,
                  color: isUnlocked
                      ? null
                      : HomeSystemTokens.canvas,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    achievement.icon,
                    style: TextStyle(
                      fontSize: 24.sp,
                      color: isUnlocked ? null : HomeSystemTokens.inkMuted,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                isUnlocked
                    ? AppIcons.check_circle_rounded
                    : AppIcons.lock_outline_rounded,
                size: 18.sp,
                color: isUnlocked
                    ? HomeSystemTokens.green
                    : HomeSystemTokens.inkMuted,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            achievement.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: isUnlocked ? HomeSystemTokens.ink : HomeSystemTokens.inkSoft,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            achievement.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.sp,
              height: 1.3,
              color: HomeSystemTokens.inkMuted,
            ),
          ),
          const Spacer(),
          if (!isUnlocked) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(100.r),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6.h,
                backgroundColor: HomeSystemTokens.canvas,
                valueColor: AlwaysStoppedAnimation<Color>(
                  HomeSystemTokens.purple.withValues(alpha: 0.75),
                ),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              '${achievement.progressCurrent}/${achievement.progressTarget}',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: HomeSystemTokens.inkMuted,
              ),
            ),
          ] else ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: HomeSystemTokens.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    AppIcons.stars_rounded,
                    size: 12.sp,
                    color: HomeSystemTokens.orange,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'UNLOCKED',
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w800,
                      color: HomeSystemTokens.orange,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18.sp),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: HomeSystemTokens.ink,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: HomeSystemTokens.inkMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
