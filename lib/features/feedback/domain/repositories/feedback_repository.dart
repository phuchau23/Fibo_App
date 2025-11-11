// Following project rules:
import 'package:dartz/dartz.dart';
import 'package:swp_app/features/feedback/domain/entities/feedback_entities.dart';

class FeedbackFailure {
  final String message;
  FeedbackFailure(this.message);
}

abstract class FeedbackRepository {
  Future<Either<FeedbackFailure, FeedbackPagedEntity>> getFeedbacks({
    int page,
    int pageSize,
    String? lecturerId,
    String? topicId,
    String? answerId,
  });

  Future<Either<FeedbackFailure, FeedbackEntity>> getFeedbackById(String id);

  Future<Either<FeedbackFailure, Unit>> updateFeedback({
    required String id,
    required String helpful,
    String? comment,
  });

  Future<Either<FeedbackFailure, Unit>> deleteFeedback(String id);
}
