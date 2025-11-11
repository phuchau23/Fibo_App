// Following project rules:
import 'package:dartz/dartz.dart';
import 'package:swp_app/features/qa/domain/entities/qa_entities.dart';

class QaFailure {
  final String message;
  QaFailure(this.message);
}

abstract class QaRepository {
  Future<Either<QaFailure, QAPagedEntity>> getQAPairs({
    String? topicId,
    String? documentId,
    int page,
    int pageSize,
  });

  Future<Either<QaFailure, QAPairEntity>> getQAPairById(String id);

  Future<Either<QaFailure, Unit>> createQAPair({
    required String topicId,
    String? documentId,
    required String questionText,
    required String answerText,
  });

  Future<Either<QaFailure, Unit>> updateQAPair({
    required String id,
    required String questionText,
    required String answerText,
  });

  Future<Either<QaFailure, Unit>> deleteQAPair(String id);
}
