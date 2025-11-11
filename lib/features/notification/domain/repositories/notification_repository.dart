import 'package:dartz/dartz.dart';
import 'package:swp_app/features/notification/domain/entities/notification_entities.dart';

class NotificationFailure {
  final String message;
  NotificationFailure(this.message);
}

abstract class NotificationRepository {
  Future<Either<NotificationFailure, NotificationPagedEntity>>
  getNotificationsByLecturer(
    String lecturerId, {
    int page = 1,
    int pageSize = 20,
  });
  Future<Either<NotificationFailure, NotificationPagedEntity>>
  getAllNotifications({int page = 1, int pageSize = 20});
  Future<Either<NotificationFailure, NotificationEntity>> getNotificationById(
    String id,
  );
}
