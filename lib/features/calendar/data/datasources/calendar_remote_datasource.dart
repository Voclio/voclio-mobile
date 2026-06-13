import 'package:voclio_app/core/api/api_client.dart';
import 'package:voclio_app/core/api/api_endpoints.dart';
import '../models/calendar_month_model.dart';
import '../../domain/entities/google_calendar_entity.dart';

abstract class CalendarRemoteDataSource {
  Future<CalendarMonthModel> getCalendarMonth(int year, int month);
  Future<List<Map<String, dynamic>>> getCalendarEvents({
    String? startDate,
    String? endDate,
    bool includeGoogle = true,
  });
  Future<List<Map<String, dynamic>>> getDayEvents(String date);

  // Google Calendar APIs
  Future<GoogleCalendarStatusEntity> getGoogleCalendarStatus();
  Future<GoogleOAuthUrlEntity> getGoogleConnectUrl({
    bool isMobile = false,
    String? customScheme,
  });
  Future<void> disconnectGoogleCalendar();
  Future<List<GoogleCalendarEventEntity>> getGoogleCalendarEvents({
    String? startDate,
    String? endDate,
  });
  Future<List<GoogleCalendarEventEntity>> getTodayMeetings();
  Future<List<GoogleCalendarEventEntity>> getUpcomingMeetings({int days = 7});
  Future<void> linkOAuthSession(String sessionId);
  Future<void> handleMobileCallback(String code, String customScheme);
}

class CalendarRemoteDataSourceImpl implements CalendarRemoteDataSource {
  final ApiClient apiClient;

  CalendarRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<CalendarMonthModel> getCalendarMonth(int year, int month) async {
    final response = await apiClient.get(
      ApiEndpoints.calendarMonth(year, month),
    );
    return CalendarMonthModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<Map<String, dynamic>>> getCalendarEvents({
    String? startDate,
    String? endDate,
    bool includeGoogle = true,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.calendarEvents,
        queryParameters: {
          if (startDate != null) 'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
          'include_google': includeGoogle.toString(),
        },
      );

      final rawData = response.data;
      List<dynamic> eventsList = [];

      if (rawData is Map && rawData['data'] != null) {
        final data = rawData['data'];
        if (data is Map && data['events'] != null) {
          eventsList = data['events'];
        } else if (data is List) {
          eventsList = data;
        }
      } else if (rawData is List) {
        eventsList = rawData;
      }

      return eventsList.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch calendar events: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getDayEvents(String date) async {
    try {
      final response = await apiClient.get(ApiEndpoints.calendarDay(date));

      final rawData = response.data;
      List<dynamic> eventsList = [];

      if (rawData is Map && rawData['data'] != null) {
        final data = rawData['data'];
        if (data is Map && data['events'] != null) {
          eventsList = data['events'];
        } else if (data is List) {
          eventsList = data;
        }
      } else if (rawData is List) {
        eventsList = rawData;
      }

      return eventsList.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch day events: $e');
    }
  }

  // ========== Google Calendar Methods ==========

  @override
  Future<GoogleCalendarStatusEntity> getGoogleCalendarStatus() async {
    try {
      final response = await apiClient.get(ApiEndpoints.googleCalendarStatus);
      final data = response.data['data'] ?? response.data;

      return GoogleCalendarStatusEntity(
        connected: data['connected'] ?? false,
        syncEnabled: data['sync_enabled'] ?? false,
        syncStatus: data['sync_status'] ?? 'disconnected',
        calendarName: data['calendar_name'],
        lastSyncAt:
            data['last_sync_at'] != null
                ? DateTime.parse(data['last_sync_at'])
                : null,
        errorMessage: data['error_message'],
      );
    } catch (e) {
      // Return disconnected status if API fails
      return const GoogleCalendarStatusEntity(
        connected: false,
        syncEnabled: false,
        syncStatus: 'error',
        errorMessage: 'Failed to check Google Calendar status',
      );
    }
  }

  @override
  Future<GoogleOAuthUrlEntity> getGoogleConnectUrl({
    bool isMobile = false,
    String? customScheme,
  }) async {
    try {
      final endpoint =
          isMobile
              ? ApiEndpoints.googleCalendarConnectMobile
              : ApiEndpoints.googleCalendarConnect;

      final response = await apiClient.get(
        endpoint,
        queryParameters:
            isMobile && customScheme != null
                ? {'custom_scheme': customScheme}
                : null,
      );

      final data = response.data['data'] ?? response.data;

      return GoogleOAuthUrlEntity(
        authUrl: data['auth_url'] ?? '',
        message: data['message'] ?? 'Connect your Google Calendar',
      );
    } catch (e) {
      throw Exception('Failed to get Google OAuth URL: $e');
    }
  }

  @override
  Future<void> disconnectGoogleCalendar() async {
    try {
      await apiClient.delete(ApiEndpoints.googleCalendarDisconnect);
    } catch (e) {
      throw Exception('Failed to disconnect Google Calendar: $e');
    }
  }

  @override
  Future<List<GoogleCalendarEventEntity>> getGoogleCalendarEvents({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.googleCalendarEvents,
        queryParameters: {
          if (startDate != null) 'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
        },
      );

      return _parseGoogleEvents(response.data);
    } catch (e) {
      return []; // Return empty list if not connected or error
    }
  }

  @override
  Future<List<GoogleCalendarEventEntity>> getTodayMeetings() async {
    try {
      final response = await apiClient.get(ApiEndpoints.googleCalendarToday);
      return _parseGoogleEvents(response.data);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<GoogleCalendarEventEntity>> getUpcomingMeetings({
    int days = 7,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.googleCalendarUpcoming,
        queryParameters: {'days': days.toString()},
      );
      return _parseGoogleEvents(response.data);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> linkOAuthSession(String sessionId) async {
    try {
      await apiClient.post(
        ApiEndpoints.googleCalendarLinkSession,
        data: {'session_id': sessionId},
      );
    } catch (e) {
      throw Exception('Failed to link OAuth session: $e');
    }
  }

  @override
  Future<void> handleMobileCallback(String code, String customScheme) async {
    try {
      await apiClient.post(
        ApiEndpoints.googleCalendarCallbackMobile,
        data: {'code': code, 'custom_scheme': customScheme},
      );
    } catch (e) {
      throw Exception('Failed to handle mobile OAuth callback: $e');
    }
  }

  List<GoogleCalendarEventEntity> _parseGoogleEvents(dynamic rawData) {
    List<dynamic> eventsList = [];

    if (rawData is Map && rawData['data'] != null) {
      final data = rawData['data'];
      if (data is Map && data['meetings'] != null) {
        eventsList = data['meetings'];
      } else if (data is Map && data['events'] != null) {
        eventsList = data['events'];
      } else if (data is List) {
        eventsList = data;
      }
    } else if (rawData is List) {
      eventsList = rawData;
    }

    return eventsList.map((e) {
      final event = Map<String, dynamic>.from(e);
      return GoogleCalendarEventEntity(
        id: event['id']?.toString() ?? '',
        title: event['title'] ?? event['summary'] ?? 'Untitled Event',
        description: event['description'],
        startTime: _parseDateTime(event['start'] ?? event['startTime']),
        endTime: _parseDateTime(event['end'] ?? event['endTime']),
        location: event['location'],
        attendees:
            (event['attendees'] as List<dynamic>?)
                ?.map((a) => a.toString())
                .toList() ??
            [],
        htmlLink: event['htmlLink'],
        meetLink: event['meet_link']?.toString() ?? event['meetLink']?.toString(),
        isAllDay: event['is_all_day'] ?? event['isAllDay'] ?? false,
        colorId: event['colorId'],
      );
    }).toList();
  }

  DateTime _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return DateTime.now();
    if (dateTime is DateTime) return dateTime;
    if (dateTime is String) return DateTime.parse(dateTime);
    if (dateTime is Map) {
      // Google Calendar API format
      final dateTimeStr = dateTime['dateTime'] ?? dateTime['date'];
      if (dateTimeStr != null) return DateTime.parse(dateTimeStr);
    }
    return DateTime.now();
  }
}
