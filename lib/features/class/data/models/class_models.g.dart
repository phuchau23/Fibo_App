// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClassResponseEnvelope _$ClassResponseEnvelopeFromJson(
        Map<String, dynamic> json) =>
    ClassResponseEnvelope(
      statusCode: (json['statusCode'] as num).toInt(),
      code: json['code'] as String,
      message: json['message'] as String,
      data: ClassResponseData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ClassResponseEnvelopeToJson(
        ClassResponseEnvelope instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
    };

ClassResponseData _$ClassResponseDataFromJson(Map<String, dynamic> json) =>
    ClassResponseData(
      items: (json['items'] as List<dynamic>)
          .map((e) => ClassItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 1,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
      hasPreviousPage: json['hasPreviousPage'] as bool? ?? false,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
    );

Map<String, dynamic> _$ClassResponseDataToJson(ClassResponseData instance) =>
    <String, dynamic>{
      'items': instance.items,
      'totalItems': instance.totalItems,
      'currentPage': instance.currentPage,
      'totalPages': instance.totalPages,
      'pageSize': instance.pageSize,
      'hasPreviousPage': instance.hasPreviousPage,
      'hasNextPage': instance.hasNextPage,
    };

ClassItemModel _$ClassItemModelFromJson(Map<String, dynamic> json) =>
    ClassItemModel(
      id: json['id'] as String,
      code: json['code'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      semester:
          SemesterModel.fromJson(json['semester'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ClassItemModelToJson(ClassItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
      'semester': instance.semester,
    };

SemesterModel _$SemesterModelFromJson(Map<String, dynamic> json) =>
    SemesterModel(
      id: json['id'] as String,
      code: json['code'] as String,
      term: json['term'] as String,
      year: (json['year'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$SemesterModelToJson(SemesterModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'term': instance.term,
      'year': instance.year,
      'createdAt': instance.createdAt.toIso8601String(),
    };
