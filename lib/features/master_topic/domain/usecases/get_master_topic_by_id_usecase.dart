import 'package:dartz/dartz.dart';
import '../entities/master_topic_entity.dart';
import '../repositories/master_topics_repository.dart';

class GetMasterTopicByIdUseCase {
  final MasterTopicsRepository repo;
  GetMasterTopicByIdUseCase(this.repo);

  Future<Either<Failure, MasterTopicEntity>> call(String id) =>
      repo.getById(id);
}
