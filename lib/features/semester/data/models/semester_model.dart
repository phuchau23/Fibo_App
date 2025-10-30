import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/semester_entity.dart';

part 'semester_model.g.dart';

@JsonSerializable()
class SemesterModel {
  final String id;
  final String code;
  final String term;
  final int year;

  SemesterModel({
    required this.id,
    required this.code,
    required this.term,
    required this.year,
  });

  factory SemesterModel.fromJson(Map<String, dynamic> json) =>
      _$SemesterModelFromJson(json);

  Map<String, dynamic> toJson() => _$SemesterModelToJson(this);

  SemesterEntity toEntity() =>
      SemesterEntity(id: id, code: code, term: term, year: year);
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
}
