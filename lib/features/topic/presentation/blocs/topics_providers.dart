// Following project rules:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swp_app/data/services/api_client.dart';
import 'package:swp_app/features/topic/data/datasources/topics_remote_datasource.dart';
import 'package:swp_app/features/topic/data/repository/topics_repository_impl.dart';
import 'package:swp_app/features/topic/domain/entities/topic_entity.dart';
import 'package:swp_app/features/topic/domain/repositories/topics_repository.dart';
import 'package:swp_app/features/topic/domain/usecases/get_all_topics_usecase.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref));

final topicsRemoteDsProvider = Provider<TopicsRemoteDataSource>(
  (ref) => TopicsRemoteDataSource(ref.watch(apiClientProvider)),
);

final topicsRepositoryProvider = Provider<TopicsRepository>(
  (ref) => TopicsRepositoryImpl(ref.watch(topicsRemoteDsProvider)),
);

final getAllTopicsUseCaseProvider = Provider<GetAllTopicsUseCase>(
  (ref) => GetAllTopicsUseCase(ref.watch(topicsRepositoryProvider)),
);

class TopicsState {
  final bool loading;
  final String? error;
  final PagedEntity<TopicEntity>? page;

  const TopicsState({this.loading = false, this.error, this.page});

  TopicsState copyWith({
    bool? loading,
    String? error,
    PagedEntity<TopicEntity>? page,
  }) => TopicsState(
    loading: loading ?? this.loading,
    error: error,
    page: page ?? this.page,
  );
}

class TopicsNotifier extends StateNotifier<TopicsState> {
  TopicsNotifier(this._getAll) : super(const TopicsState(loading: true)) {
    fetch();
  }

  final GetAllTopicsUseCase _getAll;
  int _page = 1;
  final int _pageSize = 10;

  Future<void> fetch({int? page}) async {
    state = state.copyWith(loading: true, error: null);
    final res = await _getAll(page: page ?? _page, pageSize: _pageSize);
    res.fold((l) => state = state.copyWith(loading: false, error: l.message), (
      r,
    ) {
      _page = r.currentPage;
      state = state.copyWith(loading: false, page: r);
    });
  }

  Future<void> nextPage() async {
    if (state.page?.hasNextPage == true) {
      await fetch(page: (_page + 1));
    }
  }

  Future<void> prevPage() async {
    if (state.page?.hasPreviousPage == true) {
      await fetch(page: (_page - 1));
    }
  }
}

final topicsNotifierProvider =
    StateNotifierProvider<TopicsNotifier, TopicsState>((ref) {
      return TopicsNotifier(ref.watch(getAllTopicsUseCaseProvider));
    });
