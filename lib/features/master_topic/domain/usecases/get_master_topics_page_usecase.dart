import 'package:dartz/dartz.dart';
import '../entities/master_topic_entity.dart';
import '../repositories/master_topics_repository.dart';

class GetMasterTopicsPageUseCase {
  final MasterTopicsRepository repo;
  GetMasterTopicsPageUseCase(this.repo);

  Future<Either<Failure, PageEntity<MasterTopicEntity>>> call({
    int page = 1,
    int pageSize = 10,
  }) {
    return repo.getAll(page: page, pageSize: pageSize);
  }
}
