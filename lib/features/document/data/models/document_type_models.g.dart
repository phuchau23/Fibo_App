// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_type_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentTypeModel _$DocumentTypeModelFromJson(Map<String, dynamic> json) =>
    DocumentTypeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
    );

PagedDocumentTypesResponse _$PagedDocumentTypesResponseFromJson(
        Map<String, dynamic> json) =>
    PagedDocumentTypesResponse(
      statusCode: (json['statusCode'] as num).toInt(),
      code: json['code'] as String,
      message: json['message'] as String,
      data: DocumentTypePagedDataModel.fromJson(
          json['data'] as Map<String, dynamic>),
    );

DocumentTypePagedDataModel _$DocumentTypePagedDataModelFromJson(
        Map<String, dynamic> json) =>
    DocumentTypePagedDataModel(
      items: (json['items'] as List<dynamic>)
          .map((e) => DocumentTypeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalItems: (json['totalItems'] as num).toInt(),
      currentPage: (json['currentPage'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      hasPreviousPage: json['hasPreviousPage'] as bool,
      hasNextPage: json['hasNextPage'] as bool,
    );
