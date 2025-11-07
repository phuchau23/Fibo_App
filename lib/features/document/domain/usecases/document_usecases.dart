// Following project rules:
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:swp_app/features/document/domain/entities/document_entities.dart';
import 'package:swp_app/features/document/domain/repositories/document_repository.dart';

class GetDocumentTypes {
  final DocumentRepository _repo;
  GetDocumentTypes(this._repo);
  Future<Either<DocFailure, PagedEntity<DocumentTypeEntity>>> call({
    int page = 1,
    int pageSize = 50,
  }) => _repo.getDocumentTypes(page: page, pageSize: pageSize);
}

class CreateDocumentType {
  final DocumentRepository _repo;
  CreateDocumentType(this._repo);
  Future<Either<DocFailure, DocumentTypeEntity>> call(String name) =>
      _repo.createDocumentType(name);
}

class GetDocumentsByTopic {
  final DocumentRepository _repo;
  GetDocumentsByTopic(this._repo);
  Future<Either<DocFailure, PagedEntity<DocumentEntity>>> call({
    required String topicId,
    int page = 1,
    int pageSize = 10,
  }) => _repo.getDocumentsByTopic(
    topicId: topicId,
    page: page,
    pageSize: pageSize,
  );
}

class UploadDocument {
  final DocumentRepository _repo;
  UploadDocument(this._repo);
  Future<Either<DocFailure, Unit>> call({
    required String topicId,
    required String documentTypeId,
    required String title,
    required MultipartFile file,
  }) => _repo.uploadDocument(
    topicId: topicId,
    documentTypeId: documentTypeId,
    title: title,
    file: file,
  );
}

class UpdateDocument {
  final DocumentRepository _repo;
  UpdateDocument(this._repo);
  Future<Either<DocFailure, Unit>> call({
    required String id,
    String? title,
    int? version,
    String? status,
  }) => _repo.updateDocument(
    id: id,
    title: title,
    version: version,
    status: status,
  );
}

class DeleteDocument {
  final DocumentRepository _repo;
  DeleteDocument(this._repo);
  Future<Either<DocFailure, Unit>> call(String id) => _repo.deleteDocument(id);
}

class GetDocumentById {
  final DocumentRepository _repo;
  GetDocumentById(this._repo);
  Future<Either<DocFailure, DocumentDetailEntity>> call(String id) =>
      _repo.getDocumentById(id);
}
