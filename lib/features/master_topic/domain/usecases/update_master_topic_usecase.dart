import 'package:dartz/dartz.dart';
import '../entities/master_topic_entity.dart';
import '../repositories/master_topics_repository.dart';

class UpdateMasterTopicUseCase {
  final MasterTopicsRepository repo;
  UpdateMasterTopicUseCase(this.repo);

  Future<Either<Failure, MasterTopicEntity>> call({
    required String id,
    required String domainId,
    String? semesterId,
    required List<String> lecturerIds,
    required String name,
    String? description,
  }) {
    return repo.update(
      id: id,
      domainId: domainId,
      semesterId: semesterId,
      lecturerIds: lecturerIds,
      name: name,
      description: description,
    );
  }
}
