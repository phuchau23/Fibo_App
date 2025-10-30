// Following project rules:
import 'package:dartz/dartz.dart';
import 'package:swp_app/features/topic/data/datasources/topics_remote_datasource.dart';
import 'package:swp_app/features/topic/domain/entities/topic_entity.dart';
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
      final res = await _remote.getTopics(page: page, pageSize: pageSize);
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
      return Right(paged);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
