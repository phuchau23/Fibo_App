// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TopicDetailModel _$TopicDetailModelFromJson(Map<String, dynamic> json) =>
    TopicDetailModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      masterTopic: json['masterTopic'] == null
          ? null
          : MasterTopicModel.fromJson(
              json['masterTopic'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TopicDetailModelToJson(TopicDetailModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'status': instance.status,
      'createdAt': instance.createdAt,
      'masterTopic': instance.masterTopic,
    };

MasterTopicModel _$MasterTopicModelFromJson(Map<String, dynamic> json) =>
    MasterTopicModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      domain: json['domain'] == null
          ? null
          : DomainModel.fromJson(json['domain'] as Map<String, dynamic>),
      semester: json['semester'] == null
          ? null
          : SemesterModel.fromJson(json['semester'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MasterTopicModelToJson(MasterTopicModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'status': instance.status,
      'createdAt': instance.createdAt,
      'domain': instance.domain,
      'semester': instance.semester,
    };

DomainModel _$DomainModelFromJson(Map<String, dynamic> json) => DomainModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$DomainModelToJson(DomainModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'status': instance.status,
      'createdAt': instance.createdAt,
    };

SemesterModel _$SemesterModelFromJson(Map<String, dynamic> json) =>
    SemesterModel(
      id: json['id'] as String,
      code: json['code'] as String,
      term: json['term'] as String,
      year: (json['year'] as num?)?.toInt(),
      status: json['status'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$SemesterModelToJson(SemesterModel instance) =>
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

TopicDetailResponse _$TopicDetailResponseFromJson(Map<String, dynamic> json) =>
    TopicDetailResponse(
      statusCode: (json['statusCode'] as num).toInt(),
      code: json['code'] as String,
      message: json['message'] as String,
      data: TopicDetailModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TopicDetailResponseToJson(
        TopicDetailResponse instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
    };
