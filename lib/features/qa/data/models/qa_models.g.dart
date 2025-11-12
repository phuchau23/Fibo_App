// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qa_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QAPairModel _$QAPairModelFromJson(Map<String, dynamic> json) => QAPairModel(
      id: json['id'] as String,
      topicId: json['topicId'] as String?,
      documentId: json['documentId'] as String?,
      createdById: json['createdById'] as String,
      verifiedById: json['verifiedById'] as String?,
      questionText: json['questionText'] as String,
      answerText: json['answerText'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

PagedQAPairsResponse _$PagedQAPairsResponseFromJson(
        Map<String, dynamic> json) =>
    PagedQAPairsResponse(
      statusCode: (json['statusCode'] as num).toInt(),
      code: json['code'] as String,
      message: json['message'] as String,
      data: QAPairsPagedData.fromJson(json['data'] as Map<String, dynamic>),
    );

QAPairsPagedData _$QAPairsPagedDataFromJson(Map<String, dynamic> json) =>
    QAPairsPagedData(
      items: (json['items'] as List<dynamic>)
          .map((e) => QAPairModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalItems: (json['totalItems'] as num).toInt(),
      currentPage: (json['currentPage'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      hasPreviousPage: json['hasPreviousPage'] as bool,
      hasNextPage: json['hasNextPage'] as bool,
    );

QAPairDetailResponse _$QAPairDetailResponseFromJson(
        Map<String, dynamic> json) =>
    QAPairDetailResponse(
      statusCode: (json['statusCode'] as num).toInt(),
      code: json['code'] as String,
      message: json['message'] as String,
      data: QAPairModel.fromJson(json['data'] as Map<String, dynamic>),
    );
