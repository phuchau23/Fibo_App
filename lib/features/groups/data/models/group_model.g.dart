// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupModel _$GroupModelFromJson(Map<String, dynamic> json) => GroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      classInfo:
          GroupClassModel.fromJson(json['class'] as Map<String, dynamic>),
      topic: json['topic'] == null
          ? null
          : GroupTopicModel.fromJson(json['topic'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GroupModelToJson(GroupModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
      'class': instance.classInfo,
      'topic': instance.topic,
    };

GroupClassModel _$GroupClassModelFromJson(Map<String, dynamic> json) =>
    GroupClassModel(
      id: json['id'] as String,
      code: json['code'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lecturer:
          GroupLecturerModel.fromJson(json['lecturer'] as Map<String, dynamic>),
      semester:
          GroupSemesterModel.fromJson(json['semester'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GroupClassModelToJson(GroupClassModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
      'lecturer': instance.lecturer,
      'semester': instance.semester,
    };

GroupLecturerModel _$GroupLecturerModelFromJson(Map<String, dynamic> json) =>
    GroupLecturerModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
    );

Map<String, dynamic> _$GroupLecturerModelToJson(GroupLecturerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
    };

GroupSemesterModel _$GroupSemesterModelFromJson(Map<String, dynamic> json) =>
    GroupSemesterModel(
      id: json['id'] as String,
      code: json['code'] as String,
      term: json['term'] as String,
      year: (json['year'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$GroupSemesterModelToJson(GroupSemesterModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'term': instance.term,
      'year': instance.year,
      'createdAt': instance.createdAt.toIso8601String(),
    };

GroupTopicModel _$GroupTopicModelFromJson(Map<String, dynamic> json) =>
    GroupTopicModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      masterTopic: json['masterTopic'] == null
          ? null
          : GroupMasterTopicModel.fromJson(
              json['masterTopic'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GroupTopicModelToJson(GroupTopicModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'masterTopic': instance.masterTopic,
    };

GroupMasterTopicModel _$GroupMasterTopicModelFromJson(
        Map<String, dynamic> json) =>
    GroupMasterTopicModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$GroupMasterTopicModelToJson(
        GroupMasterTopicModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
    };

GroupListResponse _$GroupListResponseFromJson(Map<String, dynamic> json) =>
    GroupListResponse(
      statusCode: (json['statusCode'] as num).toInt(),
      code: json['code'] as String,
      message: json['message'] as String,
      data: GroupListData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GroupListResponseToJson(GroupListResponse instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
    };

GroupListData _$GroupListDataFromJson(Map<String, dynamic> json) =>
    GroupListData(
      items: (json['items'] as List<dynamic>)
          .map((e) => GroupModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalItems: (json['totalItems'] as num).toInt(),
      currentPage: (json['currentPage'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      hasPreviousPage: json['hasPreviousPage'] as bool,
      hasNextPage: json['hasNextPage'] as bool,
    );

Map<String, dynamic> _$GroupListDataToJson(GroupListData instance) =>
    <String, dynamic>{
      'items': instance.items,
      'totalItems': instance.totalItems,
      'currentPage': instance.currentPage,
      'totalPages': instance.totalPages,
      'pageSize': instance.pageSize,
      'hasPreviousPage': instance.hasPreviousPage,
      'hasNextPage': instance.hasNextPage,
    };
