import 'package:dartz/dartz.dart';
import '../repositories/groups_repository.dart';
import '../entities/group_entity.dart';
import '../entities/group_member_entity.dart';

class GetGroupsByClassUseCase {
  final GroupsRepository repo;
  const GetGroupsByClassUseCase(this.repo);
  Future<Either<Failure, List<GroupEntity>>> call(String classId) =>
      repo.getGroupsByClass(classId);
}

class GetGroupMembersUseCase {
  final GroupsRepository repo;
  const GetGroupMembersUseCase(this.repo);
  Future<Either<Failure, List<GroupMemberEntity>>> call(String groupId) =>
      repo.getMembers(groupId);
}

class AddMembersUseCase {
  final GroupsRepository repo;
  const AddMembersUseCase(this.repo);
  Future<Either<Failure, Unit>> call({
    required String groupId,
    required List<String> userIds,
  }) => repo.addMembers(groupId: groupId, userIds: userIds);
}

class RemoveMemberUseCase {
  final GroupsRepository repo;
  const RemoveMemberUseCase(this.repo);
  Future<Either<Failure, Unit>> call({
    required String groupId,
    required String userId,
  }) => repo.removeMember(groupId: groupId, userId: userId);
}

class CreateGroupUseCase {
  final GroupsRepository repo;
  const CreateGroupUseCase(this.repo);
  Future<Either<Failure, Unit>> call({
    required String classId,
    required String name,
    String? description,
  }) =>
      repo.createGroup(classId: classId, name: name, description: description);
}
