import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/notification_usecases.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkAsReadUseCase markAsReadUseCase;
  final MarkAllAsReadUseCase markAllAsReadUseCase;
  final DeleteNotificationUseCase deleteNotificationUseCase;
  final DeleteAllNotificationsUseCase deleteAllNotificationsUseCase;

  NotificationsCubit({
    required this.getNotificationsUseCase,
    required this.markAsReadUseCase,
    required this.markAllAsReadUseCase,
    required this.deleteNotificationUseCase,
    required this.deleteAllNotificationsUseCase,
  }) : super(NotificationsInitial());

  Future<void> loadNotifications({bool force = false, bool silent = false}) async {
    if (!force && state is NotificationsLoaded) return;
    if (!silent) {
      emit(NotificationsLoading());
    }

    final result = await getNotificationsUseCase();
    result.fold(
      (failure) => emit(NotificationsError(failure.toString())),
      (notifications) => emit(NotificationsLoaded(notifications)),
    );
  }

  Future<void> markAsRead(int id) async {
    _patchNotifications((notifications) {
      return notifications
          .map(
            (notification) => notification.id == id
                ? notification.copyWith(isRead: true, readAt: DateTime.now())
                : notification,
          )
          .toList();
    });

    final result = await markAsReadUseCase(id);
    result.fold(
      (failure) {
        emit(NotificationsError('Failed to mark as read: $failure'));
        loadNotifications(force: true, silent: true);
      },
      (_) => loadNotifications(force: true, silent: true),
    );
  }

  Future<void> markAllAsRead() async {
    _patchNotifications(
      (notifications) => notifications
          .map(
            (notification) => notification.copyWith(
              isRead: true,
              readAt: notification.readAt ?? DateTime.now(),
            ),
          )
          .toList(),
    );

    final result = await markAllAsReadUseCase();
    result.fold(
      (failure) {
        emit(NotificationsError('Failed to mark all as read: $failure'));
        loadNotifications(force: true, silent: true);
      },
      (_) => loadNotifications(force: true, silent: true),
    );
  }

  Future<void> deleteNotification(int id) async {
    _patchNotifications(
      (notifications) =>
          notifications.where((notification) => notification.id != id).toList(),
    );

    final result = await deleteNotificationUseCase(id);
    result.fold(
      (failure) {
        emit(NotificationsError('Failed to delete notification: $failure'));
        loadNotifications(force: true, silent: true);
      },
      (_) => loadNotifications(force: true, silent: true),
    );
  }

  Future<void> deleteAllNotifications() async {
    emit(NotificationsLoaded([]));

    final result = await deleteAllNotificationsUseCase();
    result.fold(
      (failure) {
        emit(NotificationsError('Failed to delete all notifications: $failure'));
        loadNotifications(force: true, silent: true);
      },
      (_) => loadNotifications(force: true, silent: true),
    );
  }

  void _patchNotifications(
    List<NotificationEntity> Function(List<NotificationEntity>) update,
  ) {
    final current = state;
    if (current is! NotificationsLoaded) return;
    emit(NotificationsLoaded(update(current.notifications)));
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
