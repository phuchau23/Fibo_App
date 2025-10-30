import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:swp_app/core/services/session_provider.dart';
import 'package:swp_app/data/services/api_client.dart';
import 'package:swp_app/features/class/data/repository/lass_repository_impl.dart';
import 'package:swp_app/features/class/domain/usecases/get_lecturer_classes.dart';

import '../../domain/entities/class_entity.dart';
import '../../domain/errors/class_failure.dart';
import '../../domain/repositories/class_repository.dart';
import '../../data/datasources/class_remote_datasource.dart';

// DI: ApiClient
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref));

// DataSource
final classRemoteDsProvider = Provider<ClassRemoteDataSource>(
  (ref) => ClassRemoteDataSource(ref.watch(apiClientProvider)),
);

// Repository
final classRepoProvider = Provider<ClassRepository>(
  (ref) => ClassRepositoryImpl(ref.watch(classRemoteDsProvider)),
);

// Usecase
final getLecturerClassesProvider = Provider<GetLecturerClasses>(
  (ref) => GetLecturerClasses(ref.watch(classRepoProvider)),
);

// Session: lecturerId (đã lưu khi đăng nhập).
// Bạn có thể thay bởi provider thực tế của bạn.
final lecturerIdProvider = FutureProvider<String?>((ref) async {
  final session = ref.watch(sessionServiceProvider);
  final id = await session.userId;
  return id;
});

// AsyncNotifier state
class LecturerClassesState {
  final bool isLoading;
  final String? error;
  final ClassPage? page;
  const LecturerClassesState({this.isLoading = false, this.error, this.page});

  LecturerClassesState copyWith({
    bool? isLoading,
    String? error,
    ClassPage? page,
  }) => LecturerClassesState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    page: page ?? this.page,
  );
}

class LecturerClassesNotifier
    extends AutoDisposeNotifier<LecturerClassesState> {
  late final GetLecturerClasses _usecase;

  @override
  LecturerClassesState build() {
    _usecase = ref.read(getLecturerClassesProvider);
    return const LecturerClassesState();
  }

  Future<void> fetch({int page = 1, int pageSize = 10}) async {
    state = state.copyWith(isLoading: true, error: null);

    final lecturerId = ref.read(lecturerIdProvider).value;
    final Either<ClassFailure, ClassPage> result = await _usecase(
      lecturerId: lecturerId!,
      page: page,
      pageSize: pageSize,
    );

    state = result.fold(
      (l) => state.copyWith(isLoading: false, error: _mapFailure(l)),
      (r) => LecturerClassesState(isLoading: false, page: r),
    );
  }

  String _mapFailure(ClassFailure f) {
    if (f is ServerFailure) return 'Server ${f.statusCode}: ${f.message}';
    if (f is NetworkFailure) return f.message;
    if (f is UnknownFailure) return f.message;
    return 'Unknown error';
  }
}

final lecturerClassesNotifierProvider =
    AutoDisposeNotifierProvider<LecturerClassesNotifier, LecturerClassesState>(
      LecturerClassesNotifier.new,
    );

