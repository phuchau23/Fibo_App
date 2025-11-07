// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentDetailResponse _$DocumentDetailResponseFromJson(
        Map<String, dynamic> json) =>
    DocumentDetailResponse(
      statusCode: (json['statusCode'] as num).toInt(),
      code: json['code'] as String,
      message: json['message'] as String,
      data: DocumentDetailModel.fromJson(json['data'] as Map<String, dynamic>),
    );

DocumentDetailModel _$DocumentDetailModelFromJson(Map<String, dynamic> json) =>
    DocumentDetailModel(
      id: _stringify(json['id']),
      topicId: _stringify(json['topicId']),
      documentTypeId: _stringify(json['documentTypeId']),
      fileId: _stringifyNullable(json['fileId']),
      title: _stringify(json['title']),
      version: (json['version'] as num).toInt(),
      extractedTextPath: _stringifyNullable(json['extractedTextPath']),
      embeddingStatus: _stringifyNullable(json['embeddingStatus']),
      isEmbedded: json['isEmbedded'] as bool?,
      embeddedAt: _stringifyNullable(json['embeddedAt']),
      status: _stringify(json['status']),
      verifiedById: _stringifyNullable(json['verifiedById']),
      updatedById: _stringifyNullable(json['updatedById']),
      createdAt: _stringify(json['createdAt']),
      updatedAt: _stringify(json['updatedAt']),
      topic: json['topic'] == null
          ? null
          : TopicSummaryModel.fromJson(json['topic'] as Map<String, dynamic>),
      documentType: json['documentType'] == null
          ? null
          : DocumentTypeSummaryModel.fromJson(
              json['documentType'] as Map<String, dynamic>),
      file: json['file'] == null
          ? null
          : FileSummaryModel.fromJson(json['file'] as Map<String, dynamic>),
    );

TopicSummaryModel _$TopicSummaryModelFromJson(Map<String, dynamic> json) =>
    TopicSummaryModel(
      id: _stringify(json['id']),
      name: _stringify(json['name']),
      description: _stringifyNullable(json['description']),
      masterTopicId: _stringifyNullable(json['masterTopicId']),
      status: _stringify(json['status']),
      createdAt: _stringify(json['createdAt']),
    );

DocumentTypeSummaryModel _$DocumentTypeSummaryModelFromJson(
        Map<String, dynamic> json) =>
    DocumentTypeSummaryModel(
      id: _stringify(json['id']),
      name: _stringify(json['name']),
      status: _stringify(json['status']),
      createdAt: _stringify(json['createdAt']),
    );

FileSummaryModel _$FileSummaryModelFromJson(Map<String, dynamic> json) =>
    FileSummaryModel(
      id: _stringify(json['id']),
      ownerUserId: _stringifyNullable(json['ownerUserId']),
      fileName: _stringify(json['fileName']),
      filePath: _stringifyNullable(json['filePath']),
      fileContentType: _stringifyNullable(json['fileContentType']),
      fileSize: (json['fileSize'] as num?)?.toInt(),
      fileUrl: _stringifyNullable(json['fileUrl']),
      fileKey: _stringifyNullable(json['fileKey']),
      fileBucket: _stringifyNullable(json['fileBucket']),
      fileRegion: _stringifyNullable(json['fileRegion']),
      fileAcl: _stringifyNullable(json['fileAcl']),
      createdAt: _stringify(json['createdAt']),
      updatedAt: _stringify(json['updatedAt']),
      status: _stringifyNullable(json['status']),
    );
