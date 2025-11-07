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

Map<String, dynamic> _$DocumentTypeModelToJson(DocumentTypeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'status': instance.status,
      'createdAt': instance.createdAt,
    };

PagedDocumentTypesResponse _$PagedDocumentTypesResponseFromJson(
        Map<String, dynamic> json) =>
    PagedDocumentTypesResponse(
      statusCode: (json['statusCode'] as num).toInt(),
      code: json['code'] as String,
      message: json['message'] as String,
      data:
          _DocumentTypePagedData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PagedDocumentTypesResponseToJson(
        PagedDocumentTypesResponse instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
    };

_DocumentTypePagedData _$DocumentTypePagedDataFromJson(
        Map<String, dynamic> json) =>
    _DocumentTypePagedData(
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

Map<String, dynamic> _$DocumentTypePagedDataToJson(
        _DocumentTypePagedData instance) =>
    <String, dynamic>{
      'items': instance.items,
      'totalItems': instance.totalItems,
      'currentPage': instance.currentPage,
      'totalPages': instance.totalPages,
      'pageSize': instance.pageSize,
      'hasPreviousPage': instance.hasPreviousPage,
      'hasNextPage': instance.hasNextPage,
    };

CreateDocumentTypeRequest _$CreateDocumentTypeRequestFromJson(
        Map<String, dynamic> json) =>
    CreateDocumentTypeRequest(
      name: json['name'] as String,
    );

Map<String, dynamic> _$CreateDocumentTypeRequestToJson(
        CreateDocumentTypeRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
    };
