// Following project rules:
import 'package:json_annotation/json_annotation.dart';
import 'package:swp_app/features/topic/domain/entities/topic_entity.dart';

part 'topic_model.g.dart';

@JsonSerializable()
class TopicModel {
  final String id;
  final String name;
  final String? description;
  final String status;
  final String createdAt;

  TopicModel({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    required this.createdAt,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) =>
      _$TopicModelFromJson(json);
  Map<String, dynamic> toJson() => _$TopicModelToJson(this);

  TopicEntity toEntity() => TopicEntity(
    id: id,
    name: name,
    description: description,
    status: status,
    createdAt: DateTime.parse(createdAt),
  );
}
