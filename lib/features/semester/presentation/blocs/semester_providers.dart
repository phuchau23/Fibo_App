import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swp_app/data/data.dart';
import '../../data/datasources/semesters_remote_datasource.dart';
import '../../domain/entities/semester_entity.dart';

final _apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref));
final _remoteProvider = Provider<SemestersRemoteDataSource>(
  (ref) => SemestersRemoteDataSource(ref.read(_apiClientProvider)),
);

class SemestersState {
  final bool loading;
  final String? error;
  final List<SemesterEntity> items;
  const SemestersState({
    this.loading = false,
    this.error,
    this.items = const [],
  });

  SemestersState copyWith({
    bool? loading,
    String? error,
    List<SemesterEntity>? items,
  }) => SemestersState(
    loading: loading ?? this.loading,
    error: error,
    items: items ?? this.items,
  );
}

class SemestersNotifier extends StateNotifier<SemestersState> {
  final SemestersRemoteDataSource remote;
  SemestersNotifier(this.remote) : super(const SemestersState());

  Future<void> fetch({int page = 1, int pageSize = 50}) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final models = await remote.getAll(page: page, pageSize: pageSize);
      final ents = models.map((m) => m.toEntity()).toList();
      state = state.copyWith(loading: false, items: ents);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}

final semestersProvider =
    StateNotifierProvider<SemestersNotifier, SemestersState>((ref) {
      return SemestersNotifier(ref.read(_remoteProvider));
    });
