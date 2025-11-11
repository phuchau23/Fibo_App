import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/group_entity.dart';

part 'group_model.g.dart';

@JsonSerializable()
class GroupModel {
  final String id;
  final String name;
  final String? description;
  final String status;
  final DateTime createdAt;
  @JsonKey(name: 'class')
  final GroupClassModel classInfo;
  final GroupTopicModel? topic;

  GroupModel({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    required this.createdAt,
    required this.classInfo,
    this.topic,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) => GroupModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        status: json['status'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        classInfo: GroupClassModel.fromJson(json['class'] as Map<String, dynamic>),
        topic: json['topic'] != null
            ? GroupTopicModel.fromJson(json['topic'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'class': classInfo.toJson(),
        'topic': topic?.toJson(),
      };

  GroupEntity toEntity() => GroupEntity(
        id: id,
        name: name,
        description: description,
        status: status,
        createdAt: createdAt,
        classInfo: GroupClassEntity(
          id: classInfo.id,
          code: classInfo.code,
          status: classInfo.status,
          createdAt: classInfo.createdAt,
          lecturer: GroupLecturerEntity(
            id: classInfo.lecturer.id,
            fullName: classInfo.lecturer.fullName,
          ),
          semester: GroupSemesterEntity(
            id: classInfo.semester.id,
            code: classInfo.semester.code,
            term: classInfo.semester.term,
            year: classInfo.semester.year,
            createdAt: classInfo.semester.createdAt,
          ),
        ),
        topic: topic != null
            ? GroupTopicEntity(
                id: topic!.id,
                name: topic!.name,
                description: topic!.description,
                masterTopic: topic!.masterTopic != null
                    ? GroupMasterTopicEntity(
                        id: topic!.masterTopic!.id,
                        name: topic!.masterTopic!.name,
                        description: topic!.masterTopic!.description,
                      )
                    : null,
              )
            : null,
      );
}

@JsonSerializable()
class GroupClassModel {
  final String id;
  final String code;
  final String status;
  final DateTime createdAt;
  final GroupLecturerModel lecturer;
  final GroupSemesterModel semester;

  GroupClassModel({
    required this.id,
    required this.code,
    required this.status,
    required this.createdAt,
    required this.lecturer,
    required this.semester,
  });

  factory GroupClassModel.fromJson(Map<String, dynamic> json) => GroupClassModel(
        id: json['id'] as String,
        code: json['code'] as String,
        status: json['status'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        lecturer: GroupLecturerModel.fromJson(json['lecturer'] as Map<String, dynamic>),
        semester: GroupSemesterModel.fromJson(json['semester'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'lecturer': lecturer.toJson(),
        'semester': semester.toJson(),
      };

  // Removed toEntity as it's now handled directly in GroupModel.toEntity()
}

@JsonSerializable()
class GroupLecturerModel {
  final String id;
  @JsonKey(name: 'fullName')
  final String fullName;

  GroupLecturerModel({
    required this.id,
    required this.fullName,
  });

  factory GroupLecturerModel.fromJson(Map<String, dynamic> json) => GroupLecturerModel(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
      };

  // Removed toEntity as it's now handled directly in GroupModel.toEntity()
}

@JsonSerializable()
class GroupSemesterModel {
  final String id;
  final String code;
  final String term;
  final int year;
  final DateTime createdAt;

  GroupSemesterModel({
    required this.id,
    required this.code,
    required this.term,
    required this.year,
    required this.createdAt,
  });

  factory GroupSemesterModel.fromJson(Map<String, dynamic> json) => GroupSemesterModel(
        id: json['id'] as String,
        code: json['code'] as String,
        term: json['term'] as String,
        year: json['year'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'term': term,
        'year': year,
        'createdAt': createdAt.toIso8601String(),
      };

  // Removed toEntity as it's now handled directly in GroupModel.toEntity()
}

@JsonSerializable()
class GroupTopicModel {
  final String id;
  final String name;
  final String? description;
  final GroupMasterTopicModel? masterTopic;

  GroupTopicModel({
    required this.id,
    required this.name,
    this.description,
    this.masterTopic,
  });

  factory GroupTopicModel.fromJson(Map<String, dynamic> json) => GroupTopicModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        masterTopic: json['masterTopic'] != null
            ? GroupMasterTopicModel.fromJson(
                json['masterTopic'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        if (masterTopic != null) 'masterTopic': masterTopic!.toJson(),
      };

  // Removed toEntity as it's now handled directly in GroupModel.toEntity()
}

@JsonSerializable()
class GroupMasterTopicModel {
  final String id;
  final String name;
  final String? description;

  GroupMasterTopicModel({
    required this.id,
    required this.name,
    this.description,
  });

  factory GroupMasterTopicModel.fromJson(Map<String, dynamic> json) =>
      GroupMasterTopicModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
      };

  // Removed toEntity as it's now handled directly in GroupModel.toEntity()
}

@JsonSerializable()
class GroupListResponse {
  final int statusCode;
  final String code;
  final String message;
  final GroupListData data;

  GroupListResponse({
    required this.statusCode,
    required this.code,
    required this.message,
    required this.data,
  });

  factory GroupListResponse.fromJson(Map<String, dynamic> json) {
    return GroupListResponse(
      statusCode: json['statusCode'] as int,
      code: json['code'] as String,
      message: json['message'] as String,
      data: GroupListData(
        items: (json['data']['items'] as List<dynamic>)
            .map((e) => GroupModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalItems: json['data']['totalItems'] as int,
        currentPage: json['data']['currentPage'] as int,
        totalPages: json['data']['totalPages'] as int,
        pageSize: json['data']['pageSize'] as int,
        hasPreviousPage: json['data']['hasPreviousPage'] as bool,
        hasNextPage: json['data']['hasNextPage'] as bool,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'code': code,
      'message': message,
      'data': {
        'items': data.items.map((e) => e.toJson()).toList(),
        'totalItems': data.totalItems,
        'currentPage': data.currentPage,
        'totalPages': data.totalPages,
        'pageSize': data.pageSize,
        'hasPreviousPage': data.hasPreviousPage,
        'hasNextPage': data.hasNextPage,
      },
    };
  }
}

@JsonSerializable()
class GroupListData {
  final List<GroupModel> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  GroupListData({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory GroupListData.fromJson(Map<String, dynamic> json) => GroupListData(
        items: (json['items'] as List<dynamic>)
            .map((e) => GroupModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalItems: json['totalItems'] as int,
        currentPage: json['currentPage'] as int,
        totalPages: json['totalPages'] as int,
        pageSize: json['pageSize'] as int,
        hasPreviousPage: json['hasPreviousPage'] as bool,
        hasNextPage: json['hasNextPage'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'items': items.map((e) => e.toJson()).toList(),
        'totalItems': totalItems,
        'currentPage': currentPage,
        'totalPages': totalPages,
        'pageSize': pageSize,
        'hasPreviousPage': hasPreviousPage,
        'hasNextPage': hasNextPage,
      };
}
