import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/group_member_entity.dart';

part 'group_member_model.g.dart';

@JsonSerializable()
class GroupMemberModel {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String studentId;
  final String roleInClass;
  final String status;

  GroupMemberModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.studentId,
    required this.roleInClass,
    required this.status,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) =>
      _$GroupMemberModelFromJson(json);
  Map<String, dynamic> toJson() => _$GroupMemberModelToJson(this);

  GroupMemberEntity toEntity() => GroupMemberEntity(
    userId: userId,
    firstName: firstName,
    lastName: lastName,
    email: email,
    studentId: studentId,
    roleInClass: roleInClass,
    status: status,
  );
}

@JsonSerializable()
class GroupMembersResponse {
  final int statusCode;
  final String code;
  final String message;
  final List<GroupMemberModel> data;

  GroupMembersResponse({
    required this.statusCode,
    required this.code,
    required this.message,
    required this.data,
  });
  factory GroupMembersResponse.fromJson(Map<String, dynamic> json) =>
      _$GroupMembersResponseFromJson(json);
}
