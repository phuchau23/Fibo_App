import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swp_app/core/constants/api.constants.dart';
import 'package:swp_app/core/error/exceptions.dart';
import 'package:swp_app/data/services/api_client.dart';
import '../models/group_model.dart';
import '../models/group_member_model.dart';

class GroupsRemoteDataSource {
  final ApiClient _api;
  GroupsRemoteDataSource(this._api);

  Future<List<GroupModel>> getGroupsByClass(String classId) async {
    try {
      final res = await _api.get<Map<String, dynamic>>(
        '${ApiEndpoints.groupsByClass}/$classId',
      );
      final parsed = GroupListResponse.fromJson(res.data!);
      return parsed.data.items;
    } on AppException {
      rethrow;
    }
  }

  Future<List<GroupMemberModel>> getMembers(String groupId) async {
    try {
      final res = await _api.get<Map<String, dynamic>>(
        '${ApiEndpoints.groupMembers}/$groupId/members',
      );
      final parsed = GroupMembersResponse.fromJson(res.data!);
      return parsed.data;
    } on AppException {
      rethrow;
    }
  }

  Future<void> addMembers({
    required String groupId,
    required List<String> userIds,
  }) async {
    // Swagger shows multipart/form-data: userIds (array<string>)
    final form = FormData.fromMap({'userIds': userIds});
    try {
      await _api.post(
        '${ApiEndpoints.groupMembers}/$groupId/members',
        data: form,
        options: Options(contentType: Headers.multipartFormDataContentType),
      );
    } on DioException catch (e) {
      // Normalize to AppException when using low-level dio here
      if (e.error is AppException) rethrow;
      throw NetworkException(e.message ?? 'Network error');
    }
  }

  Future<void> removeMember({
    required String groupId,
    required String userId,
  }) async {
    try {
      await _api.delete(
        '${ApiEndpoints.groupMembers}/$groupId/members/$userId',
      );
    } on AppException {
      rethrow;
    }
  }

  Future<void> createGroup({
    required String classId,
    required String name,
    String? description,
  }) async {
    // Swagger shows multipart/form-data with exact PascalCase keys
    final form = FormData.fromMap({
      'ClassId': classId,
      'Name': name,
      if (description != null && description.isNotEmpty)
        'Description': description,
    });
    try {
      await _api.post(
        ApiEndpoints.groupsRoot,
        data: form,
        options: Options(contentType: Headers.multipartFormDataContentType),
      );
    } on DioException catch (e) {
      if (e.error is AppException) rethrow;
      throw NetworkException(e.message ?? 'Network error');
    }
  }
}

final groupsRemoteDataSourceProvider = Provider<GroupsRemoteDataSource>((ref) {
  final api = ApiClient(ref); // uses your factory that injects token
  return GroupsRemoteDataSource(api);
});
