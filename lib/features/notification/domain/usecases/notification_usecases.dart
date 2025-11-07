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
