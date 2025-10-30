// Following project rules:
import 'package:dio/dio.dart';
import 'package:swp_app/data/services/api_client.dart';
import 'package:swp_app/features/topic/data/models/paged_topics_response.dart';

class TopicsRemoteDataSource {
  final ApiClient _client;
  TopicsRemoteDataSource(this._client);

  Future<PagedTopicsResponse> getTopics({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final resp = await _client.get<Map<String, dynamic>>(
        '/course/api/topics',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
      return PagedTopicsResponse.fromJson(resp.data!);
    } on DioException catch (e) {
      // ném ra cho Repository map -> Failure
      throw Exception(e.message);
    }
  }
}
