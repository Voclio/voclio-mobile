import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_as_read_usecase.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkAsReadUseCase markAsReadUseCase;

  NotificationsCubit({
    required this.getNotificationsUseCase,
    required this.markAsReadUseCase,
  }) : super(NotificationsInitial());

  Future<void> loadNotifications() async {
    emit(NotificationsLoading());
    final result = await getNotificationsUseCase();
    result.fold(
      (failure) => emit(NotificationsError(failure.toString())),
      (notifications) => emit(NotificationsLoaded(notifications)),
    );
  }

  Future<void> markAsRead(String id) async {
    final result = await markAsReadUseCase(id);
    result.fold(
      (failure) => emit(NotificationsError(failure.toString())),
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
