import 'package:equatable/equatable.dart';

class DomainMiniEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String status;
  final DateTime createdAt;

  const DomainMiniEntity({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, description, status, createdAt];
}

class SemesterMiniEntity extends Equatable {
  final String id;
  final String code;
  final String term;
  final int year;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;

  const SemesterMiniEntity({
    required this.id,
    required this.code,
    required this.term,
    required this.year,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    code,
    term,
    year,
    status,
    startDate,
    endDate,
    createdAt,
  ];
}

class MasterTopicEntity extends Equatable {
  final String id;
  final DomainMiniEntity domain;
  final SemesterMiniEntity? semester;
  final List<String>
  lecturerIds; // API trả về mảng lecturers rỗng – để đơn giản hóa UI CRUD ta nắm IDs
  final String name;
  final String? description;
  final String status;
  final DateTime createdAt;

  const MasterTopicEntity({
    required this.id,
    required this.domain,
    this.semester,
    required this.lecturerIds,
    required this.name,
    this.description,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    domain,
    semester,
    lecturerIds,
    name,
    description,
    status,
    createdAt,
  ];
}

class PageEntity<T> extends Equatable {
  final List<T> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  const PageEntity({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  @override
  List<Object?> get props => [
    items,
    totalItems,
    currentPage,
    totalPages,
    pageSize,
    hasPreviousPage,
    hasNextPage,
  ];
}
