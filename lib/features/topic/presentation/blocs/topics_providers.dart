// Following project rules:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swp_app/core/services/session_provider.dart';
import 'package:swp_app/data/services/api_client.dart';
import 'package:swp_app/features/topic/data/datasources/topics_remote_datasource.dart';
import 'package:swp_app/features/topic/data/repository/topics_repository_impl.dart';
import 'package:swp_app/features/topic/domain/entities/topic_entity.dart';
import 'package:swp_app/features/topic/domain/repositories/topics_repository.dart';
import 'package:swp_app/features/topic/domain/usecases/get_all_topics_usecase.dart';
import 'package:swp_app/features/topic/domain/usecases/get_topics_by_lecturer_usecase.dart';
import 'package:swp_app/features/topic/domain/usecases/get_topic_by_id_usecase.dart';

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

final getTopicsByLecturerUseCaseProvider = Provider<GetTopicsByLecturerUseCase>(
  (ref) => GetTopicsByLecturerUseCase(ref.watch(topicsRepositoryProvider)),
);

final getTopicByIdUseCaseProvider = Provider<GetTopicByIdUseCase>(
  (ref) => GetTopicByIdUseCase(ref.watch(topicsRepositoryProvider)),
);

final lecturerIdProvider = FutureProvider<String?>((ref) async {
  final session = ref.watch(sessionServiceProvider);
  return session.userId;
});

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
    print(
      '🟡 [TopicsNotifier] Constructor called, initializing with loading=true',
    );
    print('🟡 [TopicsNotifier] Calling fetch() from constructor...');
    fetch();
  }

  final GetAllTopicsUseCase _getAll;
  int _page = 1;
  final int _pageSize = 10;

  Future<void> fetch({int? page}) async {
    print('🟡 [TopicsNotifier] fetch() called with page: ${page ?? _page}');
    state = state.copyWith(loading: true, error: null);
    print('🟡 [TopicsNotifier] State updated: loading=true');
    try {
      final res = await _getAll(page: page ?? _page, pageSize: _pageSize);
      res.fold(
        (l) {
          print('❌ [TopicsNotifier] Failure: ${l.message}');
          state = state.copyWith(loading: false, error: l.message);
        },
        (r) {
          print(
            '✅ [TopicsNotifier] Success: ${r.items.length} topics, page ${r.currentPage}/${r.totalPages}',
          );
          _page = r.currentPage;
          state = state.copyWith(loading: false, page: r);
        },
      );
    } catch (e, stackTrace) {
      print('❌ [TopicsNotifier] Exception in fetch: $e');
      print('❌ [TopicsNotifier] StackTrace: $stackTrace');
      state = state.copyWith(loading: false, error: e.toString());
    }
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

// My Topics Provider (topics assigned to lecturer)
class MyTopicsState {
  final bool loading;
  final String? error;
  final PagedEntity<TopicEntity>? page;

  const MyTopicsState({this.loading = false, this.error, this.page});

  MyTopicsState copyWith({
    bool? loading,
    String? error,
    PagedEntity<TopicEntity>? page,
  }) => MyTopicsState(
    loading: loading ?? this.loading,
    error: error,
    page: page ?? this.page,
  );
}

class MyTopicsNotifier extends StateNotifier<MyTopicsState> {
  MyTopicsNotifier(this._getByLecturer)
    : super(const MyTopicsState(loading: false)) {
    print(
      '🟡 [MyTopicsNotifier] Constructor called, initializing with loading=false',
    );
    print(
      '🟡 [MyTopicsNotifier] Note: fetch() will be called from UI when lecturerId is available',
    );
  }

  final GetTopicsByLecturerUseCase _getByLecturer;
  int _page = 1;
  final int _pageSize = 10;
  String? _lecturerId;

  Future<void> fetch({int? page, String? lecturerId}) async {
    print(
      '🟡 [MyTopicsNotifier] fetch() called with page: ${page ?? _page}, lecturerId: ${lecturerId ?? _lecturerId}',
    );
    final lid = lecturerId ?? _lecturerId;
    if (lid == null) {
      print('❌ [MyTopicsNotifier] Lecturer ID is null!');
      state = state.copyWith(loading: false, error: 'Lecturer ID not found');
      return;
    }
    _lecturerId = lid;
    print('✅ [MyTopicsNotifier] Using lecturerId: $lid');

    state = state.copyWith(loading: true, error: null);
    print('🟡 [MyTopicsNotifier] State updated: loading=true');
    try {
      final res = await _getByLecturer(
        lecturerId: lid,
        page: page ?? _page,
        pageSize: _pageSize,
      );
      res.fold(
        (l) {
          print('❌ [MyTopicsNotifier] Failure: ${l.message}');
          state = state.copyWith(loading: false, error: l.message);
        },
        (r) {
          print(
            '✅ [MyTopicsNotifier] Success: ${r.items.length} topics, page ${r.currentPage}/${r.totalPages}',
          );
          _page = r.currentPage;
          state = state.copyWith(loading: false, page: r);
        },
      );
    } catch (e, stackTrace) {
      print('❌ [MyTopicsNotifier] Exception in fetch: $e');
      print('❌ [MyTopicsNotifier] StackTrace: $stackTrace');
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> nextPage() async {
    if (state.page?.hasNextPage == true && _lecturerId != null) {
      await fetch(page: (_page + 1));
    }
  }

  Future<void> prevPage() async {
    if (state.page?.hasPreviousPage == true && _lecturerId != null) {
      await fetch(page: (_page - 1));
    }
  }
}

final myTopicsNotifierProvider =
    StateNotifierProvider<MyTopicsNotifier, MyTopicsState>((ref) {
      return MyTopicsNotifier(ref.watch(getTopicsByLecturerUseCaseProvider));
    });
