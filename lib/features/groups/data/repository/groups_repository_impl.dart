import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swp_app/core/error/exceptions.dart';
import '../../domain/repositories/groups_repository.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/entities/group_member_entity.dart';
import '../datasources/groups_remote_datasource.dart';

class GroupsRepositoryImpl implements GroupsRepository {
  final GroupsRemoteDataSource remote;
  GroupsRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, List<GroupEntity>>> getGroupsByClass(
    String classId,
  ) async {
    try {
      final models = await remote.getGroupsByClass(classId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on AppException catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, List<GroupMemberEntity>>> getMembers(
    String groupId,
  ) async {
    try {
      final models = await remote.getMembers(groupId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on AppException catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, Unit>> addMembers({
    required String groupId,
    required List<String> userIds,
  }) async {
    try {
      await remote.addMembers(groupId: groupId, userIds: userIds);
      return const Right(unit);
    } on AppException catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, Unit>> removeMember({
    required String groupId,
    required String userId,
  }) async {
    try {
      await remote.removeMember(groupId: groupId, userId: userId);
      return const Right(unit);
    } on AppException catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, Unit>> createGroup({
    required String classId,
    required String name,
    String? description,
  }) async {
    try {
      await remote.createGroup(
        classId: classId,
        name: name,
        description: description,
      );
      return const Right(unit);
    } on AppException catch (e) {
      return Left(e);
    }
  }
}

final groupsRepositoryProvider = Provider<GroupsRepository>((ref) {
  final ds = ref.watch(groupsRemoteDataSourceProvider);
  return GroupsRepositoryImpl(ds);
});
