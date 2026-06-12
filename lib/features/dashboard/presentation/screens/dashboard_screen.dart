import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_tokens.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_widgets.dart';
import '../../domain/entities/dashboard_stats_entity.dart';
import '../bloc/dashboard_cubit.dart';
import '../bloc/dashboard_state.dart';
import 'package:voclio_app/core/icons/app_icons.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadDashboardStats();
  }

  @override
  Widget build(BuildContext context) {
    return HomeSecondaryScaffold(
      title: 'Dashboard',
      subtitle: 'Your productivity at a glance',
      icon: AppIcons.insights_rounded,
      accent: HomeSystemTokens.purple,
      actions: [
        HomeIconButton(
          icon: AppIcons.refresh_rounded,
          color: HomeSystemTokens.inkSoft,
          onTap: () => context.read<DashboardCubit>().refresh(),
        ),
      ],
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return _buildLoadingSkeleton();
          }

          if (state is DashboardError) {
            return HomeEmptyState(
              icon: AppIcons.cloud_off_rounded,
              title: 'Could not load dashboard',
              message: state.message,
              actionLabel: 'Try again',
              accent: HomeSystemTokens.coral,
              onAction: () =>
                  context.read<DashboardCubit>().loadDashboardStats(),
            );
          }

          if (state is DashboardStatsLoaded) {
            return _buildContent(context, state.stats);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, DashboardStatsEntity stats) {
    final overview = stats.overview;
    final productivity = stats.productivity;
    final progress = (overview.overallProgress / 100).clamp(0.0, 1.0);

    return RefreshIndicator(
      color: HomeSystemTokens.purple,
      onRefresh: () => context.read<DashboardCubit>().refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 100.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroCard(overview, progress),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: HomeStatTile(
                    icon: AppIcons.task_alt_rounded,
                    color: HomeSystemTokens.purple,
                    label: 'Tasks',
                    value: '${overview.completedTasks}/${overview.totalTasks}',
                    subtitle: 'Completed',
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: HomeStatTile(
                    icon: AppIcons.notes_rounded,
                    color: HomeSystemTokens.blue,
                    label: 'Notes',
                    value: '${overview.totalNotes}',
                    subtitle: 'Saved',
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: HomeStatTile(
                    icon: AppIcons.local_fire_department_rounded,
                    color: HomeSystemTokens.orange,
                    label: 'Streak',
                    value: '${productivity.currentStreak}',
                    subtitle: 'Days',
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            HomeSectionTitle(title: 'Activity'),
            _buildActivityPanel(overview, productivity),
            if (stats.upcomingTasks.isNotEmpty) ...[
              SizedBox(height: 22.h),
              HomeSectionTitle(
                title: 'Coming up',
                trailing: '${stats.upcomingTasks.length}',
              ),
              _buildUpcomingCard(stats.upcomingTasks.take(5).toList()),
            ],
            if (stats.recentNotes.isNotEmpty) ...[
              SizedBox(height: 22.h),
              const HomeSectionTitle(title: 'Recent notes'),
              _buildRecentNotesCard(stats.recentNotes.take(4).toList()),
            ],
            if (stats.upcomingTasks.isEmpty && stats.recentNotes.isEmpty) ...[
              SizedBox(height: 24.h),
              HomeEmptyState(
                icon: AppIcons.rocket_launch_outlined,
                title: 'You are all caught up',
                message:
                    'Create tasks or notes to see your activity summary here.',
                accent: HomeSystemTokens.purple,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(DashboardOverview overview, double progress) {
    final percent = overview.overallProgress.clamp(0, 100);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(HomeSystemTokens.radiusLg.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HomeSystemTokens.purple.withValues(alpha: 0.12),
            HomeSystemTokens.blue.withValues(alpha: 0.06),
          ],
        ),
        boxShadow: HomeSystemTokens.cardShadow(opacity: 0.04),
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
                      'Overall completion',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: HomeSystemTokens.inkSoft,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '${percent.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 36.sp,
                        fontWeight: FontWeight.w800,
                        color: HomeSystemTokens.ink,
                        height: 1,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 72.r,
                height: 72.r,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      backgroundColor:
                          HomeSystemTokens.purple.withValues(alpha: 0.12),
                      color: HomeSystemTokens.purple,
                    ),
                    Text(
                      '${percent.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: HomeSystemTokens.purple,
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
              value: progress,
              minHeight: 6.h,
              backgroundColor: Colors.white.withValues(alpha: 0.55),
              color: HomeSystemTokens.purple,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _heroChip(
                '${overview.completedTasks}',
                'Done',
                HomeSystemTokens.green,
              ),
              SizedBox(width: 8.w),
              _heroChip(
                '${overview.pendingTasks}',
                'Pending',
                HomeSystemTokens.orange,
              ),
              SizedBox(width: 8.w),
              _heroChip(
                '${overview.overdueTasks}',
                'Overdue',
                HomeSystemTokens.coral,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroChip(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: HomeSystemTokens.inkMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityPanel(
    DashboardOverview overview,
    ProductivityStats productivity,
  ) {
    final items = [
      _ActivityItem(
        icon: AppIcons.mic_rounded,
        label: 'Voice notes',
        value: '${overview.totalRecordings}',
        color: HomeSystemTokens.blue,
      ),
      _ActivityItem(
        icon: AppIcons.emoji_events_outlined,
        label: 'Achievements',
        value: '${overview.totalAchievements}',
        color: HomeSystemTokens.orange,
      ),
      _ActivityItem(
        icon: AppIcons.bolt_rounded,
        label: 'Best streak',
        value: '${productivity.longestStreak}d',
        color: HomeSystemTokens.purple,
      ),
      _ActivityItem(
        icon: AppIcons.check_circle_outline_rounded,
        label: 'Completion',
        value: '${overview.overallProgress.toStringAsFixed(0)}%',
        color: HomeSystemTokens.green,
      ),
    ];

    return HomeSectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: Row(
                  children: [
                    Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(item.icon, color: item.color, size: 20.sp),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: HomeSystemTokens.ink,
                        ),
                      ),
                    ),
                    Text(
                      item.value,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: HomeSystemTokens.ink,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 68.w,
                  color: HomeSystemTokens.inkMuted.withValues(alpha: 0.12),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildUpcomingCard(List<TaskEntity> tasks) {
    return HomeSectionCard(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
      child: Column(
        children: List.generate(tasks.length, (index) {
          final task = tasks[index];
          final isLast = index == tasks.length - 1;
          final isDone = task.status.toLowerCase() == 'completed';
          final isUrgent = task.dueDate != null &&
              !isDone &&
              task.dueDate!.difference(DateTime.now()).inHours < 24;

          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 14.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22.r,
                  height: 22.r,
                  margin: EdgeInsets.only(top: 2.h),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone
                        ? HomeSystemTokens.green
                        : Colors.transparent,
                    border: Border.all(
                      color: isDone
                          ? HomeSystemTokens.green
                          : HomeSystemTokens.inkMuted.withValues(alpha: 0.35),
                      width: 2,
                    ),
                  ),
                  child: isDone
                      ? Icon(AppIcons.check, size: 14.sp, color: Colors.white)
                      : null,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: isDone
                              ? HomeSystemTokens.inkMuted
                              : HomeSystemTokens.ink,
                          decoration:
                              isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (task.dueDate != null) ...[
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(
                              AppIcons.schedule_rounded,
                              size: 13.sp,
                              color: isUrgent
                                  ? HomeSystemTokens.coral
                                  : HomeSystemTokens.inkMuted,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              DateFormat('MMM d · h:mm a').format(task.dueDate!),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: isUrgent
                                    ? HomeSystemTokens.coral
                                    : HomeSystemTokens.inkMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                _priorityDot(task.priority),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _priorityDot(String priority) {
    final color = switch (priority.toLowerCase()) {
      'high' => HomeSystemTokens.coral,
      'medium' => HomeSystemTokens.orange,
      'low' => HomeSystemTokens.green,
      _ => HomeSystemTokens.inkMuted,
    };

    return Container(
      width: 8.r,
      height: 8.r,
      margin: EdgeInsets.only(top: 8.h),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildRecentNotesCard(List<NoteEntity> notes) {
    return HomeSectionCard(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
      child: Column(
        children: List.generate(notes.length, (index) {
          final note = notes[index];
          final isLast = index == notes.length - 1;

          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 14.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: HomeSystemTokens.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    AppIcons.article_outlined,
                    color: HomeSystemTokens.blue,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: HomeSystemTokens.ink,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        note.preview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          height: 1.4,
                          color: HomeSystemTokens.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 40.h),
      child: Column(
        children: [
          Container(
            height: 160.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(HomeSystemTokens.radiusLg.r),
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 96.h,
            child: Row(
              children: List.generate(
                3,
                (i) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i < 2 ? 10.w : 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Container(
            height: 220.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(HomeSystemTokens.radiusLg.r),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ActivityItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}
