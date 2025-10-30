import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:swp_app/features/domains/domain/repositories/domain_repository.dart';
import '../../domain/entities/domain_entity.dart';
import '../datasources/domain_remote_datasource.dart';

class DomainRepositoryImpl implements DomainRepository {
  final DomainRemoteDataSource remote;
  DomainRepositoryImpl(this.remote);

  @override
  Future<Either<String, DomainPage>> getDomains({
    required int page,
    required int pageSize,
  }) async {
    try {
      final model = await remote.getDomains(page: page, pageSize: pageSize);
      return right(model.toEntity());
    } on DioException catch (e) {
      return left(
        e.response?.data?['message']?.toString() ??
            e.message ??
            'Network error',
      );
    } catch (e) {
      return left(e.toString());
    }
  }

  @override
  Future<Either<String, DomainEntity>> createDomain({
    required String name,
    required String description,
  }) async {
    try {
      final model = await remote.createDomain(
        name: name,
        description: description,
      );
      return right(model.toEntity());
    } on DioException catch (e) {
      return left(
        e.response?.data?['message']?.toString() ??
            e.message ??
            'Network error',
      );
    } catch (e) {
      return left(e.toString());
    }
  }

  @override
  Future<Either<String, DomainEntity>> updateDomain({
    required String id,
    required String name,
    required String description,
  }) async {
    try {
      final model = await remote.updateDomain(
        id: id,
        name: name,
        description: description,
      );
      return right(model.toEntity());
    } on DioException catch (e) {
      return left(
        e.response?.data?['message']?.toString() ??
            e.message ??
            'Network error',
      );
    } catch (e) {
      return left(e.toString());
    }
  }

  @override
  Future<Either<String, DomainEntity>> deleteDomain({
    required String id,
  }) async {
    try {
      final model = await remote.deleteDomain(id: id);
      return right(model.toEntity());
    } on DioException catch (e) {
      return left(
        e.response?.data?['message']?.toString() ??
            e.message ??
            'Network error',
      );
    } catch (e) {
      return left(e.toString());
    }
  }
}
