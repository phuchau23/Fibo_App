// Following project rules:
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:swp_app/features/document/data/datasources/document_remote_datasource.dart';
import 'package:swp_app/features/document/data/models/document_detail_model.dart';
import 'package:swp_app/features/document/domain/entities/document_entities.dart';
import 'package:swp_app/features/document/domain/repositories/document_repository.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentRemoteDataSource _remote;
  DocumentRepositoryImpl(this._remote);

  @override
  Future<Either<DocFailure, PagedEntity<DocumentTypeEntity>>> getDocumentTypes({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final res = await _remote.getDocumentTypes(
        page: page,
        pageSize: pageSize,
      );
      final items = res.data.items
          .map(
            (e) => DocumentTypeEntity(
              id: e.id,
              name: e.name,
              status: e.status,
              createdAt: DateTime.parse(e.createdAt),
            ),
          )
          .toList();
      return Right(
        PagedEntity(
          items: items,
          totalItems: res.data.totalItems,
          currentPage: res.data.currentPage,
          totalPages: res.data.totalPages,
          pageSize: res.data.pageSize,
          hasPreviousPage: res.data.hasPreviousPage,
          hasNextPage: res.data.hasNextPage,
        ),
      );
    } catch (e) {
      return Left(DocFailure(e.toString()));
    }
  }

  @override
  Future<Either<DocFailure, DocumentTypeEntity>> createDocumentType(
    String name,
  ) async {
    try {
      final m = await _remote.createDocumentType(name);
      return Right(
        DocumentTypeEntity(
          id: m.id,
          name: m.name,
          status: m.status,
          createdAt: DateTime.parse(m.createdAt),
        ),
      );
    } catch (e) {
      return Left(DocFailure(e.toString()));
    }
  }

  @override
  Future<Either<DocFailure, PagedEntity<DocumentEntity>>> getDocumentsByTopic({
    required String topicId,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final res = await _remote.getDocumentsByTopic(
        topicId: topicId,
        page: page,
        pageSize: pageSize,
      );
      final items = res.data.items
          .map(
            (e) => DocumentEntity(
              id: e.id,
              topicId: e.topicId,
              documentTypeId: e.documentTypeId,
              fileId: e.fileId,
              title: e.title,
              version: e.version,
              status: e.status,
              createdAt: DateTime.parse(e.createdAt),
            ),
          )
          .toList();
      return Right(
        PagedEntity(
          items: items,
          totalItems: res.data.totalItems,
          currentPage: res.data.currentPage,
          totalPages: res.data.totalPages,
          pageSize: res.data.pageSize,
          hasPreviousPage: res.data.hasPreviousPage,
          hasNextPage: res.data.hasNextPage,
        ),
      );
    } catch (e) {
      return Left(DocFailure(e.toString()));
    }
  }

  @override
  Future<Either<DocFailure, Unit>> uploadDocument({
    required String topicId,
    required String documentTypeId,
    required String title,
    required MultipartFile file,
  }) async {
    try {
      await _remote.uploadDocument(
        topicId: topicId,
        documentTypeId: documentTypeId,
        title: title,
        file: file,
      );
      return const Right(unit);
    } catch (e) {
      return Left(DocFailure(e.toString()));
    }
  }

  @override
  Future<Either<DocFailure, Unit>> deleteDocument(String id) async {
    try {
      await _remote.deleteDocument(id);
      return const Right(unit);
    } catch (e) {
      return Left(DocFailure(e.toString()));
    }
  }

  @override
  Future<Either<DocFailure, Unit>> updateDocument({
    required String id,
    String? title,
    int? version,
    String? status,
  }) async {
    try {
      await _remote.updateDocument(
        id: id,
        title: title,
        version: version,
        status: status,
      );
      return const Right(unit);
    } catch (e) {
      return Left(DocFailure(e.toString()));
    }
  }

  @override
  Future<Either<DocFailure, DocumentDetailEntity>> getDocumentById(
    String id,
  ) async {
    try {
      final res = await _remote.getDocumentById(id);
      final detail = _mapDetail(res.data);
      return Right(detail);
    } catch (e) {
      return Left(DocFailure(e.toString()));
    }
  }

  DocumentDetailEntity _mapDetail(DocumentDetailModel model) {
    final summary = DocumentEntity(
      id: model.id,
      topicId: model.topicId,
      documentTypeId: model.documentTypeId,
      fileId: model.fileId,
      title: model.title,
      version: model.version,
      status: model.status,
      createdAt: DateTime.parse(model.createdAt),
    );

    TopicSummaryEntity? topic;
    if (model.topic != null) {
      topic = TopicSummaryEntity(
        id: model.topic!.id,
        name: model.topic!.name,
        description: model.topic!.description,
        masterTopicId: model.topic!.masterTopicId,
        status: model.topic!.status,
        createdAt: DateTime.parse(model.topic!.createdAt),
      );
    }

    DocumentTypeEntity? docType;
    if (model.documentType != null) {
      docType = DocumentTypeEntity(
        id: model.documentType!.id,
        name: model.documentType!.name,
        status: model.documentType!.status,
        createdAt: DateTime.parse(model.documentType!.createdAt),
      );
    }

    FileSummaryEntity? file;
    if (model.file != null) {
      file = FileSummaryEntity(
        id: model.file!.id,
        ownerUserId: model.file!.ownerUserId,
        fileName: model.file!.fileName,
        filePath: model.file!.filePath,
        fileContentType: model.file!.fileContentType,
        fileSize: model.file!.fileSize,
        fileUrl: model.file!.fileUrl,
        fileKey: model.file!.fileKey,
        fileBucket: model.file!.fileBucket,
        fileRegion: model.file!.fileRegion,
        fileAcl: model.file!.fileAcl,
        createdAt: DateTime.parse(model.file!.createdAt),
        updatedAt: DateTime.parse(model.file!.updatedAt),
        status: model.file!.status,
      );
    }

    return DocumentDetailEntity(
      summary: summary,
      extractedTextPath: model.extractedTextPath,
      embeddingStatus: model.embeddingStatus,
      isEmbedded: model.isEmbedded,
      embeddedAt: model.embeddedAt != null
          ? DateTime.tryParse(model.embeddedAt!)
          : null,
      verifiedById: model.verifiedById,
      updatedById: model.updatedById,
      updatedAt: DateTime.parse(model.updatedAt),
      topic: topic,
      documentType: docType,
      file: file,
    );
  }
}
