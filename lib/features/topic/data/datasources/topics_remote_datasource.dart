// Following project rules:
import 'package:dio/dio.dart';
import 'package:swp_app/data/services/api_client.dart';
import 'package:swp_app/features/topic/data/models/paged_topics_response.dart';
import 'package:swp_app/features/topic/data/models/topic_detail_model.dart';

class TopicsRemoteDataSource {
  final ApiClient _client;
  TopicsRemoteDataSource(this._client);

  Future<PagedTopicsResponse> getTopics({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      print(
        '🔵 [TopicsRemoteDataSource] Calling GET /course/api/topics?page=$page&pageSize=$pageSize',
      );
      final resp = await _client.get<Map<String, dynamic>>(
        '/course/api/topics',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
      print(
        '✅ [TopicsRemoteDataSource] API Response Status: ${resp.statusCode}',
      );
      print('📦 [TopicsRemoteDataSource] Response Data: ${resp.data}');
      final result = PagedTopicsResponse.fromJson(resp.data!);
      print(
        '✅ [TopicsRemoteDataSource] Parsed ${result.data.items.length} topics',
      );
      return result;
    } on DioException catch (e) {
      print('❌ [TopicsRemoteDataSource] DioException: ${e.message}');
      print(
        '❌ [TopicsRemoteDataSource] Status Code: ${e.response?.statusCode}',
      );
      print('❌ [TopicsRemoteDataSource] Response Data: ${e.response?.data}');
      // ném ra cho Repository map -> Failure
      throw Exception(e.message);
    } catch (e, stackTrace) {
      print('❌ [TopicsRemoteDataSource] Unexpected Error: $e');
      print('❌ [TopicsRemoteDataSource] StackTrace: $stackTrace');
      rethrow;
    }
  }

  Future<PagedTopicsResponse> getTopicsByLecturer({
    required String lecturerId,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      print(
        '🔵 [TopicsRemoteDataSource] Calling GET /course/api/topics/lecturer/$lecturerId?page=$page&pageSize=$pageSize',
      );
      final resp = await _client.get<Map<String, dynamic>>(
        '/course/api/topics/lecturer/$lecturerId',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
      print(
        '✅ [TopicsRemoteDataSource] API Response Status: ${resp.statusCode}',
      );
      print('📦 [TopicsRemoteDataSource] Response Data: ${resp.data}');
      final result = PagedTopicsResponse.fromJson(resp.data!);
      print(
        '✅ [TopicsRemoteDataSource] Parsed ${result.data.items.length} topics for lecturer',
      );
      return result;
    } on DioException catch (e) {
      print('❌ [TopicsRemoteDataSource] DioException: ${e.message}');
      print(
        '❌ [TopicsRemoteDataSource] Status Code: ${e.response?.statusCode}',
      );
      print('❌ [TopicsRemoteDataSource] Response Data: ${e.response?.data}');
      throw Exception(e.message);
    } catch (e, stackTrace) {
      print('❌ [TopicsRemoteDataSource] Unexpected Error: $e');
      print('❌ [TopicsRemoteDataSource] StackTrace: $stackTrace');
      rethrow;
    }
  }

  Future<TopicDetailResponse> getTopicById(String topicId) async {
    try {
      print(
        '🔵 [TopicsRemoteDataSource] Calling GET /course/api/topics/$topicId',
      );
      final resp = await _client.get<Map<String, dynamic>>(
        '/course/api/topics/$topicId',
      );
      print(
        '✅ [TopicsRemoteDataSource] API Response Status: ${resp.statusCode}',
      );
      print('📦 [TopicsRemoteDataSource] Response Data: ${resp.data}');
      final result = TopicDetailResponse.fromJson(resp.data!);
      print('✅ [TopicsRemoteDataSource] Parsed topic detail');
      return result;
    } on DioException catch (e) {
      print('❌ [TopicsRemoteDataSource] DioException: ${e.message}');
      print(
        '❌ [TopicsRemoteDataSource] Status Code: ${e.response?.statusCode}',
      );
      print('❌ [TopicsRemoteDataSource] Response Data: ${e.response?.data}');
      throw Exception(e.message);
    } catch (e, stackTrace) {
      print('❌ [TopicsRemoteDataSource] Unexpected Error: $e');
      print('❌ [TopicsRemoteDataSource] StackTrace: $stackTrace');
      rethrow;
    }
  }
}
