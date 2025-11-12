// Following project rules:
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:swp_app/features/document/domain/entities/document_entities.dart';

abstract class DocumentRepository {
  Future<Either<DocFailure, PagedEntity<DocumentTypeEntity>>> getDocumentTypes({
    int page,
    int pageSize,
  });

  Future<Either<DocFailure, DocumentTypeEntity>> createDocumentType(
    String name,
  );

  Future<Either<DocFailure, PagedEntity<DocumentEntity>>> getDocumentsByTopic({
    required String topicId,
    int page,
    int pageSize,
  });

  Future<Either<DocFailure, Unit>> uploadDocument({
    required String topicId,
    required String documentTypeId,
    required String title,
    required MultipartFile file,
  });

  Future<Either<DocFailure, Unit>> updateDocument({
    required String id,
    required String topicId,
    required String documentTypeId,
    required String title,
    required int version,
    MultipartFile? file,
  });

  Future<Either<DocFailure, Unit>> deleteDocument(String id);

  Future<Either<DocFailure, Unit>> publishDocument(String id);

  Future<Either<DocFailure, Unit>> unpublishDocument(String id);

  Future<Either<DocFailure, DocumentDetailEntity>> getDocumentById(String id);
}

class DocFailure {
  final String message;
  const DocFailure(this.message);
}
