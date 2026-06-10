/// Helpers for the backend `{ success, data, pagination }` envelope.
class ApiResponse {
  ApiResponse._();

  static dynamic unwrap(dynamic raw) {
    if (raw is Map<String, dynamic> && raw.containsKey('data')) {
      return raw['data'];
    }
    return raw;
  }

  static Map<String, dynamic> unwrapMap(dynamic raw) {
    final data = unwrap(raw);
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }

  static List<dynamic> unwrapList(
    dynamic raw, {
    String? key,
    List<String> fallbackKeys = const [
      'items',
      'tasks',
      'notes',
      'recordings',
      'categories',
      'subtasks',
      'achievements',
      'notifications',
      'reminders',
      'sessions',
      'tags',
    ],
  }) {
    final data = unwrap(raw);

    if (data is List) return data;

    if (data is Map) {
      if (key != null && data[key] is List) return data[key] as List;
      for (final k in fallbackKeys) {
        if (data[k] is List) return data[k] as List;
      }
    }

    return [];
  }
}
