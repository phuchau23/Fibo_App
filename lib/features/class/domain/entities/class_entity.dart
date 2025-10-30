class ClassEntity {
  final String id;
  final String code;
  final String status;
  final DateTime createdAt;
  final String semesterCode; // e.g. SP25
  final String semesterTerm; // e.g. Spring
  final int year; // e.g. 2025

  const ClassEntity({
    required this.id,
    required this.code,
    required this.status,
    required this.createdAt,
    required this.semesterCode,
    required this.semesterTerm,
    required this.year,
  });
}

class ClassPage {
  final List<ClassEntity> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const ClassPage({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });
}
