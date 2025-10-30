class DomainEntity {
  final String id;
  final String name;
  final String description;
  final String status; // "Active" ...
  final DateTime createdAt;

  const DomainEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.createdAt,
  });
}

class DomainPage {
  final List<DomainEntity> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  const DomainPage({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });
}
