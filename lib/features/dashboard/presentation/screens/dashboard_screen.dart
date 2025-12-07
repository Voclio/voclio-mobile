import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/dashboard_cubit.dart';
import '../bloc/dashboard_state.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<DashboardCubit>().refresh(),
          ),
        ],
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    state.message,
                    style: TextStyle(fontSize: 16.sp, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton.icon(
                    onPressed:
                        () =>
                            context.read<DashboardCubit>().loadDashboardStats(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 32.w,
                        vertical: 12.h,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is DashboardStatsLoaded) {
            final stats = state.stats;
            return RefreshIndicator(
              onRefresh: () => context.read<DashboardCubit>().refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Header Stats Cards
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Progress',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Keep up the great work!',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Row(
                            children: [
                              _buildQuickStat(
                                'Streak',
                                '${stats.productivityStats.currentStreak}',
                                'days',
                                Icons.local_fire_department_rounded,
                                Colors.orange.shade400,
                              ),
                              SizedBox(width: 16.w),
                              _buildQuickStat(
                                'Tasks',
                                '${stats.taskStats.completedTasks}/${stats.taskStats.totalTasks}',
                                'done',
                                Icons.task_alt_rounded,
                                Colors.green.shade400,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Main Content
                    Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Task Completion Circle
                          _buildCompletionCard(
                            stats.taskStats.completionRate,
                            stats.taskStats,
                          ),

                          SizedBox(height: 24.h),

                          // Overview Grid
                          Text(
                            'Overview',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Expanded(
                                child: _buildOverviewCard(
                                  'Notes',
                                  stats.noteStats.totalNotes.toString(),
                                  Icons.note_rounded,
                                  const Color(0xFF9C27B0),
                                  'Total',
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: _buildOverviewCard(
                                  'This Week',
                                  stats.noteStats.notesThisWeek.toString(),
                                  Icons.event_note_rounded,
                                  const Color(0xFF00BCD4),
                                  'Notes',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Expanded(
                                child: _buildOverviewCard(
                                  'Focus Time',
                                  '${(stats.productivityStats.totalFocusTime / 60).toStringAsFixed(1)}h',
                                  Icons.timer_rounded,
                                  const Color(0xFF3F51B5),
                                  'Total',
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: _buildOverviewCard(
                                  'Sessions',
                                  stats.productivityStats.focusSessionsCompleted
                                      .toString(),
                                  Icons.psychology_rounded,
                                  const Color(0xFFFF9800),
                                  'Completed',
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 24.h),

                          // Upcoming Tasks
                          if (stats.upcomingTasks.isNotEmpty) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Upcoming Tasks',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  '${stats.upcomingTasks.length} tasks',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            ...stats.upcomingTasks
                                .take(5)
                                .map((task) => _buildTaskItem(task)),
                          ],

                          SizedBox(height: 100.h), // Bottom nav space
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text('No data available'));
        },
      ),
    );
  }

  Widget _buildQuickStat(
    String label,
    String value,
    String suffix,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20.sp),
                ),
                SizedBox(width: 8.w),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              suffix,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionCard(double completionRate, dynamic taskStats) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCompletionStat(
                'Pending',
                taskStats.pendingTasks,
                Colors.orange,
              ),
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${completionRate.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Completed',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildCompletionStat(
                'Overdue',
                taskStats.overdueTasks,
                Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 13.sp, color: Colors.black54)),
      ],
    );
  }

  Widget _buildOverviewCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11.sp, color: Colors.black38),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(dynamic task) {
    final isUrgent =
        task.dueDate != null &&
        task.dueDate!.difference(DateTime.now()).inHours < 24;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isUrgent ? Colors.red.shade200 : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: isUrgent ? Colors.red : Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (task.description != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    task.description!,
                    style: TextStyle(fontSize: 13.sp, color: Colors.black54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (task.dueDate != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isUrgent ? Colors.red.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                _formatDueDate(task.dueDate!),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isUrgent ? Colors.red.shade700 : Colors.blue.shade700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);

    if (difference.inHours < 1) return 'Due now';
    if (difference.inHours < 24) return '${difference.inHours}h';
    if (difference.inDays < 7) return '${difference.inDays}d';
    return '${dueDate.day}/${dueDate.month}';
  }
}
