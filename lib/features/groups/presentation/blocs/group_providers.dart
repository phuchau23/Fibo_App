// lib/features/groups/presentation/blocs/group_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:swp_app/features/groups/data/repository/groups_repository_impl.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/entities/group_member_entity.dart';
import '../../domain/usecases/groups_usecases.dart';

// UseCase providers
final _getGroupsByClassProvider = Provider<GetGroupsByClassUseCase>((ref) {
  final repo = ref.watch(groupsRepositoryProvider);
  return GetGroupsByClassUseCase(repo);
});
final _getGroupMembersProvider = Provider<GetGroupMembersUseCase>((ref) {
  final repo = ref.watch(groupsRepositoryProvider);
  return GetGroupMembersUseCase(repo);
});
final _addMembersProvider = Provider<AddMembersUseCase>((ref) {
  final repo = ref.watch(groupsRepositoryProvider);
  return AddMembersUseCase(repo);
});
final _removeMemberProvider = Provider<RemoveMemberUseCase>((ref) {
  final repo = ref.watch(groupsRepositoryProvider);
  return RemoveMemberUseCase(repo);
});
final _createGroupProvider = Provider<CreateGroupUseCase>((ref) {
  final repo = ref.watch(groupsRepositoryProvider);
  return CreateGroupUseCase(repo);
});

/// =====================
/// LIST GROUPS BY CLASS
/// =====================
class GroupsByClassNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<GroupEntity>, String> {
  @override
  Future<List<GroupEntity>> build(String classId) async {
    final usecase = ref.read(_getGroupsByClassProvider);
    final result = await usecase(classId);
    return result.fold((l) => throw l, (r) => r);
  }
}

final groupsByClassProvider =
    AutoDisposeAsyncNotifierProviderFamily<
      GroupsByClassNotifier,
      List<GroupEntity>,
      String
    >(GroupsByClassNotifier.new);

/// =====================
/// GROUP MEMBERS BY ID
/// =====================
class GroupMembersNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<GroupMemberEntity>, String> {
  @override
  Future<List<GroupMemberEntity>> build(String groupId) async {
    final usecase = ref.read(_getGroupMembersProvider);
    final result = await usecase(groupId);
    return result.fold((l) => throw l, (r) => r);
  }
}

final groupMembersProvider =
    AutoDisposeAsyncNotifierProviderFamily<
      GroupMembersNotifier,
      List<GroupMemberEntity>,
      String
    >(GroupMembersNotifier.new);

/// =====================
/// COMMAND CONTROLLERS
/// =====================
final addMembersControllerProvider =
    AutoDisposeNotifierProvider<AddMembersController, AsyncValue<Unit>>(
      AddMembersController.new,
    );

class AddMembersController extends AutoDisposeNotifier<AsyncValue<Unit>> {
  @override
  AsyncValue<Unit> build() => const AsyncValue.data(unit);

  Future<void> submit({
    required String groupId,
    required List<String> userIds,
  }) async {
    state = const AsyncValue.loading();
    final usecase = ref.read(_addMembersProvider);
    final result = await usecase(groupId: groupId, userIds: userIds);
    state = result.fold(
      (l) => AsyncValue.error(l, StackTrace.current),
      (r) => const AsyncValue.data(unit),
    );
  }
}

final removeMemberControllerProvider =
    AutoDisposeNotifierProvider<RemoveMemberController, AsyncValue<Unit>>(
      RemoveMemberController.new,
    );

class RemoveMemberController extends AutoDisposeNotifier<AsyncValue<Unit>> {
  @override
  AsyncValue<Unit> build() => const AsyncValue.data(unit);

  Future<void> submit({required String groupId, required String userId}) async {
    state = const AsyncValue.loading();
    final usecase = ref.read(_removeMemberProvider);
    final result = await usecase(groupId: groupId, userId: userId);
    state = result.fold(
      (l) => AsyncValue.error(l, StackTrace.current),
      (r) => const AsyncValue.data(unit),
    );
  }
}

final createGroupControllerProvider =
    AutoDisposeNotifierProvider<CreateGroupController, AsyncValue<Unit>>(
      CreateGroupController.new,
    );

class CreateGroupController extends AutoDisposeNotifier<AsyncValue<Unit>> {
  @override
  AsyncValue<Unit> build() => const AsyncValue.data(unit);

  Future<void> submit({
    required String classId,
    required String name,
    String? description,
  }) async {
    state = const AsyncValue.loading();
    final usecase = ref.read(_createGroupProvider);
    final result = await usecase(
      classId: classId,
      name: name,
      description: description,
    );
    state = result.fold(
      (l) => AsyncValue.error(l, StackTrace.current),
      (r) => const AsyncValue.data(unit),
    );
  }
}
