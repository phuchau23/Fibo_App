// Following project rules:
import 'package:json_annotation/json_annotation.dart';

part 'feedback_models.g.dart';

@JsonSerializable(createToJson: false)
class FeedbackModel {
  final String id;
  final FeedbackUserModel user;
  final FeedbackAnswerModel? answer;
  final FeedbackTopicModel? topic;
  final String helpful;
  final String? comment;
  final String createdAt;

  FeedbackModel({
    required this.id,
    required this.user,
    this.answer,
    this.topic,
    required this.helpful,
    this.comment,
    required this.createdAt,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) =>
      _$FeedbackModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class FeedbackUserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String? studentID;
  final String email;
  final String role;
  final FeedbackClassModel? classInfo;
  final FeedbackGroupModel? group;

  FeedbackUserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.studentID,
    required this.email,
    required this.role,
    this.classInfo,
    this.group,
  });

  factory FeedbackUserModel.fromJson(Map<String, dynamic> json) =>
      _$FeedbackUserModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class FeedbackClassModel {
  final String id;
  final String? code;
  final FeedbackLecturerModel? lecturer;
  final String status;

  FeedbackClassModel({
    required this.id,
    this.code,
    this.lecturer,
    required this.status,
  });

  factory FeedbackClassModel.fromJson(Map<String, dynamic> json) =>
      _$FeedbackClassModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class FeedbackLecturerModel {
  final String id;
  final String? fullName;

  FeedbackLecturerModel({required this.id, this.fullName});

  factory FeedbackLecturerModel.fromJson(Map<String, dynamic> json) =>
      _$FeedbackLecturerModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class FeedbackGroupModel {
  final String id;
  final String? name;

  FeedbackGroupModel({required this.id, this.name});

  factory FeedbackGroupModel.fromJson(Map<String, dynamic> json) =>
      _$FeedbackGroupModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class FeedbackAnswerModel {
  final String id;
  final String? content;

  FeedbackAnswerModel({required this.id, this.content});

  factory FeedbackAnswerModel.fromJson(Map<String, dynamic> json) =>
      _$FeedbackAnswerModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class FeedbackTopicModel {
  final String id;
  final String? name;

  FeedbackTopicModel({required this.id, this.name});

  factory FeedbackTopicModel.fromJson(Map<String, dynamic> json) =>
      _$FeedbackTopicModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class PagedFeedbackResponse {
  final int statusCode;
  final String code;
  final String message;
  final FeedbackPagedData data;

  PagedFeedbackResponse({
    required this.statusCode,
    required this.code,
    required this.message,
    required this.data,
  });

  factory PagedFeedbackResponse.fromJson(Map<String, dynamic> json) =>
      _$PagedFeedbackResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class FeedbackPagedData {
  final List<FeedbackModel> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  FeedbackPagedData({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory FeedbackPagedData.fromJson(Map<String, dynamic> json) =>
      _$FeedbackPagedDataFromJson(json);
}
