// Following project rules:
import 'package:dartz/dartz.dart';
import 'package:swp_app/features/topic/data/datasources/topics_remote_datasource.dart';
import 'package:swp_app/features/topic/domain/entities/topic_entity.dart';
import 'package:swp_app/features/topic/domain/entities/topic_detail_entity.dart';
import 'package:swp_app/features/topic/domain/repositories/topics_repository.dart';

class TopicsRepositoryImpl implements TopicsRepository {
  final TopicsRemoteDataSource _remote;
  TopicsRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, PagedEntity<TopicEntity>>> getTopics({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      print(
        '🟠 [TopicsRepositoryImpl] getTopics() called with page=$page, pageSize=$pageSize',
      );
      final res = await _remote.getTopics(page: page, pageSize: pageSize);
      print(
        '🟠 [TopicsRepositoryImpl] Remote call successful, mapping to entities...',
      );
      final items = res.data.items.map((m) => m.toEntity()).toList();
      final paged = PagedEntity<TopicEntity>(
        items: items,
        totalItems: res.data.totalItems,
        currentPage: res.data.currentPage,
        totalPages: res.data.totalPages,
        pageSize: res.data.pageSize,
        hasPreviousPage: res.data.hasPreviousPage,
        hasNextPage: res.data.hasNextPage,
      );
      print(
        '🟠 [TopicsRepositoryImpl] Returning Right with ${items.length} items',
      );
      return Right(paged);
    } catch (e, stackTrace) {
      print('❌ [TopicsRepositoryImpl] Error in getTopics: $e');
      print('❌ [TopicsRepositoryImpl] StackTrace: $stackTrace');
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PagedEntity<TopicEntity>>> getTopicsByLecturer({
    required String lecturerId,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      print(
        '🟠 [TopicsRepositoryImpl] getTopicsByLecturer() called with lecturerId=$lecturerId, page=$page, pageSize=$pageSize',
      );
      final res = await _remote.getTopicsByLecturer(
        lecturerId: lecturerId,
        page: page,
        pageSize: pageSize,
      );
      print(
        '🟠 [TopicsRepositoryImpl] Remote call successful, mapping to entities...',
      );
      final items = res.data.items.map((m) => m.toEntity()).toList();
      final paged = PagedEntity<TopicEntity>(
        items: items,
        totalItems: res.data.totalItems,
        currentPage: res.data.currentPage,
        totalPages: res.data.totalPages,
        pageSize: res.data.pageSize,
        hasPreviousPage: res.data.hasPreviousPage,
        hasNextPage: res.data.hasNextPage,
      );
      print(
        '🟠 [TopicsRepositoryImpl] Returning Right with ${items.length} items',
      );
      return Right(paged);
    } catch (e, stackTrace) {
      print('❌ [TopicsRepositoryImpl] Error in getTopicsByLecturer: $e');
      print('❌ [TopicsRepositoryImpl] StackTrace: $stackTrace');
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TopicDetailEntity>> getTopicById(
    String topicId,
  ) async {
    try {
      print(
        '🟠 [TopicsRepositoryImpl] getTopicById() called with topicId=$topicId',
      );
      final res = await _remote.getTopicById(topicId);
      print(
        '🟠 [TopicsRepositoryImpl] Remote call successful, mapping to entity...',
      );
      final entity = res.data.toEntity();
      print('🟠 [TopicsRepositoryImpl] Returning Right with topic detail');
      return Right(entity);
    } catch (e, stackTrace) {
      print('❌ [TopicsRepositoryImpl] Error in getTopicById: $e');
      print('❌ [TopicsRepositoryImpl] StackTrace: $stackTrace');
      return Left(Failure(e.toString()));
    }
  }
}
