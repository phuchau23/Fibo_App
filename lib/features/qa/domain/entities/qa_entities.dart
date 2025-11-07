// Following project rules:
class QAPairEntity {
  final String id;
  final String topicId;
  final String? documentId;
  final String createdById;
  final String? verifiedById;
  final String questionText;
  final String answerText;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const QAPairEntity({
    required this.id,
    required this.topicId,
    this.documentId,
    required this.createdById,
    this.verifiedById,
    required this.questionText,
    required this.answerText,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
}

class QAPagedEntity {
  final List<QAPairEntity> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  const QAPagedEntity({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });
}
