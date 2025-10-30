import 'package:dartz/dartz.dart';
import '../entities/domain_entity.dart';
import '../repositories/domain_repository.dart';

class UpdateDomain {
  final DomainRepository repo;
  UpdateDomain(this.repo);

  Future<Either<String, DomainEntity>> call({
    required String id,
    required String name,
    required String description,
  }) {
    return repo.updateDomain(id: id, name: name, description: description);
  }
}
