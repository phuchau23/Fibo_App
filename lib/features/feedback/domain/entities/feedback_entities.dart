// Following project rules:
class FeedbackEntity {
  final String id;
  final FeedbackUserEntity user;
  final FeedbackAnswerEntity? answer;
  final FeedbackTopicEntity? topic;
  final String helpful;
  final String? comment;
  final DateTime createdAt;

  const FeedbackEntity({
    required this.id,
    required this.user,
    this.answer,
    this.topic,
    required this.helpful,
    this.comment,
    required this.createdAt,
  });
}

class FeedbackUserEntity {
  final String id;
  final String firstName;
  final String lastName;
  final String? studentId;
  final String email;
  final String role;
  final FeedbackClassEntity? classInfo;
  final FeedbackGroupEntity? group;

  const FeedbackUserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.studentId,
    required this.email,
    required this.role,
    this.classInfo,
    this.group,
  });
}

class FeedbackClassEntity {
  final String id;
  final String? code;
  final FeedbackLecturerEntity? lecturer;
  final String status;

  const FeedbackClassEntity({
    required this.id,
    this.code,
    this.lecturer,
    required this.status,
  });
}

class FeedbackLecturerEntity {
  final String id;
  final String? fullName;

  const FeedbackLecturerEntity({required this.id, this.fullName});
}

class FeedbackGroupEntity {
  final String id;
  final String? name;

  const FeedbackGroupEntity({required this.id, this.name});
}

class FeedbackAnswerEntity {
  final String id;
  final String? content;

  const FeedbackAnswerEntity({required this.id, this.content});
}

class FeedbackTopicEntity {
  final String id;
  final String? name;

  const FeedbackTopicEntity({required this.id, this.name});
}

class FeedbackPagedEntity {
  final List<FeedbackEntity> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  const FeedbackPagedEntity({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });
}
