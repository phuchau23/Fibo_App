// Following project rules:
import 'package:dartz/dartz.dart';
import 'package:swp_app/features/feedback/domain/entities/feedback_entities.dart';
import 'package:swp_app/features/feedback/domain/repositories/feedback_repository.dart';

class GetFeedbacks {
  final FeedbackRepository _repo;
  GetFeedbacks(this._repo);

  Future<Either<FeedbackFailure, FeedbackPagedEntity>> call({
    int page = 1,
    int pageSize = 10,
    String? lecturerId,
    String? topicId,
    String? answerId,
  }) => _repo.getFeedbacks(
    page: page,
    pageSize: pageSize,
    lecturerId: lecturerId,
    topicId: topicId,
    answerId: answerId,
  );
}

class GetFeedbackById {
  final FeedbackRepository _repo;
  GetFeedbackById(this._repo);
  Future<Either<FeedbackFailure, FeedbackEntity>> call(String id) =>
      _repo.getFeedbackById(id);
}

class UpdateFeedback {
  final FeedbackRepository _repo;
  UpdateFeedback(this._repo);

  Future<Either<FeedbackFailure, Unit>> call({
    required String id,
    required String helpful,
    String? comment,
  }) => _repo.updateFeedback(id: id, helpful: helpful, comment: comment);
}

class DeleteFeedback {
  final FeedbackRepository _repo;
  DeleteFeedback(this._repo);
  Future<Either<FeedbackFailure, Unit>> call(String id) =>
      _repo.deleteFeedback(id);
}
