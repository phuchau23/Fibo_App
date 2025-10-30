// Following project rules:
import 'package:dartz/dartz.dart';
import 'package:swp_app/features/topic/domain/entities/topic_entity.dart';
import 'package:swp_app/features/topic/domain/repositories/topics_repository.dart';

class GetAllTopicsUseCase {
  final TopicsRepository _repo;
  GetAllTopicsUseCase(this._repo);

  Future<Either<Failure, PagedEntity<TopicEntity>>> call({
    int page = 1,
    int pageSize = 10,
  }) {
    return _repo.getTopics(page: page, pageSize: pageSize);
  }
}
