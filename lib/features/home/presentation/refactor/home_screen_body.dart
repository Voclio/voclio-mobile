import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:voclio_app/features/home/presentation/widgets/home_list_tile.dart';
import 'package:voclio_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:voclio_app/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:voclio_app/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:voclio_app/features/dashboard/domain/entities/dashboard_stats_entity.dart'
    as dashboard;
import 'package:voclio_app/core/widgets/home_system/home_system_tokens.dart';
import 'package:voclio_app/features/productivity/presentation/widgets/ai_suggestions_widget.dart';
import 'package:voclio_app/features/notes/presentation/bloc/notes_cubit.dart';
import 'package:voclio_app/features/tasks/presentation/bloc/tasks_cubit.dart';
import 'package:voclio_app/features/tasks/presentation/bloc/tasks_state.dart';
import 'package:voclio_app/features/tasks/domain/entities/task_entity.dart'
    as task_entities;
import 'package:voclio_app/features/calendar/presentation/bloc/calendar_cubit.dart';
import 'package:voclio_app/features/productivity/presentation/bloc/ai_suggestions_cubit.dart';
import 'package:voclio_app/features/widget_config/domain/entities/widget_preference.dart';
import 'package:voclio_app/features/widget_config/presentation/bloc/widget_config_cubit.dart';
import 'package:voclio_app/features/widget_config/presentation/bloc/widget_config_state.dart';
import 'package:voclio_app/features/widget_config/presentation/widgets/home_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:voclio_app/core/routes/App_routes.dart';
import 'package:voclio_app/core/icons/app_icons.dart';

class HomeScreenBody extends StatefulWidget {
  final Function(int)? onTabChange;
  const HomeScreenBody({super.key, this.onTabChange});

  @override
  State<HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<HomeScreenBody> {
  final PageController _bannerController = PageController();
  Timer? _bannerTimer;
  int _bannerIndex = 0;

  static const _bannerImages = [
    'assets/images/hero1.png',
    'assets/images/hero2.png',
    'assets/images/hero3.png',
    'assets/images/hero4.png',
  ];

  @override
  void initState() {
    super.initState();

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess || authState is ProfileUpdateError) {
      context.read<AuthBloc>().add(const GetProfileEvent());
    }

    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_bannerController.hasClients) return;
      final next = (_bannerIndex + 1) % _bannerImages.length;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });

    final now = DateTime.now();
    unawaited(
      Future.wait([
        context.read<DashboardCubit>().loadDashboardStats(),
        GetIt.I<TasksCubit>().init(),
        GetIt.I<NotesCubit>().init(),
        context.read<CalendarCubit>().loadMonth(now.year, now.month),
        context.read<AiSuggestionsCubit>().loadAiSuggestions(),
      ]),
    );
  }

  Future<void> _onRefresh() async {
    final now = DateTime.now();
    await Future.wait([
      context.read<DashboardCubit>().refresh(),
      GetIt.I<TasksCubit>().init(),
      GetIt.I<NotesCubit>().init(),
      context.read<CalendarCubit>().loadMonth(now.year, now.month),
      context.read<AiSuggestionsCubit>().loadAiSuggestions(),
    ]);
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: HomeSystemTokens.canvas,
      child: SafeArea(
        bottom: false,
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            final stats = state is DashboardStatsLoaded ? state.stats : null;
            final overview = stats?.overview;
            final upcoming = stats?.upcomingTasks;

            return RefreshIndicator(
              color: HomeSystemTokens.purple,
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HomeListTile(),
                  SizedBox(height: 16.h),
                  _buildHeroBanner(),
                  SizedBox(height: 20.h),
                  _buildStatsRow(overview, stats?.productivity),
                  SizedBox(height: 24.h),
                  _buildConfiguredSections(upcoming),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildConfiguredSections(List<dashboard.TaskEntity>? upcoming) {
    return BlocBuilder<WidgetConfigCubit, WidgetConfigState>(
      builder: (context, widgetState) {
        if (widgetState.status == WidgetConfigStatus.loading) {
          return const SizedBox.shrink();
        }

        final enabled = widgetState.enabledWidgets;
        final sections = enabled.isEmpty
            ? _defaultHomeSections(upcoming)
            : enabled
                .map((config) => _sectionForWidgetType(config.type, upcoming))
                .toList();

        return BlocProvider<TasksCubit>.value(
          value: GetIt.I<TasksCubit>(),
          child: Column(
            children: [
              for (var i = 0; i < sections.length; i++) ...[
                if (i > 0) SizedBox(height: 20.h),
                sections[i],
              ],
            ],
          ),
        );
      },
    );
  }

  List<Widget> _defaultHomeSections(List<dashboard.TaskEntity>? upcoming) {
    return [
      _buildTodaysFocus(),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: const AiSuggestionsWidget(),
      ),
      _buildUpcoming(upcoming),
    ];
  }

  Widget _sectionForWidgetType(
    WidgetType type,
    List<dashboard.TaskEntity>? upcoming,
  ) {
    switch (type) {
      case WidgetType.todayTasks:
        return _buildTodaysFocus();
      case WidgetType.upcomingTasks:
        return _buildUpcoming(upcoming);
      case WidgetType.productivity:
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: const AiSuggestionsWidget(),
        );
      case WidgetType.calendar:
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: CalendarWidget(onViewAll: () => widget.onTabChange?.call(2)),
        );
      case WidgetType.notes:
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: RecentNotesWidget(onViewAll: () => widget.onTabChange?.call(3)),
        );
      case WidgetType.reminders:
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: RemindersWidget(
            onViewAll: () => context.push(AppRouter.reminders),
          ),
        );
      case WidgetType.quickActions:
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: QuickActionsWidget(onTabChange: widget.onTabChange),
        );
    }
  }

  Widget _buildHeroBanner() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: SizedBox(
              height: 150.h,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _bannerController,
                    onPageChanged: (i) => setState(() => _bannerIndex = i),
                    itemCount: _bannerImages.length,
                    itemBuilder: (_, index) {
                      return Image.asset(
                        _bannerImages[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: HomeSystemTokens.purple.withValues(alpha: 0.08),
                          child: Icon(AppIcons.image_outlined, color: HomeSystemTokens.purple, size: 40.sp),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 60.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.35)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_bannerImages.length, (i) {
              final active = i == _bannerIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                width: active ? 18.w : 6.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: active ? HomeSystemTokens.purple : const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(
    dashboard.DashboardOverview? overview,
    dashboard.ProductivityStats? productivity,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              icon: AppIcons.assignment_outlined,
              color: HomeSystemTokens.purple,
              label: 'Tasks',
              value: overview?.totalTasks.toString() ?? '—',
              subtitle: '${overview?.completedTasks ?? 0} done today',
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _SummaryCard(
              icon: AppIcons.notes_rounded,
              color: HomeSystemTokens.blue,
              label: 'Notes',
              value: overview?.totalNotes.toString() ?? '—',
              subtitle: 'All your notes',
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _SummaryCard(
              icon: AppIcons.local_fire_department_rounded,
              color: HomeSystemTokens.orange,
              label: 'Streak',
              value: productivity?.currentStreak.toString() ?? '—',
              subtitle: 'Days',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysFocus() {
    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, taskState) {
        final today = DateTime.now();
        final tasks = taskState.tasks
            .where(
              (t) =>
                  t.date.year == today.year &&
                  t.date.month == today.month &&
                  t.date.day == today.day,
            )
            .take(5)
            .toList();

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
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
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: HomeSystemTokens.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(AppIcons.calendar_today_rounded,
                          color: HomeSystemTokens.purple, size: 18.sp),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Today's Focus",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          Text(
                            '${tasks.length} tasks scheduled',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => widget.onTabChange?.call(1),
                      child: Row(
                        children: [
                          Text(
                            'View all',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: HomeSystemTokens.purple,
                            ),
                          ),
                          Icon(AppIcons.chevron_right_rounded,
                              color: HomeSystemTokens.purple, size: 18.sp),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                if (taskState.status == TasksStatus.loading && tasks.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Center(
                      child: SizedBox(
                        width: 22.w,
                        height: 22.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: HomeSystemTokens.purple,
                        ),
                      ),
                    ),
                  )
                else if (tasks.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Text(
                      'No tasks scheduled for today',
                      style: TextStyle(
                          fontSize: 13.sp, color: const Color(0xFF9CA3AF)),
                    ),
                  )
                else
                  ...List.generate(tasks.length, (index) {
                    final task = tasks[index];
                    final isLast = index == tasks.length - 1;
                    return _FocusTaskRow(
                      task: task,
                      isLast: isLast,
                    );
                  }),
                SizedBox(height: 8.h),
                GestureDetector(
                  onTap: () => widget.onTabChange?.call(1),
                  child: Text(
                    '+ Add task',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: HomeSystemTokens.purple,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUpcoming(List<dashboard.TaskEntity>? tasks) {
    final upcoming = tasks?.where((t) {
      if (t.dueDate == null) return false;
      return !t.dueDate!.isBefore(DateTime.now());
    }).toList();

    final next = upcoming != null && upcoming.isNotEmpty ? upcoming.first : null;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
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
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: HomeSystemTokens.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(AppIcons.event_rounded, color: HomeSystemTokens.orange, size: 18.sp),
                ),
                SizedBox(width: 10.w),
                Text(
                  'Upcoming',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => widget.onTabChange?.call(2),
                  child: Row(
                    children: [
                      Text(
                        'View all',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: HomeSystemTokens.orange,
                        ),
                      ),
                      Icon(AppIcons.chevron_right_rounded, color: HomeSystemTokens.orange, size: 18.sp),
                    ],
                  ),
                ),
              ],
            ),
            if (next != null) ...[
              SizedBox(height: 16.h),
              _UpcomingRow(task: next),
            ] else
              Padding(
                padding: EdgeInsets.only(top: 16.h),
                child: Text(
                  'No upcoming events',
                  style: TextStyle(fontSize: 13.sp, color: const Color(0xFF9CA3AF)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String subtitle;

  const _SummaryCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 100.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(5.w),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, color: color, size: 14.sp),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                  height: 1,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10.sp,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
  }
}

class _FocusTaskRow extends StatelessWidget {
  final task_entities.TaskEntity task;
  final bool isLast;

  const _FocusTaskRow({
    required this.task,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final tagLabel = task.tags.isNotEmpty
        ? task.tags.first
        : task.priority.displayName;
    final tagColor = task.priority.color;
    final time = DateFormat('h:mm a').format(task.date);
    final isDone = task.isDone;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28.w,
            child: Column(
              children: [
                Container(
                  width: 22.r,
                  height: 22.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDone ? const Color(0xFF34C759) : const Color(0xFFD1D5DB),
                      width: 2,
                    ),
                    color: isDone ? const Color(0xFF34C759) : Colors.transparent,
                  ),
                  child: isDone
                      ? Icon(AppIcons.check, size: 14.sp, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: EdgeInsets.symmetric(vertical: 4.h),
                      color: const Color(0xFFE5E7EB),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20.h),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: isDone
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF111827),
                            decoration: isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: tagColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                tagLabel,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: tagColor,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Icon(
                              AppIcons.schedule_rounded,
                              size: 13.sp,
                              color: const Color(0xFF9CA3AF),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              time,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    AppIcons.flag_outlined,
                    size: 18.sp,
                    color: tagColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  final dashboard.TaskEntity task;

  const _UpcomingRow({required this.task});

  String _daysLabel(DateTime date) {
    final diff = date.difference(DateTime.now()).inDays;
    if (diff <= 0) return 'Today';
    if (diff == 1) return 'In 1 day';
    return 'In $diff days';
  }

  @override
  Widget build(BuildContext context) {
    final due = task.dueDate ?? DateTime.now();
    final dateStr = DateFormat('MMM d, yyyy • h:mm a').format(due);

    return Row(
      children: [
        Container(
          width: 40.r,
          height: 40.r,
          decoration: BoxDecoration(
            color: const Color(0xFFFF9500).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            AppIcons.event_available_rounded,
            color: const Color(0xFFFF9500),
            size: 20.sp,
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
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFF9500).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            _daysLabel(due),
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFF9500),
            ),
          ),
        ),
      ],
    );
  }
}
