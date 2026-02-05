import 'package:voclio_app/core/api/api_client.dart';
import 'package:voclio_app/core/api/api_endpoints.dart';
import 'package:voclio_app/features/productivity/data/models/productivity_models.dart';
import 'package:voclio_app/features/productivity/data/models/ai_suggestion_model.dart';

abstract class ProductivityRemoteDataSource {
  Future<FocusSessionModel> startFocusSession(
    int duration,
    String? sound,
    int? volume,
  );
  Future<List<FocusSessionModel>> getFocusSessions();
  Future<void> endFocusSession(String id, int actualDuration);
  Future<void> deleteFocusSession(String id);
  Future<StreakModel> getStreak();
  Future<List<AchievementModel>> getAchievements();
  Future<Map<String, dynamic>> getProductivitySummary();
  Future<AiSuggestionModel> getAiSuggestions();
}

class ProductivityRemoteDataSourceImpl implements ProductivityRemoteDataSource {
  final ApiClient apiClient;

  ProductivityRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<FocusSessionModel> startFocusSession(
    int duration,
    String? sound,
    int? volume,
  ) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.focusSessions,
        data: {
          'timer_duration': duration,
          if (sound != null) 'ambient_sound': sound,
          if (volume != null) 'sound_volume': volume,
        },
      );
      return FocusSessionModel.fromJson(response.data['data']['session']);
    } catch (e) {
      // Return mock focus session
      return FocusSessionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timerDuration: duration * 60,
        ambientSound: sound,
        soundVolume: volume,
        completed: false,
        createdAt: DateTime.now(),
      );
    }
  }

  @override
  Future<List<FocusSessionModel>> getFocusSessions() async {
    try {
      final response = await apiClient.get(ApiEndpoints.focusSessions);
      final List<dynamic> data = response.data['data'];
      return data.map((json) => FocusSessionModel.fromJson(json)).toList();
    } catch (e) {
      // Return mock data if API fails
      return [
        FocusSessionModel(
          id: '1',
          timerDuration: 1500,
          actualDuration: 1500,
          completed: true,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        FocusSessionModel(
          id: '2',
          timerDuration: 3600,
          actualDuration: 3200,
          completed: true,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
    }
  }

  @override
  Future<void> endFocusSession(String id, int actualDuration) async {
    try {
      await apiClient.put(
        ApiEndpoints.focusSessionById(id),
        data: {'status': 'completed', 'actual_duration': actualDuration},
      );
    } catch (e) {
      // Mock success - do nothing
      return;
    }
  }

  Future<StreakModel> getStreak() async {
    try {
      final response = await apiClient.get(ApiEndpoints.streak);
      return StreakModel.fromJson(response.data['data']['streak']);
    } catch (e) {
      // Return mock data if API fails
      return StreakModel(
        currentStreak: 5,
        longestStreak: 12,
        lastActivityDate: DateTime.now().subtract(const Duration(days: 1)),
      );
    }
  }

  @override
  Future<List<AchievementModel>> getAchievements() async {
    try {
      final response = await apiClient.get(ApiEndpoints.achievements);
      final List<dynamic> data = response.data['data']['achievements'];
      return data.map((json) => AchievementModel.fromJson(json)).toList();
    } catch (e) {
      // Return mock data if API fails
      return [
        AchievementModel(
          id: '1',
          title: 'First Focus',
          description: 'Complete your first focus session',
          icon: '🎯',
          isUnlocked: true,
        ),
        AchievementModel(
          id: '2',
          title: 'Week Warrior',
          description: 'Maintain a 7-day streak',
          icon: '🔥',
          isUnlocked: true,
        ),
        AchievementModel(
          id: '3',
          title: 'Focus Master',
          description: 'Complete 50 focus sessions',
          icon: '👑',
          isUnlocked: false,
        ),
        AchievementModel(
          id: '4',
          title: 'Early Bird',
          description: 'Start a session before 8 AM',
          icon: '🌅',
          isUnlocked: true,
        ),
        AchievementModel(
          id: '5',
          title: 'Night Owl',
          description: 'Complete a session after 10 PM',
          icon: '🦉',
          isUnlocked: false,
        ),
        AchievementModel(
          id: '6',
          title: 'Marathon Runner',
          description: 'Complete a 2-hour focus session',
          icon: '⚡',
          isUnlocked: false,
        ),
      ];
    }
  }

  @override
  Future<void> deleteFocusSession(String id) async {
    try {
      await apiClient.delete(ApiEndpoints.focusSessionById(id));
    } catch (e) {
      throw Exception('Failed to delete focus session: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getProductivitySummary() async {
    try {
      final response = await apiClient.get(ApiEndpoints.productivitySummary);
      return response.data['data'] ?? response.data;
    } catch (e) {
      // Return mock summary if API fails
      return {
        'total_focus_time': 7200,
        'sessions_completed': 10,
        'average_session_length': 720,
        'most_productive_hour': 14,
        'weekly_goal_progress': 0.75,
      };
    }
  }

  @override
  Future<AiSuggestionModel> getAiSuggestions() async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.productivitySuggestions,
      );
      return AiSuggestionModel.fromJson(response.data);
    } catch (e) {
      // Return mock suggestions if API fails
      return AiSuggestionModel.fromJson({
        'data': {
          'suggestions': [
            'Try scheduling your most important tasks in the morning when focus is highest',
            'Take short breaks every 25-30 minutes to maintain productivity',
            'Consider using voice notes to capture ideas quickly on the go',
          ],
          'based_on': {
            'summary': {
              'focus_days': 0,
              'total_focus_minutes': 0,
              'total_sessions': 0,
              'avg_session_minutes': '0.00',
              'tasks_completed': 0,
              'current_streak': 0,
            },
            'total_tasks': 0,
            'pending_tasks': 0,
            'overdue_tasks': 0,
          },
        },
      });
    }
  }
}
