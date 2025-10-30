import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/group_entity.dart';

part 'group_model.g.dart';

@JsonSerializable()
class GroupModel {
  final String id;
  final String classId;
  final String name;
  final String? description;
  final DateTime createdAt;

  GroupModel({
    required this.id,
    required this.classId,
    required this.name,
    this.description,
    required this.createdAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) =>
      _$GroupModelFromJson(json);
  Map<String, dynamic> toJson() => _$GroupModelToJson(this);

  GroupEntity toEntity() => GroupEntity(
    id: id,
    classId: classId,
    name: name,
    description: description,
    createdAt: createdAt,
  );
}

// Helper for paginated list from data.items[] wrapper
@JsonSerializable()
class GroupListResponse {
  final int statusCode;
  final String code;
  final String message;
  final _GroupListData data;
  GroupListResponse({
    required this.statusCode,
    required this.code,
    required this.message,
    required this.data,
  });
  factory GroupListResponse.fromJson(Map<String, dynamic> json) =>
      _$GroupListResponseFromJson(json);
}

@JsonSerializable()
class _GroupListData {
  final List<GroupModel> items;
  _GroupListData({required this.items});
  factory _GroupListData.fromJson(Map<String, dynamic> json) =>
      _$GroupListDataFromJson(json);
}
