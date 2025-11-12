import 'package:dartz/dartz.dart';
import 'package:swp_app/features/notification/domain/entities/notification_entities.dart';
import 'package:swp_app/features/notification/domain/repositories/notification_repository.dart';

class GetNotificationsByLecturer {
  final NotificationRepository repository;

  GetNotificationsByLecturer(this.repository);

  Future<Either<NotificationFailure, NotificationPagedEntity>> call(
    String lecturerId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    return await repository.getNotificationsByLecturer(
      lecturerId,
      page: page,
      pageSize: pageSize,
    );
  }
}

class GetAllNotifications {
  final NotificationRepository repository;

  GetAllNotifications(this.repository);

  Future<Either<NotificationFailure, NotificationPagedEntity>> call({
    int page = 1,
    int pageSize = 20,
  }) async {
    return await repository.getAllNotifications(page: page, pageSize: pageSize);
  }
}

class GetNotificationById {
  final NotificationRepository repository;

  GetNotificationById(this.repository);

  Future<Either<NotificationFailure, NotificationEntity>> call(
    String id,
  ) async {
    return await repository.getNotificationById(id);
  }
}

class MarkNotificationRead {
  final NotificationRepository repository;

  MarkNotificationRead(this.repository);

  Future<Either<NotificationFailure, Unit>> call({
    required String lecturerId,
    required String notificationId,
    bool isRead = true,
  }) {
    return repository.markNotificationRead(
      lecturerId: lecturerId,
      notificationId: notificationId,
      isRead: isRead,
    );
  }
}

class MarkAllNotificationsRead {
  final NotificationRepository repository;

  MarkAllNotificationsRead(this.repository);

  Future<Either<NotificationFailure, Unit>> call(String lecturerId) {
    return repository.markAllNotificationsRead(lecturerId);
  }
}
