import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../bloc/calendar_cubit.dart';
import '../bloc/calendar_state.dart';

class MonthlyCalendarScreen extends StatefulWidget {
  const MonthlyCalendarScreen({super.key});

  @override
  State<MonthlyCalendarScreen> createState() => _MonthlyCalendarScreenState();
}

class _MonthlyCalendarScreenState extends State<MonthlyCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Calendar',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: BlocConsumer<CalendarCubit, CalendarState>(
        listener: (context, state) {
          if (state is CalendarLoaded) {
            final monthData = state.monthData;
            final today = DateTime.now();

            // Only try to auto-select if we are in the currently focused month
            if (monthData.year == _focusedDay.year &&
                monthData.month == _focusedDay.month) {
              // If today has events, keep today selected
              if (monthData.eventsByDay.containsKey(today.day)) {
                setState(() {
                  _selectedDay = DateTime(today.year, today.month, today.day);
                });
              } else {
                // Find the nearest upcoming day with events
                final eventDays = monthData.eventsByDay.keys.toList()..sort();
                final upcomingDay = eventDays.firstWhere(
                  (day) => day >= today.day,
                  orElse:
                      () => eventDays.isNotEmpty ? eventDays.first : today.day,
                );

                setState(() {
                  _selectedDay = DateTime(
                    monthData.year,
                    monthData.month,
                    upcomingDay,
                  );
                  // Also update focused day to the selected day if it's far away?
                  // No, TableCalendar handles focusedDay for the month view.
                });
              }
            }
          }
        },
        builder: (context, state) {
          if (state is CalendarLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CalendarError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(state.message, textAlign: TextAlign.center),
                  TextButton(
                    onPressed:
                        () => context.read<CalendarCubit>().loadMonth(
                          _focusedDay.year,
                          _focusedDay.month,
                        ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is CalendarLoaded) {
            final monthData = state.monthData;

            // Ensure _selectedDay is within the loaded month if we just switched pages
            final currentSelection = _selectedDay ?? _focusedDay;
            final effectiveSelection =
                (currentSelection.year == monthData.year &&
                        currentSelection.month == monthData.month)
                    ? currentSelection
                    : DateTime(monthData.year, monthData.month, 1);

            final selectedDayEvents =
                monthData.eventsByDay[effectiveSelection.day];

            return Column(
              children: [
                // Month/Year Display
                Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 10.h,
                      ),
                      child: Row(
                        children: [
                          Text(
                            DateFormat('MMMM yyyy').format(_focusedDay),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: -0.1, end: 0),

                // Calendar Container
                Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.white,
                        borderRadius: BorderRadius.circular(24.r),
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
                        calendarFormat: _calendarFormat,
                        selectedDayPredicate:
                            (day) => isSameDay(effectiveSelection, day),
                        eventLoader: (day) {
                          if (day.month != monthData.month) return [];
                          return monthData.eventsByDay[day.day]?.tasks ?? [];
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        onFormatChanged: (format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          setState(() {
                            _focusedDay = focusedDay;
                            _selectedDay =
                                null; // Reset selection so listener can pick the best day for the new month
                          });
                          context.read<CalendarCubit>().loadMonth(
                            focusedDay.year,
                            focusedDay.month,
                          );
                        },
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          todayTextStyle: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          markerDecoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          markersMaxCount: 1,
                          outsideDaysVisible: false,
                          defaultTextStyle: TextStyle(
                            color: theme.colorScheme.onSurface,
                          ),
                          weekendTextStyle: TextStyle(
                            color: theme.colorScheme.primary.withOpacity(0.7),
                          ),
                        ),
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(begin: const Offset(0.98, 0.98)),

                SizedBox(height: 20.h),

                // Selected Day info
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isSameDay(effectiveSelection, DateTime.now())
                            ? 'Today\'s Events'
                            : 'Events for ${DateFormat('MMM d').format(effectiveSelection)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                        ),
                      ),
                      if (selectedDayEvents != null &&
                          selectedDayEvents.count > 0)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            '${selectedDayEvents.count}',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                SizedBox(height: 12.h),

                // Events List
                Expanded(
                  child:
                      selectedDayEvents == null ||
                              (selectedDayEvents.tasks.isEmpty &&
                                  selectedDayEvents.reminders.isEmpty)
                          ? _buildEmptyState(
                            theme,
                            isDark,
                          ).animate().fadeIn(duration: 400.ms, delay: 300.ms)
                          : ListView(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            physics: const BouncingScrollPhysics(),
                            children: [
                              ...selectedDayEvents.tasks.map(
                                (task) => _buildEventCard(
                                  task.title,
                                  'Due: ${DateFormat('hh:mm a').format(task.dueDate)}',
                                  _getPriorityColor(task.priority),
                                  theme,
                                  isDark,
                                  Icons.task_alt_rounded,
                                ),
                              ),
                              ...selectedDayEvents.reminders.map(
                                (reminder) => _buildEventCard(
                                  reminder.title,
                                  'Reminder: ${DateFormat('hh:mm a').format(reminder.reminderTime)}',
                                  Colors.purple,
                                  theme,
                                  isDark,
                                  Icons.notifications_active_outlined,
                                ),
                              ),
                              SizedBox(height: 100.h), // Space for bottom nav
                            ],
                          ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: Padding(
            padding: EdgeInsets.only(bottom: 85.h),
            child: FloatingActionButton(
              onPressed: () {
                // TODO: Add event
              },
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          )
          .animate()
          .fadeIn(duration: 600.ms, delay: 500.ms)
          .scale(begin: const Offset(0.5, 0.5)),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
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
      ],
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  Widget _buildEventCard(
    String title,
    String time,
    Color color,
    ThemeData theme,
    bool isDark,
    IconData icon,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow:
            isDark
                ? []
                : [
                  BoxShadow(
                    color: color.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20.sp),
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
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: theme.colorScheme.secondary.withOpacity(0.3),
          ),
        ],
      ),
    );
  }
}
