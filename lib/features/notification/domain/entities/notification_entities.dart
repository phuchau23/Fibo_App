class NotificationEntity {
  final String id;
  final String type;
  final String title;
  final String description;
  final String icon;
  final String? relatedEntityId;
  final String? relatedEntityType;
  final DateTime createdAt;
  final bool isNew;
  final Map<String, dynamic>? data;

  NotificationEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    this.relatedEntityId,
    this.relatedEntityType,
    required this.createdAt,
    required this.isNew,
    this.data,
  });
}

class NotificationPagedEntity {
  final List<NotificationEntity> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  NotificationPagedEntity({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });
}

