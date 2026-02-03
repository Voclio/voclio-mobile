import 'package:voclio_app/core/api/api_client.dart';
import 'package:voclio_app/core/api/api_endpoints.dart';
import '../models/calendar_month_model.dart';

abstract class CalendarRemoteDataSource {
  Future<CalendarMonthModel> getCalendarMonth(int year, int month);
  Future<List<Map<String, dynamic>>> getCalendarEvents({
    String? startDate,
    String? endDate,
  });
  Future<List<Map<String, dynamic>>> getDayEvents(String date);
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
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.calendarEvents,
        queryParameters: {
          if (startDate != null) 'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
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
}
