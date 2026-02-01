import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/notification_usecases.dart';
import 'package:translator/translator.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkAsReadUseCase markAsReadUseCase;
  final MarkAllAsReadUseCase markAllAsReadUseCase;
  final DeleteNotificationUseCase deleteNotificationUseCase;
  final DeleteAllNotificationsUseCase deleteAllNotificationsUseCase;
  final GoogleTranslator _translator = GoogleTranslator();

  // In-memory cache for translations to avoid redundant API calls
  static final Map<String, String> _translationCache = {};

  NotificationsCubit({
    required this.getNotificationsUseCase,
    required this.markAsReadUseCase,
    required this.markAllAsReadUseCase,
    required this.deleteNotificationUseCase,
    required this.deleteAllNotificationsUseCase,
  }) : super(NotificationsInitial());

  Future<void> loadNotifications() async {
    emit(NotificationsLoading());
    final result = await getNotificationsUseCase();
    result.fold((failure) => emit(NotificationsError(failure.toString())), (
      notifications,
    ) async {
      try {
        final translatedNotifications = await _translateNotifications(
          notifications,
        );
        emit(NotificationsLoaded(translatedNotifications));
      } catch (e) {
        // If translation fails, show original notifications
        emit(NotificationsLoaded(notifications));
      }
    });
  }

  Future<List<NotificationEntity>> _translateNotifications(
    List<NotificationEntity> notifications,
  ) async {
    // Translate all notifications in parallel for better performance
    final results = await Future.wait(
      notifications.map((notification) async {
        String title = notification.title;
        String message = notification.message;

        // Translate title if Arabic
        if (_isArabic(title)) {
          title = await _getCachedOrTranslate(title);
        }

        // Translate message if Arabic
        if (_isArabic(message)) {
          message = await _getCachedOrTranslate(message);
        }

        return NotificationEntity(
          id: notification.id,
          userId: notification.userId,
          title: title,
          message: message,
          type: notification.type,
          priority: notification.priority,
          isRead: notification.isRead,
          readAt: notification.readAt,
          relatedId: notification.relatedId,
          createdAt: notification.createdAt,
        );
      }),
    );
    return results;
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
      // Return original text on failure
      return text;
    }
  }

  bool _isArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  Future<void> markAsRead(int id) async {
    final result = await markAsReadUseCase(id);
    result.fold(
      (failure) => emit(NotificationsError('Failed to mark as read: $failure')),
      (_) => loadNotifications(),
    );
  }

  Future<void> markAllAsRead() async {
    final result = await markAllAsReadUseCase();
    result.fold(
      (failure) =>
          emit(NotificationsError('Failed to mark all as read: $failure')),
      (_) => loadNotifications(),
    );
  }

  Future<void> deleteNotification(int id) async {
    final result = await deleteNotificationUseCase(id);
    result.fold(
      (failure) =>
          emit(NotificationsError('Failed to delete notification: $failure')),
      (_) => loadNotifications(),
    );
  }

  Future<void> deleteAllNotifications() async {
    final result = await deleteAllNotificationsUseCase();
    result.fold(
      (failure) => emit(
        NotificationsError('Failed to delete all notifications: $failure'),
      ),
      (_) => loadNotifications(),
    );
  }

  int get unreadCount {
    if (state is NotificationsLoaded) {
      return (state as NotificationsLoaded).notifications
          .where((n) => !n.isRead)
          .length;
    }
    return 0;
  }
}
