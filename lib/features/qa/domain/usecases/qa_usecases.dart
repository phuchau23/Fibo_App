// Following project rules:
import 'package:dartz/dartz.dart';
import 'package:swp_app/features/qa/domain/entities/qa_entities.dart';
import 'package:swp_app/features/qa/domain/repositories/qa_repository.dart';

class GetQAPairs {
  final QaRepository _repo;
  GetQAPairs(this._repo);

  Future<Either<QaFailure, QAPagedEntity>> call({
    required String lecturerId,
    String? topicId,
    String? documentId,
    int page = 1,
    int pageSize = 10,
  }) {
    return _repo.getQAPairs(
      lecturerId: lecturerId,
      topicId: topicId,
      documentId: documentId,
      page: page,
      pageSize: pageSize,
    );
  }
}

class GetQAPairById {
  final QaRepository _repo;
  GetQAPairById(this._repo);
  Future<Either<QaFailure, QAPairEntity>> call(String id) =>
      _repo.getQAPairById(id);
}

class CreateQAPair {
  final QaRepository _repo;
  CreateQAPair(this._repo);

  Future<Either<QaFailure, Unit>> call({
    String? topicId,
    String? documentId,
    required String questionText,
    required String answerText,
  }) => _repo.createQAPair(
    topicId: topicId,
    documentId: documentId,
    questionText: questionText,
    answerText: answerText,
  );
}

class UpdateQAPair {
  final QaRepository _repo;
  UpdateQAPair(this._repo);

  Future<Either<QaFailure, Unit>> call({
    required String id,
    required String questionText,
    required String answerText,
  }) => _repo.updateQAPair(
    id: id,
    questionText: questionText,
    answerText: answerText,
  );
}

class DeleteQAPair {
  final QaRepository _repo;
  DeleteQAPair(this._repo);
  Future<Either<QaFailure, Unit>> call(String id) => _repo.deleteQAPair(id);
}
