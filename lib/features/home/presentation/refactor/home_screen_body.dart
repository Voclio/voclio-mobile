import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:voclio_app/features/home/presentation/widgets/home_list_tile.dart';
import 'package:voclio_app/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:voclio_app/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:voclio_app/features/dashboard/domain/entities/dashboard_stats_entity.dart';

class HomeScreenBody extends StatefulWidget {
  final Function(int)? onTabChange;
  const HomeScreenBody({super.key, this.onTabChange});

  @override
  State<HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<HomeScreenBody>
    with TickerProviderStateMixin {
  final PageController _controller = PageController();

  final List<String> images = const [
    'assets/images/freepik__modern-vector-illustration-of-person-speaking-into__23557.png',
    'assets/images/Banner.png',
    'assets/images/raw.png',
  ];

  int currentIndex = 0;
  Timer? timer;
  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadDashboardStats();

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    timer?.cancel();
    _controller.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Home header Info
              const HomeListTile()
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideX(begin: -0.2, end: 0),

              SizedBox(height: 20.h),

              // Welcome Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Activity',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E),
                        fontSize: 24.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Track your progress and stay organized',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

              SizedBox(height: 20.h),

              // Stats Cards
              BlocBuilder<DashboardCubit, DashboardState>(
                builder: (context, state) {
                  final stats =
                      state is DashboardStatsLoaded ? state.stats : null;
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatsCard(
                            theme,
                            Icons.task_alt_rounded,
                            stats?.overview.totalTasks.toString() ?? '...',
                            'Tasks',
                            400,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildStatsCard(
                            theme,
                            Icons.note_alt_outlined,
                            stats?.overview.totalNotes.toString() ?? '...',
                            'Notes',
                            500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              SizedBox(height: 32.h),

              // Daily Progress Section
              BlocBuilder<DashboardCubit, DashboardState>(
                builder: (context, state) {
                  final stats =
                      state is DashboardStatsLoaded ? state.stats : null;
                  final progress = stats?.overview.overallProgress ?? 0.0;
                  final completed = stats?.overview.completedTasks ?? 0;
                  final total = stats?.overview.totalTasks ?? 0;
                  final pending = stats?.overview.pendingTasks ?? 0;
                  final recordings = stats?.overview.totalRecordings ?? 0;

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Progress',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A2E),
                            fontSize: 20.sp,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Container(
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: theme.primaryColor.withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.primaryColor.withOpacity(0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '$completed of $total tasks completed',
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1A1A2E),
                                    ),
                                  ),
                                  Text(
                                    '${progress.toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w700,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: LinearProgressIndicator(
                                  value: progress / 100,
                                  minHeight: 8.h,
                                  backgroundColor: theme.primaryColor
                                      .withOpacity(0.1),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.primaryColor,
                                  ),
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Row(
                                children: [
                                  _buildProgressStat(
                                    pending.toString(),
                                    'Remaining',
                                    Icons.schedule_rounded,
                                    Colors.orange.shade400,
                                  ),
                                  SizedBox(width: 16.w),
                                  _buildProgressStat(
                                    recordings.toString(),
                                    'Voice Notes',
                                    Icons.mic_none_rounded,
                                    theme.primaryColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 600.ms);
                },
              ),

              SizedBox(height: 32.h),

              // Upcoming Tasks Section
              BlocBuilder<DashboardCubit, DashboardState>(
                builder: (context, state) {
                  final tasks =
                      state is DashboardStatsLoaded
                          ? state.stats.upcomingTasks
                          : <TaskEntity>[];

                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Upcoming Tasks',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1A2E),
                                fontSize: 20.sp,
                              ),
                            ),
                            TextButton(
                              onPressed: () => widget.onTabChange?.call(1),
                              child: Text(
                                'View All',
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 700.ms),
                      SizedBox(height: 12.h),
                      if (tasks.isEmpty && state is DashboardStatsLoaded)
                        Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Text(
                            'No upcoming tasks',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        )
                      else if (state is DashboardLoading)
                        Padding(
                          padding: EdgeInsets.all(20.w),
                          child: const CircularProgressIndicator(),
                        )
                      else
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Column(
                            children:
                                tasks
                                    .take(3)
                                    .map(
                                      (task) => Padding(
                                        padding: EdgeInsets.only(bottom: 12.h),
                                        child: _buildTaskItem(
                                              task.title,
                                              task.dueDate != null
                                                  ? DateFormat(
                                                    'MMM d, h:mm a',
                                                  ).format(task.dueDate!)
                                                  : 'No due date',
                                              task.priority.toLowerCase() ==
                                                      'high'
                                                  ? Colors.red.shade400
                                                  : theme.primaryColor,
                                              task.status.toLowerCase() ==
                                                  'completed',
                                            )
                                            .animate()
                                            .fadeIn(duration: 600.ms)
                                            .slideX(begin: -0.1),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                    ],
                  );
                },
              ),

              SizedBox(height: 32.h),

              // Recent Notes Section
              BlocBuilder<DashboardCubit, DashboardState>(
                builder: (context, state) {
                  final notes =
                      state is DashboardStatsLoaded
                          ? state.stats.recentNotes
                          : <NoteEntity>[];

                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Notes',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1A2E),
                                fontSize: 20.sp,
                              ),
                            ),
                            TextButton(
                              onPressed: () => widget.onTabChange?.call(3),
                              child: Text(
                                'View All',
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 1100.ms),
                      SizedBox(height: 12.h),
                      if (notes.isEmpty && state is DashboardStatsLoaded)
                        Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Text(
                            'No recent notes',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        )
                      else if (state is DashboardLoading)
                        Padding(
                          padding: EdgeInsets.all(20.w),
                          child: const CircularProgressIndicator(),
                        )
                      else
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Column(
                            children:
                                notes
                                    .take(2)
                                    .map(
                                      (note) => Padding(
                                        padding: EdgeInsets.only(bottom: 12.h),
                                        child: _buildNoteItem(
                                              note.title,
                                              note.preview,
                                              DateFormat(
                                                'MMM d, yyyy',
                                              ).format(note.createdAt),
                                              theme.primaryColor,
                                            )
                                            .animate()
                                            .fadeIn(duration: 600.ms)
                                            .slideX(begin: -0.1),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                    ],
                  );
                },
              ),

              SizedBox(height: 32.h),

              // Quick Actions Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  'Quick Actions',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                    fontSize: 20.sp,
                  ),
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 600.ms),

              SizedBox(height: 16.h),

              // Action Cards
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    _buildActionCard(
                          context,
                          'Record Voice Note',
                          'Capture your thoughts instantly',
                          Icons.mic_rounded,
                          theme.primaryColor,
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 700.ms)
                        .slideX(begin: -0.2),
                    SizedBox(height: 12.h),
                    _buildActionCard(
                          context,
                          'Create Task',
                          'Add a new task to your list',
                          Icons.add_task_rounded,
                          theme.primaryColor,
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 800.ms)
                        .slideY(begin: 0.2),
                    SizedBox(height: 12.h),
                    _buildActionCard(
                          context,
                          'View Calendar',
                          'Check your upcoming events',
                          Icons.calendar_month_rounded,
                          theme.primaryColor,
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 900.ms)
                        .slideX(begin: 0.2),
                  ],
                ),
              ),

              SizedBox(height: 100.h), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(
    ThemeData theme,
    IconData icon,
    String value,
    String label,
    int delay,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.9), size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.white.withOpacity(0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: delay.ms).slideY(begin: 0.2);
  }

  Widget _buildProgressStat(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20.sp),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(
    String title,
    String time,
    Color color,
    bool isCompleted,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: isCompleted ? color : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              isCompleted ? Icons.check_rounded : Icons.circle_outlined,
              color: isCompleted ? Colors.white : color,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteItem(
    String title,
    String preview,
    String time,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.note_outlined, color: color, size: 18.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            preview,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8.h),
          Text(
            time,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16.sp,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}
