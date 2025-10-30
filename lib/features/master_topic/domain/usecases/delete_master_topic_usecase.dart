import 'package:dartz/dartz.dart';
import 'package:swp_app/features/master_topic/domain/entities/master_topic_entity.dart';
import 'package:swp_app/features/master_topic/domain/repositories/master_topics_repository.dart';

class DeleteMasterTopicUsecase {
  final MasterTopicsRepository repo;
  DeleteMasterTopicUsecase(this.repo);

  Future<Either<Failure, MasterTopicEntity>> call({required String id}) {
    return repo.delete(id: id);
  }
}
