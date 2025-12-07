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
    try {
      final response = await apiClient.get(ApiEndpoints.dashboardStats);
      return DashboardStatsModel.fromJson(response.data['data']);
    } catch (e) {
      // Return mock data on error
      return _getMockDashboardStats();
    }
  }

  @override
  Future<QuickStatsModel> getQuickStats() async {
    try {
      final response = await apiClient.get(ApiEndpoints.quickStats);
      return QuickStatsModel.fromJson(response.data['data']);
    } catch (e) {
      // Return mock data on error
      return _getMockQuickStats();
    }
  }

  // Mock data methods
  DashboardStatsModel _getMockDashboardStats() {
    final now = DateTime.now();
    return DashboardStatsModel.fromJson({
      'taskStats': {
        'totalTasks': 24,
        'completedTasks': 16,
        'pendingTasks': 6,
        'overdueTasks': 2,
        'completionRate': 66.7,
      },
      'noteStats': {'totalNotes': 18, 'notesThisWeek': 5, 'notesThisMonth': 12},
      'productivityStats': {
        'currentStreak': 7,
        'longestStreak': 21,
        'totalFocusTime': 1440, // 24 hours in minutes
        'focusSessionsCompleted': 32,
      },
      'upcomingTasks': [
        {
          'id': 'task_1',
          'title': 'Complete project proposal',
          'description': 'Finalize and submit the Q1 project proposal',
          'due_date': now.add(const Duration(days: 1)).toIso8601String(),
          'priority': 'high',
          'is_done': false,
        },
        {
          'id': 'task_2',
          'title': 'Team meeting preparation',
          'description': 'Prepare slides for weekly team sync',
          'due_date': now.add(const Duration(days: 2)).toIso8601String(),
          'priority': 'medium',
          'is_done': false,
        },
        {
          'id': 'task_3',
          'title': 'Review code changes',
          'description': 'Review pull requests from team members',
          'due_date': now.add(const Duration(hours: 6)).toIso8601String(),
          'priority': 'high',
          'is_done': false,
        },
      ],
      'recentNotes': [
        {
          'id': 'note_1',
          'title': 'Meeting Notes - Daily Standup',
          'content':
              'Discussed sprint progress and blockers. Team velocity is good.',
          'created_at':
              now.subtract(const Duration(hours: 2)).toIso8601String(),
        },
        {
          'id': 'note_2',
          'title': 'Ideas for New Feature',
          'content':
              'Consider adding dark mode and custom themes to improve user experience.',
          'created_at': now.subtract(const Duration(days: 1)).toIso8601String(),
        },
        {
          'id': 'note_3',
          'title': 'Learning Resources',
          'content':
              'Bookmark useful Flutter tutorials and best practices articles.',
          'created_at': now.subtract(const Duration(days: 2)).toIso8601String(),
        },
      ],
    });
  }

  QuickStatsModel _getMockQuickStats() {
    return QuickStatsModel(
      todayTasks: 5,
      pendingTasks: 8,
      totalNotes: 18,
      currentStreak: 7,
    );
  }
}
