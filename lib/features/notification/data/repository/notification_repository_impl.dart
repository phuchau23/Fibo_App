import 'package:dartz/dartz.dart';
import 'package:swp_app/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:swp_app/features/notification/data/models/notification_models.dart';
import 'package:swp_app/features/notification/domain/entities/notification_entities.dart';
import 'package:swp_app/features/notification/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remote;

  NotificationRepositoryImpl(this.remote);

  @override
  Future<Either<NotificationFailure, NotificationPagedEntity>>
  getNotificationsByLecturer(
    String lecturerId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await remote.getNotificationsByLecturer(
        lecturerId,
        page: page,
        pageSize: pageSize,
      );
      return Right(_mapPagedResponse(response.data));
    } catch (e) {
      return Left(NotificationFailure(e.toString()));
    }
  }

  @override
  Future<Either<NotificationFailure, NotificationPagedEntity>>
  getAllNotifications({int page = 1, int pageSize = 20}) async {
    try {
      final response = await remote.getAllNotifications(
        page: page,
        pageSize: pageSize,
      );
      return Right(_mapPagedResponse(response.data));
    } catch (e) {
      return Left(NotificationFailure(e.toString()));
    }
  }

  @override
  Future<Either<NotificationFailure, NotificationEntity>> getNotificationById(
    String id,
  ) async {
    try {
      final model = await remote.getNotificationById(id);
      return Right(_mapModel(model));
    } catch (e) {
      return Left(NotificationFailure(e.toString()));
    }
  }

  NotificationPagedEntity _mapPagedResponse(NotificationPagedData data) {
    return NotificationPagedEntity(
      items: data.items.map((m) => _mapModel(m)).toList(),
      totalItems: data.totalItems,
      currentPage: data.currentPage,
      totalPages: data.totalPages,
      pageSize: data.pageSize,
      hasPreviousPage: data.hasPreviousPage,
      hasNextPage: data.hasNextPage,
    );
  }

  NotificationEntity _mapModel(NotificationModel model) {
    return NotificationEntity(
      id: model.id,
      type: model.type,
      title: model.title,
      description: model.description,
      icon: model.icon,
      relatedEntityId: model.relatedEntityId,
      relatedEntityType: model.relatedEntityType,
      createdAt: DateTime.parse(model.createdAt),
      isNew: model.isNew,
      data: model.data,
    );
  }
}
