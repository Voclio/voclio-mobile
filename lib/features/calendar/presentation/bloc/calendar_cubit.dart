import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:translator/translator.dart';
import '../../domain/entities/calendar_month_entity.dart';
import '../../domain/entities/google_calendar_entity.dart';
import '../../domain/usecases/calendar_usecases.dart';
import '../../data/datasources/calendar_remote_datasource.dart';
import 'calendar_state.dart';

class CalendarCubit extends Cubit<CalendarState> {
  final GetCalendarMonthUseCase getCalendarMonthUseCase;
  final CalendarRemoteDataSource? calendarDataSource;
  final GoogleTranslator _translator = GoogleTranslator();

  // In-memory cache for translations to avoid redundant API calls
  static final Map<String, String> _translationCache = {};
  
  // Cached Google Calendar status
  GoogleCalendarStatusEntity? _googleStatus;
  List<GoogleCalendarEventEntity> _todayMeetings = [];
  
  // Cached Webex status
  WebexStatusEntity? _webexStatus;
  List<WebexMeetingEntity> _todayWebexMeetings = [];

  CalendarCubit({
    required this.getCalendarMonthUseCase,
    this.calendarDataSource,
  }) : super(CalendarInitial());

  /// Get current Google Calendar status
  GoogleCalendarStatusEntity? get googleStatus => _googleStatus;
  
  /// Get current Webex status
  WebexStatusEntity? get webexStatus => _webexStatus;
  
  /// Check if Google Calendar is connected
  bool get isGoogleConnected => _googleStatus?.connected ?? false;
  
  /// Check if Webex is connected
  bool get isWebexConnected => _webexStatus?.connected ?? false;

  Future<void> loadMonth(int year, int month) async {
    emit(CalendarLoading());
    
    // Load Google Calendar and Webex status in parallel
    await Future.wait([
      _loadGoogleStatus(),
      _loadWebexStatus(),
    ]);
    
    final result = await getCalendarMonthUseCase(year, month);
    result.fold((failure) => emit(CalendarError(message: failure.toString())), (
      monthData,
    ) async {
      try {
        final translatedData = await _translateMonthData(monthData);
        emit(CalendarLoaded(
          monthData: translatedData,
          googleStatus: _googleStatus,
          webexStatus: _webexStatus,
          todayMeetings: _todayMeetings,
          todayWebexMeetings: _todayWebexMeetings,
        ));
      } catch (e) {
        // Fallback to original data if translation fails
        emit(CalendarLoaded(
          monthData: monthData,
          googleStatus: _googleStatus,
          webexStatus: _webexStatus,
          todayMeetings: _todayMeetings,
          todayWebexMeetings: _todayWebexMeetings,
        ));
      }
    });
  }

  /// Load Google Calendar connection status
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

  /// Check Google Calendar connection status
  Future<void> checkGoogleCalendarStatus() async {
    if (calendarDataSource == null) return;
    
    try {
      _googleStatus = await calendarDataSource!.getGoogleCalendarStatus();
      
      if (state is CalendarLoaded) {
        final currentState = state as CalendarLoaded;
        emit(CalendarLoaded(
          monthData: currentState.monthData,
          googleStatus: _googleStatus,
          webexStatus: _webexStatus,
          todayMeetings: _todayMeetings,
          todayWebexMeetings: _todayWebexMeetings,
        ));
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Get Google Calendar OAuth URL for connection
  Future<GoogleOAuthUrlEntity?> getGoogleConnectUrl({bool isMobile = true}) async {
    if (calendarDataSource == null) return null;
    
    try {
      return await calendarDataSource!.getGoogleConnectUrl(
        isMobile: isMobile,
        customScheme: 'com.voclio.app',
      );
    } catch (e) {
      return null;
    }
  }

  /// Disconnect Google Calendar
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
      
      // Reload current month data
      if (state is CalendarLoaded) {
        final currentState = state as CalendarLoaded;
        loadMonth(currentState.monthData.year, currentState.monthData.month);
      }
    } catch (e) {
      emit(CalendarError(message: 'Failed to disconnect Google Calendar'));
    }
  }

  /// Handle OAuth callback from mobile
  Future<void> handleOAuthCallback(String code) async {
    if (calendarDataSource == null) return;
    
    emit(GoogleCalendarConnecting());
    
    try {
      await calendarDataSource!.handleMobileCallback(code, 'com.voclio.app');
      _googleStatus = await calendarDataSource!.getGoogleCalendarStatus();
      
      emit(const GoogleCalendarConnected(message: 'Google Calendar connected successfully!'));
      
      // Reload calendar data
      if (state is CalendarLoaded) {
        final currentState = state as CalendarLoaded;
        loadMonth(currentState.monthData.year, currentState.monthData.month);
      }
    } catch (e) {
      emit(CalendarError(message: 'Failed to connect Google Calendar'));
    }
  }

  /// Get today's meetings from Google Calendar
  Future<List<GoogleCalendarEventEntity>> getTodayMeetings() async {
    if (calendarDataSource == null || !isGoogleConnected) return [];
    
    try {
      _todayMeetings = await calendarDataSource!.getTodayMeetings();
      return _todayMeetings;
    } catch (e) {
      return [];
    }
  }

  /// Get upcoming meetings from Google Calendar
  Future<List<GoogleCalendarEventEntity>> getUpcomingMeetings({int days = 7}) async {
    if (calendarDataSource == null || !isGoogleConnected) return [];
    
    try {
      return await calendarDataSource!.getUpcomingMeetings(days: days);
    } catch (e) {
      return [];
    }
  }

  // ========== Webex Calendar Methods ==========

  /// Load Webex connection status
  Future<void> _loadWebexStatus() async {
    if (calendarDataSource == null) return;
    
    try {
      _webexStatus = await calendarDataSource!.getWebexStatus();
      if (_webexStatus?.connected == true) {
        _todayWebexMeetings = await calendarDataSource!.getWebexTodayMeetings();
      }
    } catch (e) {
      _webexStatus = null;
    }
  }

  /// Check Webex connection status
  Future<void> checkWebexStatus() async {
    if (calendarDataSource == null) return;
    
    try {
      _webexStatus = await calendarDataSource!.getWebexStatus();
      
      if (state is CalendarLoaded) {
        final currentState = state as CalendarLoaded;
        emit(CalendarLoaded(
          monthData: currentState.monthData,
          googleStatus: _googleStatus,
          webexStatus: _webexStatus,
          todayMeetings: _todayMeetings,
          todayWebexMeetings: _todayWebexMeetings,
        ));
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Get Webex OAuth URL for connection
  Future<GoogleOAuthUrlEntity?> getWebexConnectUrl() async {
    if (calendarDataSource == null) return null;
    
    try {
      return await calendarDataSource!.getWebexAuthUrl();
    } catch (e) {
      return null;
    }
  }

  /// Disconnect Webex
  Future<void> disconnectWebex() async {
    if (calendarDataSource == null) return;
    
    try {
      await calendarDataSource!.disconnectWebex();
      _webexStatus = const WebexStatusEntity(connected: false);
      _todayWebexMeetings = [];
      
      emit(WebexDisconnected());
      
      // Reload current month data
      if (state is CalendarLoaded) {
        final currentState = state as CalendarLoaded;
        loadMonth(currentState.monthData.year, currentState.monthData.month);
      }
    } catch (e) {
      emit(CalendarError(message: 'Failed to disconnect Webex'));
    }
  }

  /// Get today's Webex meetings
  Future<List<WebexMeetingEntity>> getTodayWebexMeetings() async {
    if (calendarDataSource == null || !isWebexConnected) return [];
    
    try {
      _todayWebexMeetings = await calendarDataSource!.getWebexTodayMeetings();
      return _todayWebexMeetings;
    } catch (e) {
      return [];
    }
  }

  /// Get upcoming Webex meetings
  Future<List<WebexMeetingEntity>> getUpcomingWebexMeetings({int days = 7}) async {
    if (calendarDataSource == null || !isWebexConnected) return [];
    
    try {
      return await calendarDataSource!.getWebexMeetings(days: days);
    } catch (e) {
      return [];
    }
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
      googleEvents: dayEvents.googleEvents,
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

        emit(CalendarLoaded(
          monthData: updatedMonthData,
          googleStatus: currentState.googleStatus,
          webexStatus: currentState.webexStatus,
          todayMeetings: currentState.todayMeetings,
          todayWebexMeetings: currentState.todayWebexMeetings,
        ));
      }
    }
  }
}
