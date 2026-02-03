import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:voclio_app/features/home/presentation/widgets/home_list_tile.dart';
import 'package:voclio_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:voclio_app/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:voclio_app/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:voclio_app/features/dashboard/domain/entities/dashboard_stats_entity.dart';
import 'package:voclio_app/features/productivity/presentation/widgets/ai_suggestions_widget.dart';

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

    // Only fetch profile if user is already logged in (has valid auth state)
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      // Already have profile data, no need to fetch again
    } else if (authState is! AuthInitial) {
      // Only fetch if not in initial/guest state
      context.read<AuthBloc>().add(const GetProfileEvent());
    }

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
      backgroundColor: const Color(0xFFF8F9FC),
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

              SizedBox(height: 16.h),

              // Welcome Section with decorative background
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor.withOpacity(0.08),
                      theme.primaryColor.withOpacity(0.03),
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.primaryColor.withOpacity(0.2),
                                theme.primaryColor.withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.auto_graph_rounded,
                            color: theme.primaryColor,
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Activity',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1A1A2E),
                                  fontSize: 18.sp,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                'Track progress & stay organized',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.primaryColor,
                                theme.primaryColor.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color: theme.primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'Today',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.1),

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

              SizedBox(height: 24.h),

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
                        Row(
                          children: [
                            Text(
                              'Daily Progress',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1A2E),
                                fontSize: 18.sp,
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    progress >= 50
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                '${progress.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  color:
                                      progress >= 50
                                          ? Colors.green
                                          : Colors.orange,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),
                        Container(
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24.r),
                            boxShadow: [
                              BoxShadow(
                                color: theme.primaryColor.withOpacity(0.08),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
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
                                    '$completed of $total tasks',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    'completed',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 14.h),
                              Container(
                                height: 10.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.r),
                                  color: theme.primaryColor.withOpacity(0.1),
                                ),
                                child: Stack(
                                  children: [
                                    FractionallySizedBox(
                                      widthFactor: (progress / 100).clamp(0.0, 1.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10.r),
                                          gradient: LinearGradient(
                                            colors: [
                                              theme.primaryColor,
                                              theme.primaryColor.withOpacity(0.7),
                                              const Color(0xFF667EEA),
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: theme.primaryColor.withOpacity(0.4),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
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
                                  SizedBox(width: 12.w),
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

              SizedBox(height: 28.h),

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
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                                    ),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Icon(
                                    Icons.task_alt_rounded,
                                    color: Colors.white,
                                    size: 16.sp,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Text(
                                  'Upcoming Tasks',
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1A1A2E),
                                        fontSize: 18.sp,
                                        letterSpacing: -0.3,
                                      ),
                                ),
                                if (tasks.isNotEmpty) ...[
                                  SizedBox(width: 8.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 3.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Text(
                                      '${tasks.length}',
                                      style: TextStyle(
                                        color: theme.primaryColor,
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            TextButton(
                              onPressed: () => widget.onTabChange?.call(1),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'View All',
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontSize: 13.sp,
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

              SizedBox(height: 28.h),

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
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                    ),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Icon(
                                    Icons.note_alt_rounded,
                                    color: Colors.white,
                                    size: 16.sp,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Text(
                                  'Recent Notes',
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1A1A2E),
                                        fontSize: 18.sp,
                                        letterSpacing: -0.3,
                                      ),
                                ),
                                if (notes.isNotEmpty) ...[
                                  SizedBox(width: 8.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 3.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Text(
                                      '${notes.length}',
                                      style: TextStyle(
                                        color: theme.primaryColor,
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            TextButton(
                              onPressed: () => widget.onTabChange?.call(3),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'View All',
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontSize: 13.sp,
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

              SizedBox(height: 28.h),

              // Quick Actions Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4ECDC4), Color(0xFF44B09E)],
                        ),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.bolt_rounded,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'Quick Actions',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E),
                        fontSize: 18.sp,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
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

              SizedBox(height: 28.h),

              // AI Suggestions Section (at bottom for better UX)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: const AiSuggestionsWidget(),
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
    final isTask = label == 'Tasks';
    final gradientColors = isTask
        ? [theme.primaryColor, theme.primaryColor.withOpacity(0.85)]
        : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
    final shadowColor = isTask ? theme.primaryColor : const Color(0xFF6366F1);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -20.w,
            top: -20.h,
            child: Container(
              width: 80.r,
              height: 80.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            right: 10.w,
            bottom: -30.h,
            child: Container(
              width: 60.r,
              height: 60.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 24.sp),
              ),
              SizedBox(height: 16.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1,
                      height: 1,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 4.w, bottom: 4.h),
                    child: Icon(
                      isTask ? Icons.trending_up_rounded : Icons.auto_awesome,
                      color: Colors.white.withOpacity(0.8),
                      size: 18.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withOpacity(0.95),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: delay.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildProgressStat(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 16.sp),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey.shade500,
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
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: isCompleted
                ? Colors.green.withOpacity(0.08)
                : color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              gradient: isCompleted
                  ? const LinearGradient(
                      colors: [Color(0xFF4ECDC4), Color(0xFF44B09E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [color.withOpacity(0.15), color.withOpacity(0.08)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: isCompleted
                  ? [
                      BoxShadow(
                        color: const Color(0xFF4ECDC4).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              isCompleted
                  ? Icons.check_rounded
                  : Icons.circle_outlined,
              color: isCompleted ? Colors.white : color,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color:
                        isCompleted
                            ? Colors.grey.shade500
                            : const Color(0xFF1A1A2E),
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    decorationColor: Colors.grey.shade400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 13.sp,
                      color: Colors.grey.shade500,
                    ),
                    SizedBox(width: 4.w),
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
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 20.sp,
            color: Colors.grey.shade400,
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
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
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
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.sticky_note_2_rounded,
                  color: Colors.white,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16.sp,
                  color: const Color(0xFF6366F1),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            preview,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 12.sp,
                  color: Colors.grey.shade500,
                ),
                SizedBox(width: 4.w),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
    final gradientColors = icon == Icons.mic_rounded
        ? [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)]
        : icon == Icons.add_task_rounded
            ? [const Color(0xFF4ECDC4), const Color(0xFF44B09E)]
            : [const Color(0xFF667EEA), const Color(0xFF764BA2)];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: gradientColors[0].withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E),
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      gradientColors[0].withOpacity(0.1),
                      gradientColors[1].withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 18.sp,
                  color: gradientColors[0],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
