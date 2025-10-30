import 'package:dartz/dartz.dart';
import '../entities/master_topic_entity.dart';

abstract class MasterTopicsRepository {
  Future<Either<Failure, PageEntity<MasterTopicEntity>>> getAll({
    int page = 1,
    int pageSize = 10,
  });
  Future<Either<Failure, MasterTopicEntity>> getById(String id);
  Future<Either<Failure, MasterTopicEntity>> create({
    required String domainId,
    String? semesterId,
    required List<String> lecturerIds,
    required String name,
    String? description,
  });
  Future<Either<Failure, MasterTopicEntity>> update({
    required String id,
    required String domainId,
    String? semesterId,
    required List<String> lecturerIds,
    required String name,
    String? description,
  });

  Future<Either<Failure, MasterTopicEntity>> delete({required String id});
}

/// Domain-level Failure (map từ Dio/network exception)
class Failure {
  final String message;
  final int? statusCode;
  Failure(this.message, {this.statusCode});
}
