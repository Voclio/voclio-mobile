import 'package:voclio_app/core/api/api_client.dart';
import 'package:voclio_app/core/api/api_endpoints.dart';
import 'package:voclio_app/core/api/api_response.dart';
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
    final response = await apiClient.post(
      ApiEndpoints.focusSessions,
      data: {
        'timer_duration': duration,
        if (sound != null) 'ambient_sound': sound,
        if (volume != null) 'sound_volume': volume,
      },
    );
    final data = ApiResponse.unwrapMap(response.data);
    final session = data['session'] ?? data;
    return FocusSessionModel.fromJson(Map<String, dynamic>.from(session as Map));
  }

  @override
  Future<List<FocusSessionModel>> getFocusSessions() async {
    final response = await apiClient.get(ApiEndpoints.focusSessions);
    final list = ApiResponse.unwrapList(response.data, fallbackKeys: ['sessions']);
    return list
        .map((json) => FocusSessionModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  @override
  Future<void> endFocusSession(String id, int actualDuration) async {
    await apiClient.put(
      ApiEndpoints.focusSessionById(id),
      data: {'status': 'completed', 'elapsed_time': actualDuration},
    );
  }

  @override
  Future<void> deleteFocusSession(String id) async {
    await apiClient.delete(ApiEndpoints.focusSessionById(id));
  }

  @override
  Future<StreakModel> getStreak() async {
    final response = await apiClient.get(ApiEndpoints.streak);
    final data = ApiResponse.unwrapMap(response.data);
    final streak = data['streak'] ?? data;
    return StreakModel.fromJson(Map<String, dynamic>.from(streak as Map));
  }

  @override
  Future<List<AchievementModel>> getAchievements() async {
    final response = await apiClient.get(ApiEndpoints.achievements);
    final list = ApiResponse.unwrapList(response.data, key: 'achievements');
    return list
        .map((json) => AchievementModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> getProductivitySummary() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday));
    final response = await apiClient.get(
      ApiEndpoints.productivitySummary,
      queryParameters: {
        'start_date': weekStart.toIso8601String().split('T').first,
        'end_date': now.toIso8601String().split('T').first,
      },
    );
    return ApiResponse.unwrapMap(response.data);
  }

  @override
  Future<AiSuggestionModel> getAiSuggestions() async {
    final response = await apiClient.get(ApiEndpoints.productivitySuggestions);
    return AiSuggestionModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }
}
