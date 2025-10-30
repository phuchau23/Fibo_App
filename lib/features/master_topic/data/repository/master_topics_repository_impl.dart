import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:swp_app/features/master_topic/data/datasource/master_topics_remote_datasource.dart';
import '../../domain/entities/master_topic_entity.dart';
import '../../domain/repositories/master_topics_repository.dart';
import '../models/master_topic_model.dart';

class MasterTopicsRepositoryImpl implements MasterTopicsRepository {
  final MasterTopicsRemoteDataSource remote;
  MasterTopicsRepositoryImpl(this.remote);

  Failure _mapError(Object e) {
    if (e is DioException) {
      final status = e.response?.statusCode;
      final msg =
          e.response?.data is Map && (e.response?.data['message'] != null)
          ? e.response?.data['message'].toString()
          : e.message ?? 'Network error';
      return Failure(msg!, statusCode: status);
    }
    return Failure(e.toString());
  }

  @override
  Future<Either<Failure, PageEntity<MasterTopicEntity>>> getAll({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final pageModel = await remote.getAll(page: page, pageSize: pageSize);
      final pageEntity = pageModel.toEntity<MasterTopicEntity>(
        (m) => (m as MasterTopicModel).toEntity(),
      );
      return Right(pageEntity);
    } catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, MasterTopicEntity>> getById(String id) async {
    try {
      final m = await remote.getById(id);
      return Right(m.toEntity());
    } catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, MasterTopicEntity>> create({
    required String domainId,
    String? semesterId,
    required List<String> lecturerIds,
    required String name,
    String? description,
  }) async {
    try {
      final m = await remote.create(
        domainId: domainId,
        semesterId: semesterId,
        lecturerIds: lecturerIds,
        name: name,
        description: description,
      );
      return Right(m.toEntity());
    } catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, MasterTopicEntity>> update({
    required String id,
    required String domainId,
    String? semesterId,
    required List<String> lecturerIds,
    required String name,
    String? description,
  }) async {
    try {
      final m = await remote.update(
        id: id,
        domainId: domainId,
        semesterId: semesterId,
        lecturerIds: lecturerIds,
        name: name,
        description: description,
      );
      return Right(m.toEntity());
    } catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, MasterTopicEntity>> delete({required String id}) async {
    try {
      final m = await remote.delete(id: id);
      return Right(m.toEntity());
    } catch (e) {
      return Left(_mapError(e));
    }
  }
}
