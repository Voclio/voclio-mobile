class ApiEndpoints {
  // Base URL
  static const String baseUrl = 'https://voclio-backend.build8.dev/api';

  // Production URL (uncomment when deploying)
  // static const String baseUrl = 'https://your-production-url.com/api';

  // ========== Authentication ==========
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String googleOAuth = '/auth/google';
  static const String googleAuth = '/auth/google';
  static const String facebookOAuth = '/auth/facebook';
  static const String facebookAuth = '/auth/facebook';
  static const String refreshToken = '/auth/refresh-token';
  static const String profile = '/auth/profile';
  static const String updateProfile = '/auth/profile';
  static const String changePassword = '/auth/change-password';
  static const String resetPassword = '/auth/reset-password';
  static const String forgotPassword = '/auth/forgot-password';
  static const String logout = '/auth/logout';
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';

  // ========== Dashboard ==========
  static const String dashboardStats = '/dashboard/stats';
  static const String quickStats = '/dashboard/quick-stats';

  // ========== Tasks ==========
  static const String tasks = '/tasks';
  static const String taskStats = '/tasks/stats';
  static const String mainTasks = '/tasks/main';
  static const String bulkTasks = '/tasks/bulk';
  static const String taskStatistics = '/tasks/statistics';
  static const String taskCategories = '/tasks/categories';

  static String taskById(String id) => '/tasks/$id';
  static String taskSubtasks(String id) => '/tasks/$id/subtasks';
  static String taskWithSubtasks(String id) => '/tasks/$id/with-subtasks';
  static String completeTask(String id) => taskById(id);
  static String subtasks(String taskId) => '/tasks/$taskId/subtasks';
  static String subtaskById(String id) => '/tasks/subtasks/$id';
  static String taskCategoryById(String id) => '/tasks/categories/$id';

  static const String tasksByDate = '/tasks/by-date';
  static const String tasksByCategory = '/tasks/by-category';

  // ========== Notes ==========
  static const String notes = '/notes';

  static String noteById(String id) => '/notes/$id';
  static String summarizeNote(String id) => '/notes/$id/summarize';
  static String extractTasksFromNote(String id) => '/notes/$id/extract-tasks';
  static String noteTags(String id) => '/notes/$id/tags';
  static String removeNoteTag(String noteId, String tagId) =>
      '/notes/$noteId/tags/$tagId';

  // ========== Voice ==========
  static const String voiceRecordings = '/voice';
  static const String uploadVoice = '/voice/upload';
  static const String transcribe = '/voice/transcribe';
  static String completeProcess = '/voice/process-complete';

  static String createNoteFromVoice(String id) => '/voice/$id/create-note';
  static String createTasksFromVoice(String id) => '/voice/$id/create-tasks';
  static String deleteVoice(String id) => '/voice/$id';

  // ========== Calendar ==========
  static String calendarMonth(int year, int month) =>
      '/calendar/month/$year/$month';
  static const String calendarEvents = '/calendar/events';
  static String calendarDay(String date) => '/calendar/day/$date';

  // ========== Reminders ==========
  static const String reminders = '/reminders';
  static const String upcomingReminders = '/reminders/upcoming';

  static String reminderById(String id) => '/reminders/$id';
  static String snoozeReminder(String id) => '/reminders/$id/snooze';
  static String dismissReminder(String id) => '/reminders/$id/dismiss';

  // ========== Tags ==========
  static const String tags = '/tags';
  static String tagById(String id) => '/tags/$id';

  // ========== Productivity ==========
  static const String focusSessions = '/productivity/focus-sessions';
  static String focusSessionById(String id) =>
      '/productivity/focus-sessions/$id';
  static const String streak = '/productivity/streak';
  static const String achievements = '/productivity/achievements';
  static const String productivitySummary = '/productivity/summary';
  static const String productivitySuggestions = '/productivity/suggestions';

  // ========== Notifications ==========
  static const String notifications = '/notifications';
  static const String unreadCount = '/notifications/unread-count';
  static const String markAllRead = '/notifications/mark-all-read';

  static String notificationById(String id) => '/notifications/$id';
  static String markNotificationRead(String id) => '/notifications/$id/read';

  // ========== Settings ==========
  static const String settings = '/settings';
  static const String settingsTheme = '/settings/theme';
  static const String settingsLanguage = '/settings/language';
  static const String settingsTimezone = '/settings/timezone';
  static const String settingsNotifications = '/settings/notifications';

  // ========== Admin (Optional) ==========
  static const String adminUsers = '/admin/users';
  static String adminUserById(String id) => '/admin/users/$id';
  static String adminUserStatus(String id) => '/admin/users/$id/status';
  static const String adminSystemAnalytics = '/admin/analytics/system';
  static const String adminAIUsage = '/admin/analytics/ai-usage';
  static const String adminContent = '/admin/analytics/content';

  // ========== System ==========
  static const String health = '/health';
  static const String apiInfo = '/';
}
