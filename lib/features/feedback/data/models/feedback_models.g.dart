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

FeedbackLecturerModel _$FeedbackLecturerModelFromJson(
        Map<String, dynamic> json) =>
    FeedbackLecturerModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String?,
    );

FeedbackGroupModel _$FeedbackGroupModelFromJson(Map<String, dynamic> json) =>
    FeedbackGroupModel(
      id: json['id'] as String,
      name: json['name'] as String?,
    );

FeedbackAnswerModel _$FeedbackAnswerModelFromJson(Map<String, dynamic> json) =>
    FeedbackAnswerModel(
      id: json['id'] as String,
      content: json['content'] as String?,
    );

FeedbackTopicModel _$FeedbackTopicModelFromJson(Map<String, dynamic> json) =>
    FeedbackTopicModel(
      id: json['id'] as String,
      name: json['name'] as String?,
    );

PagedFeedbackResponse _$PagedFeedbackResponseFromJson(
        Map<String, dynamic> json) =>
    PagedFeedbackResponse(
      statusCode: (json['statusCode'] as num).toInt(),
      code: json['code'] as String,
      message: json['message'] as String,
      data: FeedbackPagedData.fromJson(json['data'] as Map<String, dynamic>),
    );

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
