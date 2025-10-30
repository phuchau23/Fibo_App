// Following project rules:
class TopicEntity {
  final String id;
  final String name;
  final String? description;
  final String status;
  final DateTime createdAt;

  const TopicEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.createdAt,
  });
}

class PagedEntity<T> {
  final List<T> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  const PagedEntity({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });
}
