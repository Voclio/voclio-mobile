import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/calendar_month_entity.dart';
import '../../domain/entities/google_calendar_entity.dart';
import 'package:voclio_app/core/config/oauth_config.dart';
import '../../domain/usecases/calendar_usecases.dart';
import '../../data/datasources/calendar_remote_datasource.dart';
import 'calendar_state.dart';

class CalendarCubit extends Cubit<CalendarState> {
  final GetCalendarMonthUseCase getCalendarMonthUseCase;
  final CalendarRemoteDataSource? calendarDataSource;

  GoogleCalendarStatusEntity? _googleStatus;
  List<GoogleCalendarEventEntity> _todayMeetings = [];

  CalendarCubit({
    required this.getCalendarMonthUseCase,
    this.calendarDataSource,
  }) : super(CalendarInitial());

  GoogleCalendarStatusEntity? get googleStatus => _googleStatus;

  bool get isGoogleConnected => _googleStatus?.connected ?? false;

  Future<void> loadMonth(int year, int month, {bool force = false}) async {
    if (!force && state is CalendarLoaded) {
      final loaded = state as CalendarLoaded;
      if (loaded.monthData.year == year && loaded.monthData.month == month) {
        return;
      }
    }
    if (!force && state is CalendarLoading) return;

    emit(CalendarLoading());

    await _loadGoogleStatus();

    final result = await getCalendarMonthUseCase(year, month);
    result.fold(
      (failure) => emit(CalendarError(message: failure.toString())),
      (monthData) => emit(
        CalendarLoaded(
          monthData: monthData,
          googleStatus: _googleStatus,
          todayMeetings: _todayMeetings,
        ),
      ),
    );
  }

  Future<void> _loadGoogleStatus() async {
    if (calendarDataSource == null) return;

    try {
      _googleStatus = await calendarDataSource!.getGoogleCalendarStatus();
      if (_googleStatus?.connected == true) {
        _todayMeetings = await calendarDataSource!.getTodayMeetings();
      }
    } catch (e) {
      _googleStatus = null;
    }
  }

  Future<void> checkGoogleCalendarStatus() async {
    if (calendarDataSource == null) return;

    try {
      _googleStatus = await calendarDataSource!.getGoogleCalendarStatus();

      if (state is CalendarLoaded) {
        final currentState = state as CalendarLoaded;
        emit(
          CalendarLoaded(
            monthData: currentState.monthData,
            googleStatus: _googleStatus,
            todayMeetings: _todayMeetings,
          ),
        );
      }
    } catch (e) {
      // Silently fail
    }
  }

  Future<GoogleOAuthUrlEntity> getGoogleConnectUrl({
    bool isMobile = true,
  }) async {
    if (calendarDataSource == null) {
      throw StateError('Calendar API is not configured');
    }

    return calendarDataSource!.getGoogleConnectUrl(
      isMobile: isMobile,
      customScheme: OAuthConfig.calendarOAuthScheme,
    );
  }

  Future<void> disconnectGoogleCalendar() async {
    if (calendarDataSource == null) return;

    try {
      await calendarDataSource!.disconnectGoogleCalendar();
      _googleStatus = const GoogleCalendarStatusEntity(
        connected: false,
        syncEnabled: false,
        syncStatus: 'disconnected',
      );
      _todayMeetings = [];

      emit(GoogleCalendarDisconnected());

      if (state is CalendarLoaded) {
        final currentState = state as CalendarLoaded;
        loadMonth(currentState.monthData.year, currentState.monthData.month);
      }
    } catch (e) {
      emit(CalendarError(message: 'Failed to disconnect Google Calendar'));
    }
  }

  Future<void> handleOAuthCallback(String code) async {
    if (calendarDataSource == null) return;

    emit(GoogleCalendarConnecting());

    try {
      await calendarDataSource!.handleMobileCallback(
        code,
        OAuthConfig.calendarOAuthScheme,
      );
      _googleStatus = await calendarDataSource!.getGoogleCalendarStatus();

      emit(
        const GoogleCalendarConnected(
          message: 'Google Calendar connected successfully!',
        ),
      );

      if (state is CalendarLoaded) {
        final currentState = state as CalendarLoaded;
        loadMonth(currentState.monthData.year, currentState.monthData.month);
      }
    } catch (e) {
      emit(CalendarError(message: 'Failed to connect Google Calendar'));
    }
  }

  Future<List<GoogleCalendarEventEntity>> getTodayMeetings() async {
    if (calendarDataSource == null || !isGoogleConnected) return [];

    try {
      _todayMeetings = await calendarDataSource!.getTodayMeetings();
      return _todayMeetings;
    } catch (e) {
      return [];
    }
  }

  Future<List<GoogleCalendarEventEntity>> getUpcomingMeetings({
    int days = 7,
  }) async {
    if (calendarDataSource == null || !isGoogleConnected) return [];

    try {
      return await calendarDataSource!.getUpcomingMeetings(days: days);
    } catch (e) {
      return [];
    }
  }

  void toggleTaskStatus(int taskId, int day) {
    if (state is CalendarLoaded) {
      final currentState = state as CalendarLoaded;
      final currentData = currentState.monthData;
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
          googleEvents: dayEvents.googleEvents,
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
          googleEventsCount: currentData.googleEventsCount,
          googleSyncEnabled: currentData.googleSyncEnabled,
        );

        emit(
          CalendarLoaded(
            monthData: updatedMonthData,
            googleStatus: currentState.googleStatus,
            todayMeetings: currentState.todayMeetings,
          ),
        );
      }
    }
  }
}
