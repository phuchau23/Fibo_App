import 'package:json_annotation/json_annotation.dart';
import 'package:swp_app/features/class/domain/entities/class_entity.dart';

part 'class_models.g.dart';

@JsonSerializable()
class ClassResponseEnvelope {
  final int statusCode;
  final String code;
  final String message;
  final ClassResponseData data;

  ClassResponseEnvelope({
    required this.statusCode,
    required this.code,
    required this.message,
    required this.data,
  });

  factory ClassResponseEnvelope.fromJson(Map<String, dynamic> json) =>
      _$ClassResponseEnvelopeFromJson(json);
  Map<String, dynamic> toJson() => _$ClassResponseEnvelopeToJson(this);
}

@JsonSerializable()
class ClassResponseData {
  final List<ClassItemModel> items;
  @JsonKey(defaultValue: 0)
  final int totalItems;
  @JsonKey(defaultValue: 1)
  final int currentPage;
  @JsonKey(defaultValue: 1)
  final int totalPages;
  @JsonKey(defaultValue: 10)
  final int pageSize;
  @JsonKey(defaultValue: false)
  final bool hasPreviousPage;
  @JsonKey(defaultValue: false)
  final bool hasNextPage;

  ClassResponseData({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory ClassResponseData.fromJson(Map<String, dynamic> json) =>
      _$ClassResponseDataFromJson(json);
  Map<String, dynamic> toJson() => _$ClassResponseDataToJson(this);
}

@JsonSerializable()
class ClassItemModel {
  final String id;
  final String code;
  final String status;
  final DateTime createdAt;
  final SemesterModel semester;

  ClassItemModel({
    required this.id,
    required this.code,
    required this.status,
    required this.createdAt,
    required this.semester,
  });

  factory ClassItemModel.fromJson(Map<String, dynamic> json) =>
      _$ClassItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$ClassItemModelToJson(this);
}

@JsonSerializable()
class SemesterModel {
  final String id;
  final String code; // e.g. SP25
  final String term; // Spring
  final int year; // 2025
  final DateTime createdAt;

  SemesterModel({
    required this.id,
    required this.code,
    required this.term,
    required this.year,
    required this.createdAt,
  });

  factory SemesterModel.fromJson(Map<String, dynamic> json) =>
      _$SemesterModelFromJson(json);
  Map<String, dynamic> toJson() => _$SemesterModelToJson(this);
}

// Mapper to Domain
extension ClassResponseDataX on ClassResponseData {
  ClassPage toEntity() => ClassPage(
    items: items
        .map(
          (m) => ClassEntity(
            id: m.id,
            code: m.code,
            status: m.status,
            createdAt: m.createdAt,
            semesterCode: m.semester.code,
            semesterTerm: m.semester.term,
            year: m.semester.year,
          ),
        )
        .toList(),
    totalItems: totalItems,
    currentPage: currentPage,
    totalPages: totalPages,
    pageSize: pageSize,
    hasNextPage: hasNextPage,
    hasPreviousPage: hasPreviousPage,
  );
}
