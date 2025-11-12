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

PagedDocumentsResponse _$PagedDocumentsResponseFromJson(
        Map<String, dynamic> json) =>
    PagedDocumentsResponse(
      statusCode: (json['statusCode'] as num).toInt(),
      code: json['code'] as String,
      message: json['message'] as String,
      data: DocumentsPagedDataModel.fromJson(
          json['data'] as Map<String, dynamic>),
    );

DocumentsPagedDataModel _$DocumentsPagedDataModelFromJson(
        Map<String, dynamic> json) =>
    DocumentsPagedDataModel(
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
