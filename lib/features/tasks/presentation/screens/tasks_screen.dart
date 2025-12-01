import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart'; // Import GetIt

import 'package:voclio_app/features/tasks/domain/entities/task_entity.dart';
import 'package:voclio_app/features/tasks/presentation/bloc/tasks_state.dart';
import 'package:voclio_app/features/tasks/presentation/screens/add_task_buttom_sheet.dart';
import 'package:voclio_app/features/tasks/presentation/screens/task_details_screen.dart';

import '../bloc/tasks_cubit.dart';
import '../widgets/task_tile.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject the Cubit here
    return BlocProvider(
      create: (_) => GetIt.I<TasksCubit>()..getTasks(),
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
  int _selectedTagIndex = 0; // 0 = All

  // Make sure these match your AppTag.label getter exactly
  final List<String> _filterTags = [
    'All',
    'Study',
    'Work',
    'Health',
    'Personal',
  ];

  @override
  Widget build(BuildContext context) {
    // We can access total count for AppBar directly from BlocBuilder to keep it in sync
    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, state) {
        // --- 1. CALCULATE PROGRESS (Based on ALL tasks, not just filtered) ---
        final totalTasks = state.tasks.length;
        final completedTasks = state.tasks.where((t) => t.isDone).length;
        final double progressValue =
            totalTasks == 0 ? 0 : completedTasks / totalTasks;
        final int progressPercent = (progressValue * 100).toInt();

        // --- 2. FILTER LOGIC ---
        List<TaskEntity> visibleTasks = state.tasks;

        // If not "All" (index 0), filter by tag
        if (_selectedTagIndex != 0) {
          final selectedTagLabel = _filterTags[_selectedTagIndex];
          visibleTasks =
              visibleTasks.where((task) {
                // Check if task has a tag that matches the selected label
                return task.tags.any((tag) => tag.label == selectedTagLabel);
              }).toList();
        }

        // --- 3. SPLIT BY DATE (Using the filtered list) ---
        final todayTasks = _filterTasksByDate(visibleTasks, 0);
        final tomorrowTasks = _filterTasksByDate(visibleTasks, 1);
        final laterTasks = _filterTasksByDate(visibleTasks, 2);

        return Scaffold(
          backgroundColor:
              AppColors.lightBackground, // Or use Theme.of(context)
          appBar: AppBar(
            backgroundColor: AppColors.lightBackground,
            elevation: 0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tasks', style: TextStyle(color: Colors.black)),
                    Text(
                      'You have $totalTasks tasks',
                      style: TextStyle(color: Colors.black54, fontSize: 12.sp),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.filter_list_rounded,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 70),
            child: FloatingActionButton(
              onPressed: () {
                // In TasksScreen.dart
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true, // REQUIRED
                  backgroundColor: Colors.transparent,
                  builder:
                      (_) => BlocProvider.value(
                        value: context.read<TasksCubit>(),
                        child: const AddTaskBottomSheet(),
                      ),
                );
              },
              backgroundColor: AppColors.primary,
              elevation: 5,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),

                  // 1. Progress Card (Dynamic Data passed)
                  _buildProgressCard(progressValue, progressPercent),

                  SizedBox(height: 24.h),

                  // 2. Filter Chips
                  SizedBox(
                    height: 40.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filterTags.length,
                      separatorBuilder: (_, __) => SizedBox(width: 10.w),
                      itemBuilder: (context, index) {
                        final isSelected = _selectedTagIndex == index;
                        return GestureDetector(
                          onTap:
                              () => setState(() => _selectedTagIndex = index),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? AppColors.primary
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? AppColors.primary
                                        : Colors.black12,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _filterTags[index],
                                style: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                  fontSize: 14.sp,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // 3. Task List Content
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (state.status == TasksStatus.loading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state.status == TasksStatus.failure) {
                          return Center(child: Text(state.errorMessage));
                        } else if (visibleTasks.isEmpty) {
                          return const Center(
                            child: Text(
                              "No tasks found",
                              style: TextStyle(color: Colors.black54),
                            ),
                          );
                        }

                        return ListView(
                          physics: const BouncingScrollPhysics(),
                          children: [
                            if (todayTasks.isNotEmpty) ...[
                              _buildSectionHeader("Today"),
                              ...todayTasks.map(
                                (t) => _buildTaskItem(context, t),
                              ),
                            ],
                            if (tomorrowTasks.isNotEmpty) ...[
                              SizedBox(height: 20.h),
                              _buildSectionHeader("Tomorrow"),
                              ...tomorrowTasks.map(
                                (t) => _buildTaskItem(context, t),
                              ),
                            ],
                            if (laterTasks.isNotEmpty) ...[
                              SizedBox(height: 20.h),
                              _buildSectionHeader("Later"),
                              ...laterTasks.map(
                                (t) => _buildTaskItem(context, t),
                              ),
                            ],
                            SizedBox(height: 80.h),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Helpers ---

  // Updated to accept data
  Widget _buildProgressCard(double progressValue, int percentage) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.lightBackground,
            AppColors.lightBackground.withOpacity(0.9),
          ], // Assuming dark logic, adjust for light
          // For Light theme specific:
          // colors: [Colors.deepPurple.shade900, Colors.deepPurple.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Overall Progress",
                style: TextStyle(color: Colors.black, fontSize: 16.sp),
              ),
              Text(
                "$percentage%", // Dynamic percentage
                style: TextStyle(color: Colors.black, fontSize: 14.sp),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          LinearProgressIndicator(
            value: progressValue, // Dynamic value (0.0 to 1.0)
            backgroundColor: Colors.white10,
            color: AppColors.primary,
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
        final updated = task.copyWith(isDone: val);
        context.read<TasksCubit>().updateTask(updated);
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, left: 4.w),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Helper to split lists (0=Today, 1=Tomorrow, 2=Later)
  List<TaskEntity> _filterTasksByDate(List<TaskEntity> tasks, int type) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return tasks.where((t) {
      final tDate = DateTime(t.date.year, t.date.month, t.date.day);
      if (type == 0) return tDate.isAtSameMomentAs(today);
      if (type == 1) return tDate.isAtSameMomentAs(tomorrow);
      return tDate.isAfter(tomorrow);
    }).toList();
  }
}
