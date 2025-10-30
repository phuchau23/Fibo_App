import 'package:dartz/dartz.dart';
import '../entities/domain_entity.dart';

abstract class DomainRepository {
  Future<Either<String, DomainPage>> getDomains({
    required int page,
    required int pageSize,
  });

  Future<Either<String, DomainEntity>> createDomain({
    required String name,
    required String description,
  });

  Future<Either<String, DomainEntity>> updateDomain({
    required String id,
    required String name,
    required String description,
  });

  Future<Either<String, DomainEntity>> deleteDomain({
    required String id,
  });
}
