// Following project rules:
import 'package:json_annotation/json_annotation.dart';

part 'qa_models.g.dart';

@JsonSerializable(createToJson: false)
class QAPairModel {
  final String id;
  final String? topicId;
  final String? documentId;
  final String createdById;
  final String? verifiedById;
  final String questionText;
  final String answerText;
  final String status;
  final String createdAt;
  final String updatedAt;

  QAPairModel({
    required this.id,
    this.topicId,
    this.documentId,
    required this.createdById,
    this.verifiedById,
    required this.questionText,
    required this.answerText,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QAPairModel.fromJson(Map<String, dynamic> json) =>
      _$QAPairModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class PagedQAPairsResponse {
  final int statusCode;
  final String code;
  final String message;
  final QAPairsPagedData data;

  PagedQAPairsResponse({
    required this.statusCode,
    required this.code,
    required this.message,
    required this.data,
  });

  factory PagedQAPairsResponse.fromJson(Map<String, dynamic> json) =>
      _$PagedQAPairsResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class QAPairsPagedData {
  final List<QAPairModel> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  QAPairsPagedData({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory QAPairsPagedData.fromJson(Map<String, dynamic> json) =>
      _$QAPairsPagedDataFromJson(json);
}

@JsonSerializable(createToJson: false)
class QAPairDetailResponse {
  final int statusCode;
  final String code;
  final String message;
  final QAPairModel data;

  QAPairDetailResponse({
    required this.statusCode,
    required this.code,
    required this.message,
    required this.data,
  });

  factory QAPairDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$QAPairDetailResponseFromJson(json);
}
