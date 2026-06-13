import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:voclio_app/core/domain/entities/tag_entity.dart';
import 'package:voclio_app/core/utils/date_time_utils.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_tokens.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_widgets.dart';

import 'package:voclio_app/features/tasks/domain/entities/task_entity.dart';
import 'package:voclio_app/features/tasks/presentation/bloc/tasks_state.dart';
import 'package:voclio_app/features/tasks/presentation/widgets/add_task_buttom_sheet.dart';
import 'package:voclio_app/features/tasks/presentation/screens/task_details_screen.dart';

import '../bloc/tasks_cubit.dart';
import '../widgets/task_tile.dart';
import 'package:voclio_app/core/icons/app_icons.dart';

int _taskCountForTag(TasksState state, String? tagName) {
  final source = state.allTasks.isNotEmpty ? state.allTasks : state.tasks;
  if (tagName == null) return source.length;
  return source.where((t) => t.tags.contains(tagName)).length;
}

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
    final cubit = context.read<TasksCubit>();
    if (cubit.state.status != TasksStatus.success) {
      cubit.init();
    }
  }

  void _showAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<TasksCubit>(),
        child: const AddTaskBottomSheet(),
      ),
    );
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

        final pendingTasks = totalTasks - completedTasks;

        return Scaffold(
          primary: false,
          backgroundColor: HomeSystemTokens.canvas,
          body: HomeCanvas(
            child: BlocListener<TasksCubit, TasksState>(
            listenWhen:
                (previous, current) => previous.status != current.status,
            listener: (context, state) {
              if (state.status == TasksStatus.failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage),
                    backgroundColor: theme.colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 90.h),
                  ),
                );
              }
            },
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.h),
                    HomeScreenHeader(
                      title: 'Tasks',
                      subtitle: '$totalTasks total · $pendingTasks remaining',
                      icon: AppIcons.task_alt_rounded,
                      accent: HomeSystemTokens.purple,
                      actions: [
                        HomeIconButton(
                          icon: AppIcons.add_rounded,
                          onTap: () => _showAddTaskSheet(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 18.h),
                    _buildProgressCard(context, progressValue, progressPercent),
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        Expanded(
                          child: HomeStatTile(
                            icon: AppIcons.pending_actions_rounded,
                            color: HomeSystemTokens.purple,
                            label: 'Pending',
                            value: pendingTasks.toString(),
                            subtitle: 'To complete',
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: HomeStatTile(
                            icon: AppIcons.check_circle_outline_rounded,
                            color: HomeSystemTokens.green,
                            label: 'Done',
                            value: completedTasks.toString(),
                            subtitle: 'Completed',
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: HomeStatTile(
                            icon: AppIcons.percent_rounded,
                            color: HomeSystemTokens.orange,
                            label: 'Progress',
                            value: '$progressPercent%',
                            subtitle: 'Overall',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    BlocBuilder<TasksCubit, TasksState>(
                      builder: (context, state) {
                        return SizedBox(
                          height: 32.h,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              HomeCountedFilterPill(
                                label: 'All',
                                count: _taskCountForTag(state, null),
                                selected: state.selectedTagName == null,
                                onTap: () => context
                                    .read<TasksCubit>()
                                    .filterByTag(null),
                              ),
                              ...state.availableTags.map(
                                (tag) => HomeCountedFilterPill(
                                  label: tag.name,
                                  count: _taskCountForTag(state, tag.name),
                                  selected: state.selectedTagName == tag.name,
                                  onTap: () => context
                                      .read<TasksCubit>()
                                      .filterByTag(tag.name),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16.h),

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
                            ),
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
                                  ...todayTasks.map(
                                    (task) => _buildTaskItem(
                                          context,
                                          task,
                                          state.availableTags,
                                        ),
                                  ),
                                ],
                                if (tomorrowTasks.isNotEmpty) ...[
                                  SizedBox(height: 20.h),
                                  _buildSectionHeader(context, "Tomorrow"),
                                  ...tomorrowTasks.map(
                                    (task) => _buildTaskItem(
                                          context,
                                          task,
                                          state.availableTags,
                                        ),
                                  ),
                                ],
                                if (laterTasks.isNotEmpty) ...[
                                  SizedBox(height: 20.h),
                                  _buildSectionHeader(context, "Later"),
                                  ...laterTasks.map(
                                    (task) => _buildTaskItem(
                                          context,
                                          task,
                                          state.availableTags,
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
    final isComplete = percentage == 100;
    final barColor =
        isComplete ? HomeSystemTokens.green : HomeSystemTokens.purple;

    return HomeSectionCard(
      padding: EdgeInsets.all(18.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: barColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  isComplete
                      ? AppIcons.celebration_rounded
                      : AppIcons.trending_up_rounded,
                  color: barColor,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isComplete ? 'All done for now' : 'Overall progress',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: HomeSystemTokens.ink,
                      ),
                    ),
                    Text(
                      isComplete
                          ? 'Great work — you cleared the list'
                          : 'Keep going, you are getting there',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: HomeSystemTokens.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: barColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 7.h,
              backgroundColor: barColor.withValues(alpha: 0.12),
              color: barColor,
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
    return HomeSectionTitle(title: title);
  }

  List<TaskEntity> _filterTasksByDate(List<TaskEntity> tasks, int type) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return tasks.where((t) {
      final tDate = DateTimeUtils.dateOnly(t.date);
      if (type == 0) {
        // Today section: include current day AND everything in the past (overdue)
        return tDate.isAtSameMomentAs(today) || tDate.isBefore(today);
      }
      if (type == 1) return tDate.isAtSameMomentAs(tomorrow);
      return tDate.isAfter(tomorrow);
    }).toList();
  }

  Widget _buildEmptyState(BuildContext context, String? selectedTagName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 112.r,
            height: 112.r,
            decoration: BoxDecoration(
              color: HomeSystemTokens.purple.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              AppIcons.task_alt_rounded,
              size: 52.sp,
              color: HomeSystemTokens.purple,
            ),
          ),
          SizedBox(height: 22.h),
          Text(
            selectedTagName != null
                ? 'No tasks in "$selectedTagName"'
                : 'No tasks yet',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: HomeSystemTokens.ink,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 36.w),
            child: Text(
              selectedTagName != null
                  ? 'Create a new task with this tag to see it here'
                  : 'Tap + to create your first task',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: HomeSystemTokens.inkMuted,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 28.h),
          ElevatedButton.icon(
            onPressed: () => _showAddTaskSheet(context),
            icon: Icon(AppIcons.add_rounded, size: 20.sp),
            label: Text(
              'Create Task',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: HomeSystemTokens.purple,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
