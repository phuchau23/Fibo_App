// Following project rules:
import 'package:json_annotation/json_annotation.dart';

part 'document_models.g.dart';

@JsonSerializable()
class DocumentModel {
  final String id;
  final String topicId;
  final String documentTypeId;
  final String? fileId;
  final String title;
  final int version;
  final String status;
  final String createdAt;

  DocumentModel({
    required this.id,
    required this.topicId,
    required this.documentTypeId,
    this.fileId,
    required this.title,
    required this.version,
    required this.status,
    required this.createdAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentModelFromJson(json);
  Map<String, dynamic> toJson() => _$DocumentModelToJson(this);
}

@JsonSerializable()
class PagedDocumentsResponse {
  final int statusCode;
  final String code;
  final String message;
  final _DocumentsPagedData data;

  PagedDocumentsResponse({
    required this.statusCode,
    required this.code,
    required this.message,
    required this.data,
  });

  factory PagedDocumentsResponse.fromJson(Map<String, dynamic> json) =>
      _$PagedDocumentsResponseFromJson(json);
}

@JsonSerializable()
class _DocumentsPagedData {
  final List<DocumentModel> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  _DocumentsPagedData({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory _DocumentsPagedData.fromJson(Map<String, dynamic> json) =>
      _$DocumentsPagedDataFromJson(json);
}
