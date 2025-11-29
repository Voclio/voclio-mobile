import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart'; // Import GetIt

import 'package:voclio_app/features/tasks/domain/entities/task_entity.dart';
import 'package:voclio_app/features/tasks/presentation/bloc/tasks_state.dart';
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
  final List<String> _filterTags = [
    'All',
    'Study',
    'Work',
    'Health',
    'Personal',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tasks', style: TextStyle(color: Colors.black)),
                Text(
                  'You have 3 tasks today',
                  style: TextStyle(color: Colors.black54, fontSize: 12.sp),
                ),
              ],
            ),
            IconButton(onPressed: () {}, icon: Icon(Icons.filter_list_rounded)),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),

              // 1. Progress Card (Static for now, dynamic later)
              _buildProgressCard(),

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
                      onTap: () => setState(() => _selectedTagIndex = index),
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
                                isSelected ? AppColors.primary : Colors.white24,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _filterTags[index],
                            style: TextStyle(
                              color: Colors.black,
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

              // 3. Task List (BlocConsumer)
              Expanded(
                child: BlocBuilder<TasksCubit, TasksState>(
                  builder: (context, state) {
                    if (state.status == TasksStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state.status == TasksStatus.failure) {
                      return Center(
                        child: Text(
                          state.errorMessage,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    } else if (state.tasks.isEmpty) {
                      return const Center(
                        child: Text(
                          "No tasks found",
                          style: TextStyle(color: Colors.white54),
                        ),
                      );
                    }

                    // Group Tasks Logic
                    final tasks = state.tasks;
                    // Note: You would filter by _selectedTagIndex here in a real app

                    final todayTasks = _filterTasksByDate(tasks, 0);
                    final tomorrowTasks = _filterTasksByDate(tasks, 1);
                    final laterTasks = _filterTasksByDate(tasks, 2);

                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        if (todayTasks.isNotEmpty) ...[
                          _buildSectionHeader("Today"),
                          ...todayTasks.map((t) => _buildTaskItem(context, t)),
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
                          ...laterTasks.map((t) => _buildTaskItem(context, t)),
                        ],
                        SizedBox(height: 80.h), // Space for FAB
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Task',

        onPressed: () {
          // Navigate to Add Task Screen (Todo later)
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  // --- Helpers ---

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
        // Call Cubit
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

  Widget _buildProgressCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.lightCard, AppColors.lightCard.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
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
                "20%",
                style: TextStyle(color: Colors.black38, fontSize: 14.sp),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          LinearProgressIndicator(
            value: 0.2, // dynamic in future
            backgroundColor: Colors.white10,
            color: AppColors.primary,
            minHeight: 8.h,
            borderRadius: BorderRadius.circular(10.r),
          ),
        ],
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
