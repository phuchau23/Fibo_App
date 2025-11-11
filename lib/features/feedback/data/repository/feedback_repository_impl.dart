// Following project rules:
import 'package:dartz/dartz.dart';
import 'package:swp_app/features/feedback/data/datasources/feedback_remote_datasource.dart';
import 'package:swp_app/features/feedback/data/models/feedback_models.dart';
import 'package:swp_app/features/feedback/domain/entities/feedback_entities.dart';
import 'package:swp_app/features/feedback/domain/repositories/feedback_repository.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {
  final FeedbackRemoteDataSource _remote;
  FeedbackRepositoryImpl(this._remote);

  @override
  Future<Either<FeedbackFailure, Unit>> deleteFeedback(String id) async {
    try {
      await _remote.deleteFeedback(id);
      return const Right(unit);
    } catch (e) {
      return Left(FeedbackFailure(e.toString()));
    }
  }

  @override
  Future<Either<FeedbackFailure, FeedbackEntity>> getFeedbackById(
    String id,
  ) async {
    try {
      final model = await _remote.getFeedbackById(id);
      return Right(_mapModel(model));
    } catch (e) {
      return Left(FeedbackFailure(e.toString()));
    }
  }

  @override
  Future<Either<FeedbackFailure, FeedbackPagedEntity>> getFeedbacks({
    int page = 1,
    int pageSize = 10,
    String? lecturerId,
    String? topicId,
    String? answerId,
  }) async {
    try {
      PagedFeedbackResponse res;
      if (answerId != null) {
        res = await _remote.getFeedbacksByAnswer(
          answerId,
          page: page,
          pageSize: pageSize,
        );
      } else if (topicId != null) {
        res = await _remote.getFeedbacksByTopic(
          topicId,
          page: page,
          pageSize: pageSize,
        );
      } else if (lecturerId != null) {
        res = await _remote.getFeedbacksByLecturer(
          lecturerId,
          page: page,
          pageSize: pageSize,
        );
      } else {
        res = await _remote.getFeedbacks(page: page, pageSize: pageSize);
      }
      return Right(
        FeedbackPagedEntity(
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
      return Left(FeedbackFailure(e.toString()));
    }
  }

  @override
  Future<Either<FeedbackFailure, Unit>> updateFeedback({
    required String id,
    required String helpful,
    String? comment,
  }) async {
    try {
      await _remote.updateFeedback(id: id, helpful: helpful, comment: comment);
      return const Right(unit);
    } catch (e) {
      return Left(FeedbackFailure(e.toString()));
    }
  }

  FeedbackEntity _mapModel(FeedbackModel model) => FeedbackEntity(
    id: model.id,
    user: FeedbackUserEntity(
      id: model.user.id,
      firstName: model.user.firstName,
      lastName: model.user.lastName,
      studentId: model.user.studentID,
      email: model.user.email,
      role: model.user.role,
      classInfo: model.user.classInfo == null
          ? null
          : FeedbackClassEntity(
              id: model.user.classInfo!.id,
              code: model.user.classInfo!.code,
              lecturer: model.user.classInfo!.lecturer == null
                  ? null
                  : FeedbackLecturerEntity(
                      id: model.user.classInfo!.lecturer!.id,
                      fullName: model.user.classInfo!.lecturer!.fullName,
                    ),
              status: model.user.classInfo!.status,
            ),
      group: model.user.group == null
          ? null
          : FeedbackGroupEntity(
              id: model.user.group!.id,
              name: model.user.group!.name,
            ),
    ),
    answer: model.answer == null
        ? null
        : FeedbackAnswerEntity(
            id: model.answer!.id,
            content: model.answer!.content,
          ),
    topic: model.topic == null
        ? null
        : FeedbackTopicEntity(id: model.topic!.id, name: model.topic!.name),
    helpful: model.helpful,
    comment: model.comment,
    createdAt: DateTime.parse(model.createdAt),
  );
}
