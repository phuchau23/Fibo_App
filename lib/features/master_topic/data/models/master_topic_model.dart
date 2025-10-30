import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/master_topic_entity.dart';

part 'master_topic_model.g.dart';

@JsonSerializable(explicitToJson: true)
class _DomainMiniModel {
  final String id;
  final String name;
  final String? description;
  final String status;
  final String createdAt;
  _DomainMiniModel({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    required this.createdAt,
  });

  factory _DomainMiniModel.fromJson(Map<String, dynamic> json) =>
      _$DomainMiniModelFromJson(json);
  Map<String, dynamic> toJson() => _$DomainMiniModelToJson(this);

  DomainMiniEntity toEntity() => DomainMiniEntity(
    id: id,
    name: name,
    description: description,
    status: status,
    createdAt: DateTime.parse(createdAt),
  );
}

@JsonSerializable()
class _SemesterMiniModel {
  final String id;
  final String code;
  final String term;
  final int year;
  final String status;
  final String startDate;
  final String endDate;
  final String createdAt;

  _SemesterMiniModel({
    required this.id,
    required this.code,
    required this.term,
    required this.year,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  factory _SemesterMiniModel.fromJson(Map<String, dynamic> json) =>
      _$SemesterMiniModelFromJson(json);
  Map<String, dynamic> toJson() => _$SemesterMiniModelToJson(this);

  SemesterMiniEntity toEntity() => SemesterMiniEntity(
    id: id,
    code: code,
    term: term,
    year: year,
    status: status,
    startDate: DateTime.parse(startDate),
    endDate: DateTime.parse(endDate),
    createdAt: DateTime.parse(createdAt),
  );
}

@JsonSerializable(explicitToJson: true)
class MasterTopicModel {
  final String id;
  final _DomainMiniModel domain;
  final _SemesterMiniModel? semester;
  final List<dynamic>? lecturers; // API trả [] hiện tại
  final String name;
  final String? description;
  final String status;
  final String createdAt;

  MasterTopicModel({
    required this.id,
    required this.domain,
    this.semester,
    this.lecturers,
    required this.name,
    this.description,
    required this.status,
    required this.createdAt,
  });

  factory MasterTopicModel.fromJson(Map<String, dynamic> json) =>
      _$MasterTopicModelFromJson(json);
  Map<String, dynamic> toJson() => _$MasterTopicModelToJson(this);

  MasterTopicEntity toEntity() => MasterTopicEntity(
    id: id,
    domain: domain.toEntity(),
    semester: semester?.toEntity(),
    lecturerIds:
        const <
          String
        >[], // API body không trả lecturerIds; nếu cần bạn có thể thay bằng map từ lecturers
    name: name,
    description: description,
    status: status,
    createdAt: DateTime.parse(createdAt),
  );
}

@JsonSerializable(genericArgumentFactories: true, explicitToJson: true)
class PageModel<T> {
  final List<T> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  PageModel({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory PageModel.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$PageModelFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$PageModelToJson(this, toJsonT);

  PageEntity<R> toEntity<R>(R Function(T m) mapItem) => PageEntity<R>(
    items: items.map(mapItem).toList(),
    totalItems: totalItems,
    currentPage: currentPage,
    totalPages: totalPages,
    pageSize: pageSize,
    hasPreviousPage: hasPreviousPage,
    hasNextPage: hasNextPage,
  );
}
