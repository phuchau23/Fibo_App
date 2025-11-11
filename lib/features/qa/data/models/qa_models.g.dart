// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qa_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QAPairModel _$QAPairModelFromJson(Map<String, dynamic> json) => QAPairModel(
      id: json['id'] as String,
      topicId: json['topicId'] as String,
      documentId: json['documentId'] as String?,
      createdById: json['createdById'] as String,
      verifiedById: json['verifiedById'] as String?,
      questionText: json['questionText'] as String,
      answerText: json['answerText'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$QAPairModelToJson(QAPairModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'topicId': instance.topicId,
      'documentId': instance.documentId,
      'createdById': instance.createdById,
      'verifiedById': instance.verifiedById,
      'questionText': instance.questionText,
      'answerText': instance.answerText,
      'status': instance.status,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

PagedQAPairsResponse _$PagedQAPairsResponseFromJson(
        Map<String, dynamic> json) =>
    PagedQAPairsResponse(
      statusCode: (json['statusCode'] as num).toInt(),
      code: json['code'] as String,
      message: json['message'] as String,
      data: QAPairsPagedData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PagedQAPairsResponseToJson(
        PagedQAPairsResponse instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
    };

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

Map<String, dynamic> _$QAPairsPagedDataToJson(QAPairsPagedData instance) =>
    <String, dynamic>{
      'items': instance.items,
      'totalItems': instance.totalItems,
      'currentPage': instance.currentPage,
      'totalPages': instance.totalPages,
      'pageSize': instance.pageSize,
      'hasPreviousPage': instance.hasPreviousPage,
      'hasNextPage': instance.hasNextPage,
    };

QAPairDetailResponse _$QAPairDetailResponseFromJson(
        Map<String, dynamic> json) =>
    QAPairDetailResponse(
      statusCode: (json['statusCode'] as num).toInt(),
      code: json['code'] as String,
      message: json['message'] as String,
      data: QAPairModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$QAPairDetailResponseToJson(
        QAPairDetailResponse instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
    };
