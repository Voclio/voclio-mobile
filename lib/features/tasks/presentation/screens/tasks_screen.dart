import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get_it/get_it.dart';
import 'package:voclio_app/core/domain/entities/tag_entity.dart';

import 'package:voclio_app/features/tasks/domain/entities/task_entity.dart';
import 'package:voclio_app/features/tasks/presentation/bloc/tasks_state.dart';
import 'package:voclio_app/features/tasks/presentation/widgets/add_task_buttom_sheet.dart';
import 'package:voclio_app/features/tasks/presentation/screens/task_details_screen.dart';

import '../bloc/tasks_cubit.dart';
import '../widgets/task_tile.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: GetIt.I<TasksCubit>(),
      child: const _TasksDashboardView(),
    );
  }
}

class _TasksDashboardView extends StatefulWidget {
  const _TasksDashboardView();

  @override
  State<_TasksDashboardView> createState() => _TasksDashboardViewState();
}

class _TasksDashboardViewState extends State<_TasksDashboardView> {
  @override
  void initState() {
    super.initState();
    // Initialize data when screen mounts
    context.read<TasksCubit>().init();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, state) {
        // --- CALCULATIONS ---
        final totalTasks =
            state
                .tasks
                .length; // This is now the filtered count if a filter is active
        final completedTasks = state.tasks.where((t) => t.isDone).length;
        final double progressValue =
            totalTasks == 0 ? 0 : completedTasks / totalTasks;
        final int progressPercent = (progressValue * 100).toInt();

        // --- FILTERING ---
        // Tasks are already filtered by the Cubit/Server
        final visibleTasks = state.tasks;

        final todayTasks = _filterTasksByDate(visibleTasks, 0);
        final tomorrowTasks = _filterTasksByDate(visibleTasks, 1);
        final laterTasks = _filterTasksByDate(visibleTasks, 2);

        return Scaffold(
          // 1. Use Theme Background
          backgroundColor: theme.scaffoldBackgroundColor,

          appBar: AppBar(
            // 2. Make AppBar Transparent
            backgroundColor: Colors.transparent,
            elevation: 0,
            // 3. Center the title layout or keep spacing
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tasks',
                          // 4. Use Theme Typography
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'You have $totalTasks tasks',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideX(begin: -0.2, end: 0),
                IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.filter_list_rounded,
                        // 5. Use Theme Icon Color
                        color: theme.colorScheme.onSurface,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 100.ms)
                    .scale(begin: const Offset(0.8, 0.8)),
              ],
            ),
          ),

          floatingActionButton: Padding(
            padding: EdgeInsets.only(bottom: 85.h),
            child: FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder:
                      (_) => BlocProvider.value(
                        value: context.read<TasksCubit>(),
                        child: const AddTaskBottomSheet(),
                      ),
                );
              },
              backgroundColor: theme.colorScheme.primary,
              elevation: 5,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),

          body: BlocListener<TasksCubit, TasksState>(
            listenWhen:
                (previous, current) => previous.status != current.status,
            listener: (context, state) {
              if (state.status == TasksStatus.failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage),
                    backgroundColor: theme.colorScheme.error,
                  ),
                );
              }
            },
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.h), // Reduced top spacing slightly
                    // Progress Card
                    // Only show progress card if viewing "All" (optional decision)
                    // or show progress for the current filter
                    _buildProgressCard(context, progressValue, progressPercent)
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 200.ms)
                        .slideY(begin: 0.2, end: 0),

                    SizedBox(height: 24.h),

                    // Tag Filter Chips (Like Notes Screen)
                    BlocBuilder<TasksCubit, TasksState>(
                          builder: (context, state) {
                            return SizedBox(
                              height: 40.h,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  // "All" Chip
                                  _buildFilterChip(
                                    context,
                                    label: 'All',
                                    isSelected: state.selectedTagName == null,
                                    onTap:
                                        () => context
                                            .read<TasksCubit>()
                                            .filterByTag(null),
                                  ),
                                  SizedBox(width: 10.w),
                                  // Dynamic Tag Chips
                                  ...state.availableTags.map((tag) {
                                    return Padding(
                                      padding: EdgeInsets.only(right: 10.w),
                                      child: _buildFilterChip(
                                        context,
                                        label: tag.name,
                                        isSelected:
                                            state.selectedTagName == tag.name,
                                        onTap:
                                            () => context
                                                .read<TasksCubit>()
                                                .filterByTag(tag.name),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            );
                          },
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 300.ms)
                        .slideX(begin: -0.2, end: 0),

                    SizedBox(height: 24.h),

                    // Top Loading Indicator
                    if (state.status == TasksStatus.loading)
                      Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child:
                            LinearProgressIndicator(
                              minHeight: 2.h,
                              backgroundColor: theme.colorScheme.primary
                                  .withOpacity(0.1),
                              color: theme.colorScheme.primary,
                            ).animate().fadeIn(),
                      ),

                    // Task List
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          if (state.status == TasksStatus.loading &&
                              state.tasks.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 48.w,
                                    height: 48.h,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'Loading tasks...',
                                    style: TextStyle(
                                      color: theme.colorScheme.secondary,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else if (visibleTasks.isEmpty) {
                            return RefreshIndicator(
                              onRefresh:
                                  () => context.read<TasksCubit>().init(),
                              child: ListView(
                                children: [
                                  SizedBox(height: 80.h),
                                  _buildEmptyState(context, state.selectedTagName),
                                ],
                              ),
                            );
                          }

                          return RefreshIndicator(
                            onRefresh: () => context.read<TasksCubit>().init(),
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: EdgeInsets.only(bottom: 100.h),
                              children: [
                                if (todayTasks.isNotEmpty) ...[
                                  _buildSectionHeader(context, "Today"),
                                  ...todayTasks.asMap().entries.map(
                                    (entry) => _buildTaskItem(
                                          context,
                                          entry.value,
                                          state.availableTags,
                                        )
                                        .animate()
                                        .fadeIn(
                                          duration: 400.ms,
                                          delay: Duration(
                                            milliseconds: 50 * entry.key,
                                          ),
                                        )
                                        .slideX(
                                          begin: -0.2,
                                          end: 0,
                                          duration: 400.ms,
                                          delay: Duration(
                                            milliseconds: 50 * entry.key,
                                          ),
                                        ),
                                  ),
                                ],
                                if (tomorrowTasks.isNotEmpty) ...[
                                  SizedBox(height: 20.h),
                                  _buildSectionHeader(context, "Tomorrow"),
                                  ...tomorrowTasks.asMap().entries.map(
                                    (entry) => _buildTaskItem(
                                          context,
                                          entry.value,
                                          state.availableTags,
                                        )
                                        .animate()
                                        .fadeIn(
                                          duration: 400.ms,
                                          delay: Duration(
                                            milliseconds: 50 * entry.key,
                                          ),
                                        )
                                        .slideX(
                                          begin: -0.2,
                                          end: 0,
                                          duration: 400.ms,
                                          delay: Duration(
                                            milliseconds: 50 * entry.key,
                                          ),
                                        ),
                                  ),
                                ],
                                if (laterTasks.isNotEmpty) ...[
                                  SizedBox(height: 20.h),
                                  _buildSectionHeader(context, "Later"),
                                  ...laterTasks.asMap().entries.map(
                                    (entry) => _buildTaskItem(
                                          context,
                                          entry.value,
                                          state.availableTags,
                                        )
                                        .animate()
                                        .fadeIn(
                                          duration: 400.ms,
                                          delay: Duration(
                                            milliseconds: 50 * entry.key,
                                          ),
                                        )
                                        .slideX(
                                          begin: -0.2,
                                          end: 0,
                                          duration: 400.ms,
                                          delay: Duration(
                                            milliseconds: 50 * entry.key,
                                          ),
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Helpers ---

  Widget _buildProgressCard(
    BuildContext context,
    double progressValue,
    int percentage,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isComplete = percentage == 100;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: isComplete 
            ? (isDark ? Colors.green.withOpacity(0.15) : Colors.green.shade50)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: isComplete 
            ? Border.all(color: Colors.green.withOpacity(0.3), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: isComplete 
                ? Colors.green.withOpacity(0.1)
                : Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: !isComplete && isDark
            ? LinearGradient(
                colors: [
                  theme.colorScheme.secondary.withOpacity(0.1),
                  theme.colorScheme.secondary.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (isComplete) ...[
                    Icon(
                      Icons.celebration_rounded,
                      color: Colors.green,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                  ],
                  Text(
                    isComplete ? "All Done!" : "Overall Progress",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isComplete ? Colors.green.shade700 : null,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isComplete
                      ? Colors.green.withOpacity(0.2)
                      : theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  "$percentage%",
                  style: TextStyle(
                    color: isComplete ? Colors.green.shade700 : theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: progressValue,
              backgroundColor: isDark 
                  ? Colors.white10 
                  : (isComplete ? Colors.green.shade100 : Colors.deepPurple.shade50),
              color: isComplete ? Colors.green : theme.colorScheme.primary,
              minHeight: 10.h,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(
    BuildContext context,
    TaskEntity task,
    List<TagEntity> availableTags,
  ) {
    return TaskTile(
      task: task,
      availableTags: availableTags,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => BlocProvider.value(
                  value: context.read<TasksCubit>(),
                  child: TaskDetailScreen(task: task),
                ),
          ),
        );
      },
      onCheckChanged: (val) {
        context.read<TasksCubit>().toggleTaskStatus(task);
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, left: 4.w),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 18.sp,
        ),
      ),
    );
  }

  List<TaskEntity> _filterTasksByDate(List<TaskEntity> tasks, int type) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return tasks.where((t) {
      final tDate = DateTime(t.date.year, t.date.month, t.date.day);
      if (type == 0) {
        // Today section: include current day AND everything in the past (overdue)
        return tDate.isAtSameMomentAs(today) || tDate.isBefore(today);
      }
      if (type == 1) return tDate.isAtSameMomentAs(tomorrow);
      return tDate.isAfter(tomorrow);
    }).toList();
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color:
                isSelected
                    ? theme.colorScheme.primary
                    : (isDark ? Colors.white24 : Colors.black12),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context, String? selectedTagName) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration container
          Container(
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.task_alt_rounded,
              size: 60.sp,
              color: theme.colorScheme.primary.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            selectedTagName != null 
                ? 'No tasks in "$selectedTagName"'
                : 'No tasks yet',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              selectedTagName != null
                  ? 'Create a new task with this tag to see it here'
                  : 'Tap the + button to create your first task',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.secondary,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 32.h),
          ElevatedButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => BlocProvider.value(
                  value: context.read<TasksCubit>(),
                  child: const AddTaskBottomSheet(),
                ),
              );
            },
            icon: Icon(Icons.add_rounded, size: 20.sp),
            label: Text(
              'Create Task',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95));
  }
}
