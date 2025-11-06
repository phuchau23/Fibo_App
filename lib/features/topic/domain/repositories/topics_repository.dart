// Following project rules:
import 'package:dartz/dartz.dart';
import 'package:swp_app/features/topic/domain/entities/topic_entity.dart';
import 'package:swp_app/features/topic/domain/entities/topic_detail_entity.dart';

abstract class TopicsRepository {
  Future<Either<Failure, PagedEntity<TopicEntity>>> getTopics({
    int page,
    int pageSize,
  });

  Future<Either<Failure, PagedEntity<TopicEntity>>> getTopicsByLecturer({
    required String lecturerId,
    int page,
    int pageSize,
  });

  Future<Either<Failure, TopicDetailEntity>> getTopicById(String topicId);
}

class Failure {
  final String message;
  const Failure(this.message);
}
