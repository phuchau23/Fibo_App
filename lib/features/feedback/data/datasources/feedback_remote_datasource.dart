// Following project rules:
import 'package:dio/dio.dart';
import 'package:swp_app/data/services/api_client.dart';
import 'package:swp_app/features/feedback/data/models/feedback_models.dart';

class FeedbackRemoteDataSource {
  final ApiClient _client;
  FeedbackRemoteDataSource(this._client);

  Future<PagedFeedbackResponse> getFeedbacks({
    int page = 1,
    int pageSize = 10,
  }) async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/course/api/feedback',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return PagedFeedbackResponse.fromJson(resp.data!);
  }

  Future<PagedFeedbackResponse> getFeedbacksByLecturer(
    String lecturerId, {
    int page = 1,
    int pageSize = 10,
  }) async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/course/api/feedback/lecturer/$lecturerId',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return PagedFeedbackResponse.fromJson(resp.data!);
  }

  Future<PagedFeedbackResponse> getFeedbacksByTopic(
    String topicId, {
    int page = 1,
    int pageSize = 10,
  }) async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/course/api/feedback/topic/$topicId',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return PagedFeedbackResponse.fromJson(resp.data!);
  }

  Future<PagedFeedbackResponse> getFeedbacksByAnswer(
    String answerId, {
    int page = 1,
    int pageSize = 10,
  }) async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/course/api/feedback/answer/$answerId',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return PagedFeedbackResponse.fromJson(resp.data!);
  }

  Future<FeedbackModel> getFeedbackById(String id) async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/course/api/feedback/$id',
    );
    return FeedbackModel.fromJson(resp.data!['data'] as Map<String, dynamic>);
  }

  Future<void> updateFeedback({
    required String id,
    required String helpful,
    String? comment,
  }) async {
    final form = FormData.fromMap({
      'Helpful': helpful,
      if (comment != null) 'Comment': comment,
    });
    await _client.put(
      '/course/api/feedback/$id',
      data: form,
      options: Options(contentType: Headers.multipartFormDataContentType),
    );
  }

  Future<void> deleteFeedback(String id) async {
    await _client.delete('/course/api/feedback/$id');
  }
}
