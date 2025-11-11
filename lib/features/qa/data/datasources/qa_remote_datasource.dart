// Following project rules:
import 'package:dio/dio.dart';
import 'package:swp_app/data/services/api_client.dart';
import 'package:swp_app/features/qa/data/models/qa_models.dart';

class QARemoteDataSource {
  final ApiClient _client;
  QARemoteDataSource(this._client);

  Future<PagedQAPairsResponse> getQAPairs({
    String? topicId,
    String? documentId,
    int page = 1,
    int pageSize = 10,
  }) async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/course/api/qa-pairs',
      queryParameters: {
        if (topicId != null) 'topicId': topicId,
        if (documentId != null) 'documentId': documentId,
        'page': page,
        'pageSize': pageSize,
      },
    );
    return PagedQAPairsResponse.fromJson(resp.data!);
  }

  Future<QAPairDetailResponse> getQAPairById(String id) async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/course/api/qa-pairs/$id',
    );
    return QAPairDetailResponse.fromJson(resp.data!);
  }

  Future<void> createQAPair({
    required String topicId,
    String? documentId,
    required String questionText,
    required String answerText,
  }) async {
    final form = FormData.fromMap({
      'TopicId': topicId,
      if (documentId != null) 'DocumentId': documentId,
      'QuestionText': questionText,
      'AnswerText': answerText,
    });
    await _client.post(
      '/course/api/qa-pairs',
      data: form,
      options: Options(contentType: Headers.multipartFormDataContentType),
    );
  }

  Future<void> updateQAPair({
    required String id,
    required String questionText,
    required String answerText,
  }) async {
    final form = FormData.fromMap({
      'QuestionText': questionText,
      'AnswerText': answerText,
    });
    await _client.put(
      '/course/api/qa-pairs/$id',
      data: form,
      options: Options(contentType: Headers.multipartFormDataContentType),
    );
  }

  Future<void> deleteQAPair(String id) async {
    await _client.delete('/course/api/qa-pairs/$id');
  }
}
