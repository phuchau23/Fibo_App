// Following project rules:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swp_app/data/services/api_client.dart';
import 'package:swp_app/features/feedback/data/datasources/feedback_remote_datasource.dart';
import 'package:swp_app/features/feedback/data/repository/feedback_repository_impl.dart';
import 'package:swp_app/features/feedback/domain/entities/feedback_entities.dart';
import 'package:swp_app/features/feedback/domain/repositories/feedback_repository.dart';
import 'package:swp_app/features/feedback/domain/usecases/feedback_usecases.dart';

final feedbackApiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref));

final feedbackRemoteProvider = Provider<FeedbackRemoteDataSource>(
  (ref) => FeedbackRemoteDataSource(ref.watch(feedbackApiClientProvider)),
);

final feedbackRepositoryProvider = Provider<FeedbackRepository>(
  (ref) => FeedbackRepositoryImpl(ref.watch(feedbackRemoteProvider)),
);

final getFeedbacksProvider = Provider<GetFeedbacks>(
  (ref) => GetFeedbacks(ref.watch(feedbackRepositoryProvider)),
);

final getFeedbackByIdProvider = Provider<GetFeedbackById>(
  (ref) => GetFeedbackById(ref.watch(feedbackRepositoryProvider)),
);

final updateFeedbackProvider = Provider<UpdateFeedback>(
  (ref) => UpdateFeedback(ref.watch(feedbackRepositoryProvider)),
);

final deleteFeedbackProvider = Provider<DeleteFeedback>(
  (ref) => DeleteFeedback(ref.watch(feedbackRepositoryProvider)),
);

class FeedbackState {
  final bool loading;
  final String? error;
  final FeedbackPagedEntity? page;
  final String? helpfulFilter;
  final String searchTerm;
  final List<FeedbackEntity> items;

  const FeedbackState({
    this.loading = false,
    this.error,
    this.page,
    this.helpfulFilter,
    this.searchTerm = '',
    this.items = const [],
  });

  FeedbackState copyWith({
    bool? loading,
    String? error,
    FeedbackPagedEntity? page,
    String? helpfulFilter,
    String? searchTerm,
    List<FeedbackEntity>? items,
  }) => FeedbackState(
    loading: loading ?? this.loading,
    error: error,
    page: page ?? this.page,
    helpfulFilter: helpfulFilter ?? this.helpfulFilter,
    searchTerm: searchTerm ?? this.searchTerm,
    items: items ?? this.items,
  );
}

class FeedbackNotifier extends StateNotifier<FeedbackState> {
  FeedbackNotifier(this._getFeedbacks) : super(const FeedbackState());

  final GetFeedbacks _getFeedbacks;
  int _page = 1;
  final int _pageSize = 10;
  String? _lecturerId;
  String? _topicId;
  String? _answerId;

  void configureSource({
    String? lecturerId,
    String? topicId,
    String? answerId,
  }) {
    _lecturerId = lecturerId;
    _topicId = topicId;
    _answerId = answerId;
  }

  Future<void> fetch({int? page}) async {
    state = state.copyWith(loading: true, error: null);
    final res = await _getFeedbacks(
      page: page ?? _page,
      pageSize: _pageSize,
      lecturerId: _lecturerId,
      topicId: _topicId,
      answerId: _answerId,
    );
    state = res.fold((l) => state.copyWith(loading: false, error: l.message), (
      r,
    ) {
      _page = r.currentPage;
      final filtered = _applyFilters(
        entities: r.items,
        helpful: state.helpfulFilter,
        search: state.searchTerm,
      );
      return state.copyWith(loading: false, page: r, items: filtered);
    });
  }

  Future<void> refresh() async => fetch(page: _page);

  void setHelpfulFilter(String? helpful) {
    final filtered = _applyFilters(
      entities: state.page?.items ?? const [],
      helpful: helpful,
      search: state.searchTerm,
    );
    state = state.copyWith(helpfulFilter: helpful, items: filtered);
  }

  void setSearchTerm(String value) {
    final filtered = _applyFilters(
      entities: state.page?.items ?? const [],
      helpful: state.helpfulFilter,
      search: value,
    );
    state = state.copyWith(searchTerm: value, items: filtered);
  }

  List<FeedbackEntity> _applyFilters({
    required List<FeedbackEntity> entities,
    String? helpful,
    String? search,
  }) {
    return entities.where((entity) {
      final helpfulMatch = helpful == null || entity.helpful == helpful;
      final text =
          '${entity.user.firstName} ${entity.user.lastName} '
          '${entity.comment ?? ''} ${entity.answer?.content ?? ''}'
          ' ${entity.topic?.name ?? ''}';
      final searchMatch = (search == null || search.isEmpty)
          ? true
          : text.toLowerCase().contains(search.toLowerCase());
      return helpfulMatch && searchMatch;
    }).toList();
  }
}

final feedbackNotifierProvider =
    StateNotifierProvider<FeedbackNotifier, FeedbackState>((ref) {
      return FeedbackNotifier(ref.watch(getFeedbacksProvider));
    });

final feedbackDetailProvider = FutureProvider.family<FeedbackEntity, String>((
  ref,
  id,
) async {
  final usecase = ref.watch(getFeedbackByIdProvider);
  final res = await usecase(id);
  return res.fold((l) => throw Exception(l.message), (r) => r);
});
