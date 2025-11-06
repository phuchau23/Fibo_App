// Following project rules:
import 'package:json_annotation/json_annotation.dart';
import 'package:swp_app/features/topic/domain/entities/topic_detail_entity.dart';

part 'topic_detail_model.g.dart';

@JsonSerializable()
class TopicDetailModel {
  final String id;
  final String name;
  final String? description;
  final String status;
  final String createdAt;
  final MasterTopicModel? masterTopic;

  TopicDetailModel({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    required this.createdAt,
    this.masterTopic,
  });

  factory TopicDetailModel.fromJson(Map<String, dynamic> json) =>
      _$TopicDetailModelFromJson(json);
  Map<String, dynamic> toJson() => _$TopicDetailModelToJson(this);

  TopicDetailEntity toEntity() => TopicDetailEntity(
    id: id,
    name: name,
    description: description,
    status: status,
    createdAt: DateTime.parse(createdAt),
    masterTopic: masterTopic?.toEntity(),
  );
}

@JsonSerializable()
class MasterTopicModel {
  final String id;
  final String name;
  final String? description;
  final String status;
  final String createdAt;
  final DomainModel? domain;
  final SemesterModel? semester;

  MasterTopicModel({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    required this.createdAt,
    this.domain,
    this.semester,
  });

  factory MasterTopicModel.fromJson(Map<String, dynamic> json) =>
      _$MasterTopicModelFromJson(json);
  Map<String, dynamic> toJson() => _$MasterTopicModelToJson(this);

  MasterTopicEntity toEntity() => MasterTopicEntity(
    id: id,
    name: name,
    description: description,
    status: status,
    createdAt: DateTime.parse(createdAt),
    domain: domain?.toEntity(),
    semester: semester?.toEntity(),
  );
}

@JsonSerializable()
class DomainModel {
  final String id;
  final String name;
  final String? description;
  final String status;
  final String createdAt;

  DomainModel({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    required this.createdAt,
  });

  factory DomainModel.fromJson(Map<String, dynamic> json) =>
      _$DomainModelFromJson(json);
  Map<String, dynamic> toJson() => _$DomainModelToJson(this);

  DomainEntity toEntity() => DomainEntity(
    id: id,
    name: name,
    description: description,
    status: status,
    createdAt: DateTime.parse(createdAt),
  );
}

@JsonSerializable()
class SemesterModel {
  final String id;
  final String code;
  final String term;
  final int? year;
  final String? status;
  final String? startDate;
  final String? endDate;
  final String? createdAt;

  SemesterModel({
    required this.id,
    required this.code,
    required this.term,
    this.year,
    this.status,
    this.startDate,
    this.endDate,
    this.createdAt,
  });

  factory SemesterModel.fromJson(Map<String, dynamic> json) =>
      _$SemesterModelFromJson(json);
  Map<String, dynamic> toJson() => _$SemesterModelToJson(this);

  SemesterEntity toEntity() => SemesterEntity(
    id: id,
    code: code,
    term: term,
    year: year,
    status: status,
    startDate: startDate != null ? DateTime.parse(startDate!) : null,
    endDate: endDate != null ? DateTime.parse(endDate!) : null,
    createdAt: createdAt != null ? DateTime.parse(createdAt!) : null,
  );
}

@JsonSerializable()
class TopicDetailResponse {
  final int statusCode;
  final String code;
  final String message;
  final TopicDetailModel data;

  TopicDetailResponse({
    required this.statusCode,
    required this.code,
    required this.message,
    required this.data,
  });

  factory TopicDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$TopicDetailResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TopicDetailResponseToJson(this);
}
