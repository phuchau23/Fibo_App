import 'package:dartz/dartz.dart';
import '../entities/master_topic_entity.dart';
import '../repositories/master_topics_repository.dart';

class CreateMasterTopicUseCase {
  final MasterTopicsRepository repo;
  CreateMasterTopicUseCase(this.repo);

  Future<Either<Failure, MasterTopicEntity>> call({
    required String domainId,
    String? semesterId,
    required List<String> lecturerIds,
    required String name,
    String? description,
  }) {
    return repo.create(
      domainId: domainId,
      semesterId: semesterId,
      lecturerIds: lecturerIds,
      name: name,
      description: description,
    );
  }
}
