import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:translator/translator.dart';
import '../../domain/entities/calendar_month_entity.dart';
import '../../domain/usecases/calendar_usecases.dart';
import 'calendar_state.dart';

class CalendarCubit extends Cubit<CalendarState> {
  final GetCalendarMonthUseCase getCalendarMonthUseCase;
  final GoogleTranslator _translator = GoogleTranslator();

  // In-memory cache for translations to avoid redundant API calls
  static final Map<String, String> _translationCache = {};

  CalendarCubit({required this.getCalendarMonthUseCase})
    : super(CalendarInitial());

  Future<void> loadMonth(int year, int month) async {
    emit(CalendarLoading());
    final result = await getCalendarMonthUseCase(year, month);
    result.fold((failure) => emit(CalendarError(message: failure.toString())), (
      monthData,
    ) async {
      try {
        final translatedData = await _translateMonthData(monthData);
        emit(CalendarLoaded(monthData: translatedData));
      } catch (e) {
        // Fallback to original data if translation fails
        emit(CalendarLoaded(monthData: monthData));
      }
    });
  }

  Future<CalendarMonthEntity> _translateMonthData(
    CalendarMonthEntity data,
  ) async {
    final Map<int, DayEventsEntity> translatedEvents = {};

    // Process all days in parallel
    final dayKeys = data.eventsByDay.keys.toList();
    await Future.wait(
      dayKeys.map((day) async {
        translatedEvents[day] = await _translateDayEvents(
          data.eventsByDay[day]!,
        );
      }),
    );

    return CalendarMonthEntity(
      year: data.year,
      month: data.month,
      monthName: data.monthName,
      daysInMonth: data.daysInMonth,
      eventsByDay: translatedEvents,
      totalEvents: data.totalEvents,
      tasksCount: data.tasksCount,
      remindersCount: data.remindersCount,
    );
  }

  Future<DayEventsEntity> _translateDayEvents(DayEventsEntity dayEvents) async {
    final translatedTasks = await Future.wait(
      dayEvents.tasks.map((task) async {
        String title = task.title;
        if (_isArabic(title)) {
          title = await _getCachedOrTranslate(title);
        }
        return CalendarTaskEntity(
          id: task.id,
          title: title,
          priority: task.priority,
          status: task.status,
          dueDate: task.dueDate,
        );
      }),
    );

    final translatedReminders = await Future.wait(
      dayEvents.reminders.map((reminder) async {
        String title = reminder.title;
        if (_isArabic(title)) {
          title = await _getCachedOrTranslate(title);
        }
        return CalendarReminderEntity(
          id: reminder.id,
          title: title,
          reminderTime: reminder.reminderTime,
        );
      }),
    );

    return DayEventsEntity(
      tasks: translatedTasks,
      reminders: translatedReminders,
      count: dayEvents.count,
    );
  }

  Future<String> _getCachedOrTranslate(String text) async {
    if (_translationCache.containsKey(text)) {
      return _translationCache[text]!;
    }

    try {
      final translated = await _translator.translate(
        text,
        from: 'ar',
        to: 'en',
      );
      _translationCache[text] = translated.text;
      return translated.text;
    } catch (e) {
      return text;
    }
  }

  bool _isArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  void toggleTaskStatus(int taskId, int day) {
    if (state is CalendarLoaded) {
      final currentData = (state as CalendarLoaded).monthData;
      final dayEvents = currentData.eventsByDay[day];

      if (dayEvents != null) {
        final updatedTasks =
            dayEvents.tasks.map((task) {
              if (task.id == taskId) {
                final newStatus = task.isCompleted ? 'pending' : 'completed';
                return task.copyWith(status: newStatus);
              }
              return task;
            }).toList();

        final updatedDayEvents = DayEventsEntity(
          tasks: updatedTasks,
          reminders: dayEvents.reminders,
          count: dayEvents.count,
        );

        final updatedEventsByDay = Map<int, DayEventsEntity>.from(
          currentData.eventsByDay,
        );
        updatedEventsByDay[day] = updatedDayEvents;

        final updatedMonthData = CalendarMonthEntity(
          year: currentData.year,
          month: currentData.month,
          monthName: currentData.monthName,
          daysInMonth: currentData.daysInMonth,
          eventsByDay: updatedEventsByDay,
          totalEvents: currentData.totalEvents,
          tasksCount: currentData.tasksCount,
          remindersCount: currentData.remindersCount,
        );

        emit(CalendarLoaded(monthData: updatedMonthData));
      }
    }
  }
}
