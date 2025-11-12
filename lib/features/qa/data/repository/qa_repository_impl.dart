// Following project rules:
import 'package:dartz/dartz.dart';
import 'package:swp_app/features/qa/data/datasources/qa_remote_datasource.dart';
import 'package:swp_app/features/qa/data/models/qa_models.dart';
import 'package:swp_app/features/qa/domain/entities/qa_entities.dart';
import 'package:swp_app/features/qa/domain/repositories/qa_repository.dart';

class QaRepositoryImpl implements QaRepository {
  final QARemoteDataSource _remote;
  QaRepositoryImpl(this._remote);

  @override
  Future<Either<QaFailure, Unit>> createQAPair({
    String? topicId,
    String? documentId,
    required String questionText,
    required String answerText,
  }) async {
    try {
      await _remote.createQAPair(
        topicId: topicId,
        documentId: documentId,
        questionText: questionText,
        answerText: answerText,
      );
      return const Right(unit);
    } catch (e) {
      return Left(QaFailure(e.toString()));
    }
  }

  @override
  Future<Either<QaFailure, Unit>> deleteQAPair(String id) async {
    try {
      await _remote.deleteQAPair(id);
      return const Right(unit);
    } catch (e) {
      return Left(QaFailure(e.toString()));
    }
  }

  @override
  Future<Either<QaFailure, QAPairEntity>> getQAPairById(String id) async {
    try {
      final res = await _remote.getQAPairById(id);
      return Right(_mapModel(res.data));
    } catch (e) {
      return Left(QaFailure(e.toString()));
    }
  }

  @override
  Future<Either<QaFailure, QAPagedEntity>> getQAPairs({
    required String lecturerId,
    String? topicId,
    String? documentId,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final res = await _remote.getQAPairs(
        lecturerId: lecturerId,
        topicId: topicId,
        documentId: documentId,
        page: page,
        pageSize: pageSize,
      );
      return Right(
        QAPagedEntity(
          items: res.data.items.map(_mapModel).toList(),
          totalItems: res.data.totalItems,
          currentPage: res.data.currentPage,
          totalPages: res.data.totalPages,
          pageSize: res.data.pageSize,
          hasPreviousPage: res.data.hasPreviousPage,
          hasNextPage: res.data.hasNextPage,
        ),
      );
    } catch (e) {
      return Left(QaFailure(e.toString()));
    }
  }

  @override
  Future<Either<QaFailure, Unit>> updateQAPair({
    required String id,
    required String questionText,
    required String answerText,
  }) async {
    try {
      await _remote.updateQAPair(
        id: id,
        questionText: questionText,
        answerText: answerText,
      );
      return const Right(unit);
    } catch (e) {
      return Left(QaFailure(e.toString()));
    }
  }

  QAPairEntity _mapModel(QAPairModel model) => QAPairEntity(
    id: model.id,
    topicId: model.topicId,
    documentId: model.documentId,
    createdById: model.createdById,
    verifiedById: model.verifiedById,
    questionText: model.questionText,
    answerText: model.answerText,
    status: model.status,
    createdAt: DateTime.parse(model.createdAt),
    updatedAt: DateTime.parse(model.updatedAt),
  );
}
