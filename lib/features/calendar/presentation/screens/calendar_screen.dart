import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../tasks/domain/entities/task_entity.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Mock data - will be replaced with actual data from cubit
  final Map<DateTime, List<TaskEntity>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<TaskEntity> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _showDayEvents(DateTime day) {
    final events = _getEventsForDay(day);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEventBottomSheet(day, events),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(
              theme,
              isDark,
            ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),

            // Calendar
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildCalendar(theme, isDark)
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 200.ms)
                        .scale(begin: const Offset(0.95, 0.95)),

                    SizedBox(height: 20.h),

                    // Today's Events
                    _buildTodayEvents(theme, isDark)
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 400.ms)
                        .slideY(begin: 0.2, end: 0),

                    SizedBox(height: 100.h), // Space for bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 85.h),
        child: FloatingActionButton(
              onPressed: () {
                // Add new event with selected date
              },
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
            .animate()
            .fadeIn(duration: 600.ms, delay: 600.ms)
            .scale(begin: const Offset(0.5, 0.5)),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Calendar',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                DateFormat('MMMM yyyy').format(_focusedDay),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: IconButton(
              icon: Icon(Icons.today, color: theme.colorScheme.onSurface),
              onPressed: () {
                setState(() {
                  _focusedDay = DateTime.now();
                  _selectedDay = DateTime.now();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(ThemeData theme, bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow:
            isDark
                ? []
                : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: _calendarFormat,
        eventLoader: _getEventsForDay,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        calendarStyle: CalendarStyle(
          // Today
          todayDecoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
          // Selected
          selectedDecoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          // Default
          defaultTextStyle: TextStyle(color: theme.colorScheme.onSurface),
          weekendTextStyle: TextStyle(
            color: theme.colorScheme.primary.withOpacity(0.7),
          ),
          outsideTextStyle: TextStyle(
            color: theme.colorScheme.secondary.withOpacity(0.3),
          ),
          // Markers
          markerDecoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 3,
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: theme.colorScheme.onSurface,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: theme.colorScheme.onSurface,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.w600,
          ),
          weekendStyle: TextStyle(
            color: theme.colorScheme.primary.withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          _showDayEvents(selectedDay);
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }

  Widget _buildTodayEvents(ThemeData theme, bool isDark) {
    final todayEvents = _getEventsForDay(_selectedDay ?? DateTime.now());

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedDay != null && isSameDay(_selectedDay, DateTime.now())
                    ? 'Today\'s Events'
                    : 'Events for ${DateFormat('MMM d').format(_selectedDay ?? DateTime.now())}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (todayEvents.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${todayEvents.length}',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          todayEvents.isEmpty
              ? _buildEmptyState(theme, isDark)
              : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: todayEvents.length,
                itemBuilder: (context, index) {
                  return _buildEventCard(todayEvents[index], theme, isDark)
                      .animate(delay: (index * 100).ms)
                      .fadeIn(duration: 400.ms)
                      .slideX(begin: 0.2, end: 0);
                },
              ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(40.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 64.sp,
            color: theme.colorScheme.secondary.withOpacity(0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            'No events for this day',
            style: TextStyle(
              fontSize: 16.sp,
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tap the + button to add a new event',
            style: TextStyle(
              fontSize: 14.sp,
              color: theme.colorScheme.secondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(TaskEntity task, ThemeData theme, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: task.priority.color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow:
            isDark
                ? []
                : [
                  BoxShadow(
                    color: task.priority.color.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
      ),
      child: Row(
        children: [
          // Priority indicator
          Container(
            width: 4.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: task.priority.color,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 12.w),
          // Checkbox
          Container(
            width: 24.w,
            height: 24.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    task.isDone
                        ? theme.colorScheme.primary
                        : theme.colorScheme.secondary.withOpacity(0.3),
                width: 2,
              ),
              color:
                  task.isDone ? theme.colorScheme.primary : Colors.transparent,
            ),
            child:
                task.isDone
                    ? Icon(Icons.check, size: 16.sp, color: Colors.white)
                    : null,
          ),
          SizedBox(width: 12.w),
          // Task info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                    decoration: task.isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14.sp,
                      color: theme.colorScheme.secondary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      DateFormat('hh:mm a').format(task.date),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    if (task.tags.isNotEmpty) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: task.tags.first.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          task.tags.first.label,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: task.tags.first.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Priority badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: task.priority.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              task.priority.displayName,
              style: TextStyle(
                fontSize: 10.sp,
                color: task.priority.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventBottomSheet(DateTime day, List<TaskEntity> events) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 0.7.sh,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          // Handle
          SizedBox(height: 12.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 20.h),
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE').format(day),
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      DateFormat('MMMM d, yyyy').format(day),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${events.length} ${events.length == 1 ? 'event' : 'events'}',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Divider(
            height: 1,
            color: theme.colorScheme.secondary.withOpacity(0.1),
          ),
          // Events list
          Expanded(
            child:
                events.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy_outlined,
                            size: 64.sp,
                            color: theme.colorScheme.secondary.withOpacity(0.3),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No events for this day',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: EdgeInsets.all(20.r),
                      physics: const BouncingScrollPhysics(),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        return _buildEventCard(events[index], theme, isDark);
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
