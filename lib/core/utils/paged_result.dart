class PagedResult<T> {
  final List<T> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  const PagedResult({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  static PagedResult<T> fromEnvelope<T>(
    Map<String, dynamic> envelope, {
    required T Function(Map<String, dynamic>) parseItem,
  }) {
    final d = envelope['data'] as Map<String, dynamic>;
    final items = (d['items'] as List)
        .cast<Map<String, dynamic>>()
        .map(parseItem)
        .toList();
    return PagedResult<T>(
      items: items,
      totalItems: d['totalItems'] ?? 0,
      currentPage: d['currentPage'] ?? 1,
      totalPages: d['totalPages'] ?? 1,
      pageSize: d['pageSize'] ?? items.length,
      hasPreviousPage: d['hasPreviousPage'] ?? false,
      hasNextPage: d['hasNextPage'] ?? false,
    );
  }
}
