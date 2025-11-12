// Following project rules:
import 'package:dio/dio.dart';
import 'package:swp_app/data/services/api_client.dart';
import 'package:swp_app/features/document/data/models/document_models.dart';
import 'package:swp_app/features/document/data/models/document_type_models.dart';
import 'package:swp_app/features/document/data/models/document_detail_model.dart';

class DocumentRemoteDataSource {
  final ApiClient _client;
  DocumentRemoteDataSource(this._client);

  Future<PagedDocumentTypesResponse> getDocumentTypes({
    int page = 1,
    int pageSize = 10,
  }) async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/course/api/document-types',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return PagedDocumentTypesResponse.fromJson(resp.data!);
  }

  Future<DocumentTypeModel> createDocumentType(String name) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/course/api/document-types',
      data: FormData.fromMap({'Name': name}),
      options: Options(contentType: Headers.multipartFormDataContentType),
    );
    return DocumentTypeModel.fromJson(
      resp.data!['data'] as Map<String, dynamic>,
    );
  }

  Future<PagedDocumentsResponse> getDocumentsByTopic({
    required String topicId,
    int page = 1,
    int pageSize = 10,
  }) async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/course/api/documents/topic/$topicId',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return PagedDocumentsResponse.fromJson(resp.data!);
  }

  Future<Map<String, dynamic>> uploadDocument({
    required String topicId,
    required String documentTypeId,
    required String title,
    required MultipartFile file,
  }) async {
    final form = FormData.fromMap({
      'TopicId': topicId,
      'DocumentTypeId': documentTypeId,
      'Title': title,
      'File': file,
      'AutoEmbed': true,
      'AutoLoadCache': true,
    });
    final resp = await _client.post<Map<String, dynamic>>(
      '/course/api/documents/upload',
      data: form,
      options: Options(contentType: Headers.multipartFormDataContentType),
    );
    return resp.data!;
  }

  Future<Map<String, dynamic>> updateDocument({
    required String id,
    required String topicId,
    required String documentTypeId,
    required String title,
    required int version,
    MultipartFile? file,
  }) async {
    final form = FormData.fromMap({
      'TopicId': topicId,
      'DocumentTypeId': documentTypeId,
      'Title': title,
      'Version': version,
      'AutoEmbed': true,
      'AutoLoadCache': true,
      if (file != null) 'File': file,
    });
    final resp = await _client.put<Map<String, dynamic>>(
      '/course/api/documents/$id',
      data: form,
      options: Options(contentType: Headers.multipartFormDataContentType),
    );
    return resp.data!;
  }

  Future<void> deleteDocument(String id) async {
    await _client.delete('/course/api/documents/$id');
  }

  Future<void> publishDocument(String id) async {
    await _client.post('/course/api/documents/$id/publish');
  }

  Future<void> unpublishDocument(String id) async {
    await _client.post('/course/api/documents/$id/unpublish');
  }

  Future<DocumentDetailResponse> getDocumentById(String id) async {
    // Following project rules: add simple terminal logging for debugging
    // ignore: avoid_print
    print('📄 [DocumentRemoteDataSource] → GET /course/api/documents/$id');
    final resp = await _client.get<Map<String, dynamic>>(
      '/course/api/documents/$id',
    );
    // ignore: avoid_print
    print('✅ [DocumentRemoteDataSource] document detail loaded for $id');
    return DocumentDetailResponse.fromJson(resp.data!);
  }
}
