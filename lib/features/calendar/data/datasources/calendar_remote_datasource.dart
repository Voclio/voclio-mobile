import 'package:voclio_app/core/api/api_client.dart';
import 'package:voclio_app/core/api/api_endpoints.dart';
import '../models/calendar_month_model.dart';

abstract class CalendarRemoteDataSource {
  Future<CalendarMonthModel> getCalendarMonth(int year, int month);
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
}
