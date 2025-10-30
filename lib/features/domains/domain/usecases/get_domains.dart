import 'package:dartz/dartz.dart';
import '../entities/domain_entity.dart';
import '../repositories/domain_repository.dart';

class GetDomains {
  final DomainRepository repo;
  GetDomains(this.repo);

  Future<Either<String, DomainPage>> call({
    required int page,
    required int pageSize,
  }) {
    return repo.getDomains(page: page, pageSize: pageSize);
  }
}
