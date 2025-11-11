// Following project rules:
import 'package:json_annotation/json_annotation.dart';

part 'notification_models.g.dart';

@JsonSerializable()
class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String description;
  final String icon;
  final String? relatedEntityId;
  final String? relatedEntityType;
  final String createdAt;
  final bool isNew;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    this.relatedEntityId,
    this.relatedEntityType,
    required this.createdAt,
    required this.isNew,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
}

@JsonSerializable()
class PagedNotificationsResponse {
  final int statusCode;
  final String code;
  final String message;
  final NotificationPagedData data;

  PagedNotificationsResponse({
    required this.statusCode,
    required this.code,
    required this.message,
    required this.data,
  });

  factory PagedNotificationsResponse.fromJson(Map<String, dynamic> json) =>
      _$PagedNotificationsResponseFromJson(json);
}

@JsonSerializable()
class NotificationPagedData {
  final List<NotificationModel> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  NotificationPagedData({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory NotificationPagedData.fromJson(Map<String, dynamic> json) =>
      _$NotificationPagedDataFromJson(json);
}

