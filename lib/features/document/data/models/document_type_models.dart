// Following project rules:
import 'package:json_annotation/json_annotation.dart';

part 'document_type_models.g.dart';

@JsonSerializable()
class DocumentTypeModel {
  final String id;
  final String name;
  final String status;
  final String createdAt;

  DocumentTypeModel({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
  });

  factory DocumentTypeModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentTypeModelFromJson(json);
  Map<String, dynamic> toJson() => _$DocumentTypeModelToJson(this);
}

@JsonSerializable()
class PagedDocumentTypesResponse {
  final int statusCode;
  final String code;
  final String message;
  final _DocumentTypePagedData data;

  PagedDocumentTypesResponse({
    required this.statusCode,
    required this.code,
    required this.message,
    required this.data,
  });

  factory PagedDocumentTypesResponse.fromJson(Map<String, dynamic> json) =>
      _$PagedDocumentTypesResponseFromJson(json);
}

@JsonSerializable()
class _DocumentTypePagedData {
  final List<DocumentTypeModel> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  _DocumentTypePagedData({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory _DocumentTypePagedData.fromJson(Map<String, dynamic> json) =>
      _$DocumentTypePagedDataFromJson(json);
}

@JsonSerializable()
class CreateDocumentTypeRequest {
  final String name;
  CreateDocumentTypeRequest({required this.name});

  Map<String, dynamic> toJson() => _$CreateDocumentTypeRequestToJson(this);
}
