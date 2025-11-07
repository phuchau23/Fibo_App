// Following project rules:
class DocumentTypeEntity {
  final String id;
  final String name;
  final String status;
  final DateTime createdAt;

  const DocumentTypeEntity({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
  });
}

class DocumentEntity {
  final String id;
  final String topicId;
  final String documentTypeId;
  final String? fileId;
  final String title;
  final int version;
  final String status;
  final DateTime createdAt;

  const DocumentEntity({
    required this.id,
    required this.topicId,
    required this.documentTypeId,
    required this.fileId,
    required this.title,
    required this.version,
    required this.status,
    required this.createdAt,
  });
}

class DocumentDetailEntity {
  final DocumentEntity summary;
  final String? extractedTextPath;
  final String? embeddingStatus;
  final bool? isEmbedded;
  final DateTime? embeddedAt;
  final String? verifiedById;
  final String? updatedById;
  final DateTime updatedAt;
  final TopicSummaryEntity? topic;
  final DocumentTypeEntity? documentType;
  final FileSummaryEntity? file;

  const DocumentDetailEntity({
    required this.summary,
    this.extractedTextPath,
    this.embeddingStatus,
    this.isEmbedded,
    this.embeddedAt,
    this.verifiedById,
    this.updatedById,
    required this.updatedAt,
    this.topic,
    this.documentType,
    this.file,
  });
}

class TopicSummaryEntity {
  final String id;
  final String name;
  final String? description;
  final String? masterTopicId;
  final String status;
  final DateTime createdAt;

  const TopicSummaryEntity({
    required this.id,
    required this.name,
    this.description,
    this.masterTopicId,
    required this.status,
    required this.createdAt,
  });
}

class FileSummaryEntity {
  final String id;
  final String? ownerUserId;
  final String fileName;
  final String? filePath;
  final String? fileContentType;
  final int? fileSize;
  final String? fileUrl;
  final String? fileKey;
  final String? fileBucket;
  final String? fileRegion;
  final String? fileAcl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? status;

  const FileSummaryEntity({
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
}

class PagedEntity<T> {
  final List<T> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  const PagedEntity({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });
}
