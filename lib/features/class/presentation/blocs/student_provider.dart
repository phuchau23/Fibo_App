import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swp_app/features/class/data/datasources/class_remote_datasource.dart';
import 'package:swp_app/features/class/data/repository/lass_repository_impl.dart';
import 'package:swp_app/features/class/domain/entities/class_students_entities.dart';
import 'package:swp_app/features/class/domain/repositories/class_repository.dart';
import 'package:swp_app/features/class/domain/usecases/get_class_student.dart';
import 'package:swp_app/data/services/api_client.dart';
import 'package:swp_app/features/class/domain/usecases/get_class_without_group.dart';
import 'package:swp_app/features/class/presentation/blocs/class_providers.dart';

/// DI
final _remoteDSProvider = Provider<ClassRemoteDataSource>(
  (ref) => ClassRemoteDataSource(ref.read(apiClientProvider)),
);
final _repoProvider = Provider<ClassRepository>(
  (ref) => ClassRepositoryImpl(ref.read(_remoteDSProvider)),
);
final getClassStudentsProvider = Provider<GetClassStudentsUseCase>(
  (ref) => GetClassStudentsUseCase(ref.read(_repoProvider)),
);

/// State
class ClassStudentsState {
  final bool loading;
  final String? error;
  final ClassWithStudentsEntity? data;
  const ClassStudentsState({this.loading = false, this.error, this.data});

  ClassStudentsState copyWith({
    bool? loading,
    String? error,
    ClassWithStudentsEntity? data,
  }) => ClassStudentsState(
    loading: loading ?? this.loading,
    error: error,
    data: data ?? this.data,
  );
}

/// Notifier FAMILY theo classId
class ClassStudentsNotifier
    extends AutoDisposeFamilyNotifier<ClassStudentsState, String> {
  late String _classId;

  @override
  ClassStudentsState build(String classId) {
    _classId = classId;
    return const ClassStudentsState();
  }

  Future<void> fetch() async {
    state = state.copyWith(loading: true, error: null);
    final usecase = ref.read(getClassStudentsProvider);
    final result = await usecase(_classId);
    state = result.fold(
      (l) => state.copyWith(loading: false, error: l),
      (r) => state.copyWith(loading: false, data: r),
    );
  }

  void reset() {
    state = state.copyWith(loading: true, error: null, data: null);
  }
}

/// Provider FAMILY (autoDispose)
final classStudentsNotifierProvider =
    AutoDisposeNotifierProviderFamily<
      ClassStudentsNotifier,
      ClassStudentsState,
      String
    >(ClassStudentsNotifier.new);

class StudentsWithoutGroupNotifier
    extends FamilyAsyncNotifier<List<StudentEntity>, String> {
  @override
  Future<List<StudentEntity>> build(String classId) async {
    final repo = ref.read(classRepoProvider);
    final res = await repo.getStudentsWithoutGroup(classId: classId);
    return res.fold((err) => Future.error(err), (list) => list);
  }

  Future<void> refresh() async {
    final id = arg;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build(id));
  }
}

final studentsWithoutGroupProvider =
    AsyncNotifierProviderFamily<
      StudentsWithoutGroupNotifier,
      List<StudentEntity>,
      String
    >(StudentsWithoutGroupNotifier.new);
