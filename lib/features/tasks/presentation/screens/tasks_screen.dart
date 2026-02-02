import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get_it/get_it.dart';

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
  // We track selection by ID. null means 'All'.
  String? _selectedCategoryId;

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

        // Prepare Filter Tabs: [All, ...SeverCategories]
        // We use a helper object to represent "All"
        final categories = state.categories;

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

                    // Filter Chips
                    SizedBox(
                          height: 40.h,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              // "All" Chip
                              _buildFilterChip(
                                context,
                                label: 'All',
                                isSelected: _selectedCategoryId == null,
                                onTap: () {
                                  setState(() {
                                    _selectedCategoryId = null;
                                  });
                                  context.read<TasksCubit>().filterByCategory(
                                    null,
                                  );
                                },
                              ),
                              SizedBox(width: 10.w),
                              // Dynamic Category Chips
                              ...categories.map((cat) {
                                return Padding(
                                  padding: EdgeInsets.only(right: 10.w),
                                  child: _buildFilterChip(
                                    context,
                                    label: cat.name,
                                    isSelected: _selectedCategoryId == cat.id,
                                    onTap: () {
                                      setState(() {
                                        _selectedCategoryId = cat.id;
                                      });
                                      context
                                          .read<TasksCubit>()
                                          .filterByCategory(cat.id);
                                    },
                                    // You can use cat.color here if you want colorful chips
                                  ),
                                );
                              }),
                            ],
                          ),
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
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (visibleTasks.isEmpty) {
                            return RefreshIndicator(
                              onRefresh:
                                  () => context.read<TasksCubit>().init(),
                              child: ListView(
                                children: [
                                  SizedBox(height: 200.h),
                                  Center(
                                    child: Text(
                                      "No tasks found",
                                      style: TextStyle(
                                        color: theme.colorScheme.secondary,
                                      ),
                                    ),
                                  ),
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
                                    (entry) =>
                                        _buildTaskItem(context, entry.value)
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
                                    (entry) =>
                                        _buildTaskItem(context, entry.value)
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
                                    (entry) =>
                                        _buildTaskItem(context, entry.value)
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

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Matches theme card color
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        // Optional Gradient for Dark Mode to make it pop
        gradient:
            isDark
                ? LinearGradient(
                  colors: [
                    AppColors.darkCard,
                    AppColors.darkCard.withOpacity(0.8),
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
              Text("Overall Progress", style: theme.textTheme.bodyLarge),
              Text("$percentage%", style: theme.textTheme.bodyMedium),
            ],
          ),
          SizedBox(height: 15.h),
          LinearProgressIndicator(
            value: progressValue,
            backgroundColor:
                isDark ? Colors.white10 : Colors.deepPurple.shade50,
            color: theme.colorScheme.primary,
            minHeight: 8.h,
            borderRadius: BorderRadius.circular(10.r),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, TaskEntity task) {
    return TaskTile(
      task: task,
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
}
