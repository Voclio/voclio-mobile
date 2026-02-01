import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<Either<Failure, List<NotificationEntity>>> call() async {
    return await repository.getNotifications();
  }
}

class GetUnreadCountUseCase {
  final NotificationRepository repository;

  GetUnreadCountUseCase(this.repository);

  Future<Either<Failure, int>> call() async {
    return await repository.getUnreadCount();
  }
}

class MarkAsReadUseCase {
  final NotificationRepository repository;

  MarkAsReadUseCase(this.repository);

  Future<Either<Failure, void>> call(int id) async {
    return await repository.markAsRead(id);
  }
}

class MarkAllAsReadUseCase {
  final NotificationRepository repository;

  MarkAllAsReadUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.markAllAsRead();
  }
}

class DeleteNotificationUseCase {
  final NotificationRepository repository;

  DeleteNotificationUseCase(this.repository);

  Future<Either<Failure, void>> call(int id) async {
    return await repository.deleteNotification(id);
  }
}

class DeleteAllNotificationsUseCase {
  final NotificationRepository repository;

  DeleteAllNotificationsUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.deleteAllNotifications();
  }
}
