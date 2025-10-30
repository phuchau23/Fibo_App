import 'package:dartz/dartz.dart';
import '../entities/domain_entity.dart';
import '../repositories/domain_repository.dart';

class CreateDomain {
  final DomainRepository repo;
  CreateDomain(this.repo);

  Future<Either<String, DomainEntity>> call({
    required String name,
    required String description,
  }) {
    return repo.createDomain(name: name, description: description);
  }
}
