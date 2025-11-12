// Following project rules:
import 'package:json_annotation/json_annotation.dart';

part 'document_type_models.g.dart';

@JsonSerializable(createToJson: false)
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
}

@JsonSerializable(createToJson: false)
class PagedDocumentTypesResponse {
  final int statusCode;
  final String code;
  final String message;
  final DocumentTypePagedDataModel data;

  PagedDocumentTypesResponse({
    required this.statusCode,
    required this.code,
    required this.message,
    required this.data,
  });

  factory PagedDocumentTypesResponse.fromJson(Map<String, dynamic> json) =>
      _$PagedDocumentTypesResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class DocumentTypePagedDataModel {
  final List<DocumentTypeModel> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  DocumentTypePagedDataModel({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory DocumentTypePagedDataModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentTypePagedDataModelFromJson(json);
}
