// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeedbackModel _$FeedbackModelFromJson(Map<String, dynamic> json) =>
    FeedbackModel(
      id: json['id'] as String,
      user: FeedbackUserModel.fromJson(json['user'] as Map<String, dynamic>),
      answer: json['answer'] == null
          ? null
          : FeedbackAnswerModel.fromJson(
              json['answer'] as Map<String, dynamic>),
      topic: json['topic'] == null
          ? null
          : FeedbackTopicModel.fromJson(json['topic'] as Map<String, dynamic>),
      helpful: json['helpful'] as String,
      comment: json['comment'] as String?,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$FeedbackModelToJson(FeedbackModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'answer': instance.answer,
      'topic': instance.topic,
      'helpful': instance.helpful,
      'comment': instance.comment,
      'createdAt': instance.createdAt,
    };

FeedbackUserModel _$FeedbackUserModelFromJson(Map<String, dynamic> json) =>
    FeedbackUserModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      studentID: json['studentID'] as String?,
      email: json['email'] as String,
      role: json['role'] as String,
      classInfo: json['classInfo'] == null
          ? null
          : FeedbackClassModel.fromJson(
              json['classInfo'] as Map<String, dynamic>),
      group: json['group'] == null
          ? null
          : FeedbackGroupModel.fromJson(json['group'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FeedbackUserModelToJson(FeedbackUserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'studentID': instance.studentID,
      'email': instance.email,
      'role': instance.role,
      'classInfo': instance.classInfo,
      'group': instance.group,
    };

FeedbackClassModel _$FeedbackClassModelFromJson(Map<String, dynamic> json) =>
    FeedbackClassModel(
      id: json['id'] as String,
      code: json['code'] as String?,
      lecturer: json['lecturer'] == null
          ? null
          : FeedbackLecturerModel.fromJson(
              json['lecturer'] as Map<String, dynamic>),
      status: json['status'] as String,
    );

Map<String, dynamic> _$FeedbackClassModelToJson(FeedbackClassModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'lecturer': instance.lecturer,
      'status': instance.status,
    };

FeedbackLecturerModel _$FeedbackLecturerModelFromJson(
        Map<String, dynamic> json) =>
    FeedbackLecturerModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String?,
    );

Map<String, dynamic> _$FeedbackLecturerModelToJson(
        FeedbackLecturerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
    };

FeedbackGroupModel _$FeedbackGroupModelFromJson(Map<String, dynamic> json) =>
    FeedbackGroupModel(
      id: json['id'] as String,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$FeedbackGroupModelToJson(FeedbackGroupModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

FeedbackAnswerModel _$FeedbackAnswerModelFromJson(Map<String, dynamic> json) =>
    FeedbackAnswerModel(
      id: json['id'] as String,
      content: json['content'] as String?,
    );

Map<String, dynamic> _$FeedbackAnswerModelToJson(
        FeedbackAnswerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
    };

FeedbackTopicModel _$FeedbackTopicModelFromJson(Map<String, dynamic> json) =>
    FeedbackTopicModel(
      id: json['id'] as String,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$FeedbackTopicModelToJson(FeedbackTopicModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

PagedFeedbackResponse _$PagedFeedbackResponseFromJson(
        Map<String, dynamic> json) =>
    PagedFeedbackResponse(
      statusCode: (json['statusCode'] as num).toInt(),
      code: json['code'] as String,
      message: json['message'] as String,
      data: FeedbackPagedData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PagedFeedbackResponseToJson(
        PagedFeedbackResponse instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
    };

FeedbackPagedData _$FeedbackPagedDataFromJson(Map<String, dynamic> json) =>
    FeedbackPagedData(
      items: (json['items'] as List<dynamic>)
          .map((e) => FeedbackModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalItems: (json['totalItems'] as num).toInt(),
      currentPage: (json['currentPage'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      hasPreviousPage: json['hasPreviousPage'] as bool,
      hasNextPage: json['hasNextPage'] as bool,
    );

Map<String, dynamic> _$FeedbackPagedDataToJson(FeedbackPagedData instance) =>
    <String, dynamic>{
      'items': instance.items,
      'totalItems': instance.totalItems,
      'currentPage': instance.currentPage,
      'totalPages': instance.totalPages,
      'pageSize': instance.pageSize,
      'hasPreviousPage': instance.hasPreviousPage,
      'hasNextPage': instance.hasNextPage,
    };
