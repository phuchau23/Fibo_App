// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      relatedEntityId: json['relatedEntityId'] as String?,
      relatedEntityType: json['relatedEntityType'] as String?,
      createdAt: json['createdAt'] as String,
      isNew: json['isNew'] as bool,
      data: json['data'] as Map<String, dynamic>?,
    );

PagedNotificationsResponse _$PagedNotificationsResponseFromJson(
        Map<String, dynamic> json) =>
    PagedNotificationsResponse(
      statusCode: (json['statusCode'] as num).toInt(),
      code: json['code'] as String,
      message: json['message'] as String,
      data:
          NotificationPagedData.fromJson(json['data'] as Map<String, dynamic>),
    );

NotificationPagedData _$NotificationPagedDataFromJson(
        Map<String, dynamic> json) =>
    NotificationPagedData(
      items: (json['items'] as List<dynamic>)
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalItems: (json['totalItems'] as num).toInt(),
      currentPage: (json['currentPage'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      hasPreviousPage: json['hasPreviousPage'] as bool,
      hasNextPage: json['hasNextPage'] as bool,
    );
