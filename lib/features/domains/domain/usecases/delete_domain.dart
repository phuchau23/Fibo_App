import 'package:dartz/dartz.dart';
import '../entities/domain_entity.dart';
import '../repositories/domain_repository.dart';

class DeleteDomain {
  final DomainRepository repo;
  DeleteDomain(this.repo);

  Future<Either<String, DomainEntity>> call({required String id}) {
    return repo.deleteDomain(id: id);
  }
}
