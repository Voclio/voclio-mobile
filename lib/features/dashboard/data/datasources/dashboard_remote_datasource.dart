import 'package:voclio_app/core/api/api_client.dart';
import 'package:voclio_app/core/api/api_endpoints.dart';
import '../models/dashboard_stats_model.dart';
import '../models/quick_stats_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardStatsModel> getDashboardStats();
  Future<QuickStatsModel> getQuickStats();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient apiClient;

  DashboardRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<DashboardStatsModel> getDashboardStats() async {
    final response = await apiClient.get(ApiEndpoints.dashboardStats);
    return DashboardStatsModel.fromJson(response.data['data']);
  }

  @override
  Future<QuickStatsModel> getQuickStats() async {
    final response = await apiClient.get(ApiEndpoints.quickStats);
    return QuickStatsModel.fromJson(response.data['data']);
  }
}
