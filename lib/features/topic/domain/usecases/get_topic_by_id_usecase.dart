// Following project rules:
import 'package:dartz/dartz.dart';
import 'package:swp_app/features/topic/domain/entities/topic_detail_entity.dart';
import 'package:swp_app/features/topic/domain/repositories/topics_repository.dart';

class GetTopicByIdUseCase {
  final TopicsRepository _repo;
  GetTopicByIdUseCase(this._repo);

  Future<Either<Failure, TopicDetailEntity>> call(String topicId) {
    return _repo.getTopicById(topicId);
  }
}
