// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentModel _$DocumentModelFromJson(Map<String, dynamic> json) =>
    DocumentModel(
      id: json['id'] as String,
      topicId: json['topicId'] as String,
      documentTypeId: json['documentTypeId'] as String,
      fileId: json['fileId'] as String?,
      title: json['title'] as String,
      version: (json['version'] as num).toInt(),
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$DocumentModelToJson(DocumentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'topicId': instance.topicId,
      'documentTypeId': instance.documentTypeId,
      'fileId': instance.fileId,
      'title': instance.title,
      'version': instance.version,
      'status': instance.status,
      'createdAt': instance.createdAt,
    };

PagedDocumentsResponse _$PagedDocumentsResponseFromJson(
        Map<String, dynamic> json) =>
    PagedDocumentsResponse(
      statusCode: (json['statusCode'] as num).toInt(),
      code: json['code'] as String,
      message: json['message'] as String,
      data: _DocumentsPagedData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PagedDocumentsResponseToJson(
        PagedDocumentsResponse instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
    };

_DocumentsPagedData _$DocumentsPagedDataFromJson(Map<String, dynamic> json) =>
    _DocumentsPagedData(
      items: (json['items'] as List<dynamic>)
          .map((e) => DocumentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalItems: (json['totalItems'] as num).toInt(),
      currentPage: (json['currentPage'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      hasPreviousPage: json['hasPreviousPage'] as bool,
      hasNextPage: json['hasNextPage'] as bool,
    );

Map<String, dynamic> _$DocumentsPagedDataToJson(_DocumentsPagedData instance) =>
    <String, dynamic>{
      'items': instance.items,
      'totalItems': instance.totalItems,
      'currentPage': instance.currentPage,
      'totalPages': instance.totalPages,
      'pageSize': instance.pageSize,
      'hasPreviousPage': instance.hasPreviousPage,
      'hasNextPage': instance.hasNextPage,
    };
