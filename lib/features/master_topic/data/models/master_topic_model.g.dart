// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'master_topic_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DomainMiniModel _$DomainMiniModelFromJson(Map<String, dynamic> json) =>
    _DomainMiniModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$DomainMiniModelToJson(_DomainMiniModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'status': instance.status,
      'createdAt': instance.createdAt,
    };

_SemesterMiniModel _$SemesterMiniModelFromJson(Map<String, dynamic> json) =>
    _SemesterMiniModel(
      id: json['id'] as String,
      code: json['code'] as String,
      term: json['term'] as String,
      year: (json['year'] as num).toInt(),
      status: json['status'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$SemesterMiniModelToJson(_SemesterMiniModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'term': instance.term,
      'year': instance.year,
      'status': instance.status,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'createdAt': instance.createdAt,
    };

MasterTopicModel _$MasterTopicModelFromJson(Map<String, dynamic> json) =>
    MasterTopicModel(
      id: json['id'] as String,
      domain: _DomainMiniModel.fromJson(json['domain'] as Map<String, dynamic>),
      semester: json['semester'] == null
          ? null
          : _SemesterMiniModel.fromJson(
              json['semester'] as Map<String, dynamic>),
      lecturers: json['lecturers'] as List<dynamic>?,
      name: json['name'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$MasterTopicModelToJson(MasterTopicModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'domain': instance.domain.toJson(),
      'semester': instance.semester?.toJson(),
      'lecturers': instance.lecturers,
      'name': instance.name,
      'description': instance.description,
      'status': instance.status,
      'createdAt': instance.createdAt,
    };

PageModel<T> _$PageModelFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    PageModel<T>(
      items: (json['items'] as List<dynamic>).map(fromJsonT).toList(),
      totalItems: (json['totalItems'] as num).toInt(),
      currentPage: (json['currentPage'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      hasPreviousPage: json['hasPreviousPage'] as bool,
      hasNextPage: json['hasNextPage'] as bool,
    );

Map<String, dynamic> _$PageModelToJson<T>(
  PageModel<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'items': instance.items.map(toJsonT).toList(),
      'totalItems': instance.totalItems,
      'currentPage': instance.currentPage,
      'totalPages': instance.totalPages,
      'pageSize': instance.pageSize,
      'hasPreviousPage': instance.hasPreviousPage,
      'hasNextPage': instance.hasNextPage,
    };
