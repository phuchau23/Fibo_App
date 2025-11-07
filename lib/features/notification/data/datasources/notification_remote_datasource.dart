import 'package:dio/dio.dart';
import 'package:swp_app/core/constants/api.constants.dart';
import 'package:swp_app/core/error/exceptions.dart';
import 'package:swp_app/data/services/api_client.dart';
import 'package:swp_app/features/notification/data/models/notification_models.dart';

abstract class NotificationRemoteDataSource {
  Future<PagedNotificationsResponse> getNotificationsByLecturer(
    String lecturerId, {
    int page = 1,
    int pageSize = 20,
  });
  Future<PagedNotificationsResponse> getAllNotifications({
    int page = 1,
    int pageSize = 20,
  });
  Future<NotificationModel> getNotificationById(String id);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient apiClient;

  NotificationRemoteDataSourceImpl(this.apiClient);

  @override
  Future<PagedNotificationsResponse> getNotificationsByLecturer(
    String lecturerId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiEndpoints.notificationsByLecturer(lecturerId),
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
      return PagedNotificationsResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message']?.toString() ?? e.message ?? 'Server error',
        e.response?.statusCode?.toString(),
      );
    }
  }

  @override
  Future<PagedNotificationsResponse> getAllNotifications({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiEndpoints.notifications,
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
      return PagedNotificationsResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message']?.toString() ?? e.message ?? 'Server error',
        e.response?.statusCode?.toString(),
      );
    }
  }

  @override
  Future<NotificationModel> getNotificationById(String id) async {
    try {
      final response = await apiClient.dio.get(
        ApiEndpoints.notificationById(id),
      );
      return NotificationModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message']?.toString() ?? e.message ?? 'Server error',
        e.response?.statusCode?.toString(),
      );
    }
  }
}
