// Following project rules:
import 'package:json_annotation/json_annotation.dart';

part 'document_detail_model.g.dart';

String _stringify(dynamic value) => value?.toString() ?? '';
String? _stringifyNullable(dynamic value) => value?.toString();

@JsonSerializable(createToJson: false)
class DocumentDetailResponse {
  final int statusCode;
  final String code;
  final String message;
  final DocumentDetailModel data;

  DocumentDetailResponse({
    required this.statusCode,
    required this.code,
    required this.message,
    required this.data,
  });

  factory DocumentDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$DocumentDetailResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class DocumentDetailModel {
  @JsonKey(fromJson: _stringify)
  final String id;
  @JsonKey(fromJson: _stringify)
  final String topicId;
  @JsonKey(fromJson: _stringify)
  final String documentTypeId;
  @JsonKey(fromJson: _stringifyNullable)
  final String? fileId;
  @JsonKey(fromJson: _stringify)
  final String title;
  final int version;
  @JsonKey(fromJson: _stringifyNullable)
  final String? extractedTextPath;
  @JsonKey(fromJson: _stringifyNullable)
  final String? embeddingStatus;
  final bool? isEmbedded;
  @JsonKey(fromJson: _stringifyNullable)
  final String? embeddedAt;
  @JsonKey(fromJson: _stringify)
  final String status;
  @JsonKey(fromJson: _stringifyNullable)
  final String? verifiedById;
  @JsonKey(fromJson: _stringifyNullable)
  final String? updatedById;
  @JsonKey(fromJson: _stringify)
  final String createdAt;
  @JsonKey(fromJson: _stringify)
  final String updatedAt;
  final TopicSummaryModel? topic;
  final DocumentTypeSummaryModel? documentType;
  final FileSummaryModel? file;

  DocumentDetailModel({
    required this.id,
    required this.topicId,
    required this.documentTypeId,
    required this.fileId,
    required this.title,
    required this.version,
    this.extractedTextPath,
    this.embeddingStatus,
    this.isEmbedded,
    this.embeddedAt,
    required this.status,
    this.verifiedById,
    this.updatedById,
    required this.createdAt,
    required this.updatedAt,
    this.topic,
    this.documentType,
    this.file,
  });

  factory DocumentDetailModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentDetailModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class TopicSummaryModel {
  @JsonKey(fromJson: _stringify)
  final String id;
  @JsonKey(fromJson: _stringify)
  final String name;
  @JsonKey(fromJson: _stringifyNullable)
  final String? description;
  @JsonKey(fromJson: _stringifyNullable)
  final String? masterTopicId;
  @JsonKey(fromJson: _stringify)
  final String status;
  @JsonKey(fromJson: _stringify)
  final String createdAt;

  TopicSummaryModel({
    required this.id,
    required this.name,
    this.description,
    this.masterTopicId,
    required this.status,
    required this.createdAt,
  });

  factory TopicSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$TopicSummaryModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class DocumentTypeSummaryModel {
  @JsonKey(fromJson: _stringify)
  final String id;
  @JsonKey(fromJson: _stringify)
  final String name;
  @JsonKey(fromJson: _stringify)
  final String status;
  @JsonKey(fromJson: _stringify)
  final String createdAt;

  DocumentTypeSummaryModel({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
  });

  factory DocumentTypeSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentTypeSummaryModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class FileSummaryModel {
  @JsonKey(fromJson: _stringify)
  final String id;
  @JsonKey(fromJson: _stringifyNullable)
  final String? ownerUserId;
  @JsonKey(fromJson: _stringify)
  final String fileName;
  @JsonKey(fromJson: _stringifyNullable)
  final String? filePath;
  @JsonKey(fromJson: _stringifyNullable)
  final String? fileContentType;
  final int? fileSize;
  @JsonKey(fromJson: _stringifyNullable)
  final String? fileUrl;
  @JsonKey(fromJson: _stringifyNullable)
  final String? fileKey;
  @JsonKey(fromJson: _stringifyNullable)
  final String? fileBucket;
  @JsonKey(fromJson: _stringifyNullable)
  final String? fileRegion;
  @JsonKey(fromJson: _stringifyNullable)
  final String? fileAcl;
  @JsonKey(fromJson: _stringify)
  final String createdAt;
  @JsonKey(fromJson: _stringify)
  final String updatedAt;
  @JsonKey(fromJson: _stringifyNullable)
  final String? status;

  FileSummaryModel({
    required this.id,
    this.ownerUserId,
    required this.fileName,
    this.filePath,
    this.fileContentType,
    this.fileSize,
    this.fileUrl,
    this.fileKey,
    this.fileBucket,
    this.fileRegion,
    this.fileAcl,
    required this.createdAt,
    required this.updatedAt,
    this.status,
  });

  factory FileSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$FileSummaryModelFromJson(json);
}
