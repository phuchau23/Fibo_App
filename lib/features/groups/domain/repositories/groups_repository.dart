import 'package:dartz/dartz.dart';
import 'package:swp_app/core/error/exceptions.dart'
    show AppException; // use as Failure
import '../entities/group_entity.dart';
import '../entities/group_member_entity.dart';

typedef Failure = AppException;

abstract class GroupsRepository {
  Future<Either<Failure, List<GroupEntity>>> getGroupsByClass(String classId);
  Future<Either<Failure, List<GroupMemberEntity>>> getMembers(String groupId);
  Future<Either<Failure, Unit>> addMembers({
    required String groupId,
    required List<String> userIds,
  });
  Future<Either<Failure, Unit>> removeMember({
    required String groupId,
    required String userId,
  });
  Future<Either<Failure, Unit>> createGroup({
    required String classId,
    required String name,
    String? description,
  });
}
