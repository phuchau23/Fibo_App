// Following project rules:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swp_app/data/services/api_client.dart';
import 'package:swp_app/features/qa/data/datasources/qa_remote_datasource.dart';
import 'package:swp_app/features/qa/data/repository/qa_repository_impl.dart';
import 'package:swp_app/features/qa/domain/entities/qa_entities.dart';
import 'package:swp_app/features/qa/domain/repositories/qa_repository.dart';
import 'package:swp_app/features/qa/domain/usecases/qa_usecases.dart';

final qaApiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref));

final qaRemoteDataSourceProvider = Provider<QARemoteDataSource>(
  (ref) => QARemoteDataSource(ref.watch(qaApiClientProvider)),
);

final qaRepositoryProvider = Provider<QaRepository>(
  (ref) => QaRepositoryImpl(ref.watch(qaRemoteDataSourceProvider)),
);

final getQAPairsProvider = Provider<GetQAPairs>(
  (ref) => GetQAPairs(ref.watch(qaRepositoryProvider)),
);

final getQAPairByIdProvider = Provider<GetQAPairById>(
  (ref) => GetQAPairById(ref.watch(qaRepositoryProvider)),
);

final createQAPairProvider = Provider<CreateQAPair>(
  (ref) => CreateQAPair(ref.watch(qaRepositoryProvider)),
);

final updateQAPairProvider = Provider<UpdateQAPair>(
  (ref) => UpdateQAPair(ref.watch(qaRepositoryProvider)),
);

final deleteQAPairProvider = Provider<DeleteQAPair>(
  (ref) => DeleteQAPair(ref.watch(qaRepositoryProvider)),
);

class QAPairsState {
  final bool loading;
  final String? error;
  final QAPagedEntity? page;

  const QAPairsState({this.loading = false, this.error, this.page});

  QAPairsState copyWith({bool? loading, String? error, QAPagedEntity? page}) =>
      QAPairsState(
        loading: loading ?? this.loading,
        error: error,
        page: page ?? this.page,
      );
}

class QAPairsNotifier extends StateNotifier<QAPairsState> {
  QAPairsNotifier(this._getQAPairs) : super(const QAPairsState());

  final GetQAPairs _getQAPairs;
  String? _topicId;
  String? _documentId;
  int _page = 1;
  final int _pageSize = 10;

  Future<void> fetch({
    required String topicId,
    String? documentId,
    int? page,
  }) async {
    _topicId = topicId;
    _documentId = documentId;
    state = state.copyWith(loading: true, error: null);
    final res = await _getQAPairs(
      topicId: topicId,
      documentId: documentId,
      page: page ?? _page,
      pageSize: _pageSize,
    );
    state = res.fold(
      (l) => QAPairsState(loading: false, error: l.message, page: state.page),
      (r) {
        _page = r.currentPage;
        return QAPairsState(loading: false, page: r);
      },
    );
  }

  Future<void> refresh() async {
    if (_topicId != null) {
      await fetch(topicId: _topicId!, documentId: _documentId);
    }
  }
}

final qaPairsNotifierProvider =
    StateNotifierProvider<QAPairsNotifier, QAPairsState>((ref) {
      return QAPairsNotifier(ref.watch(getQAPairsProvider));
    });

final qaDetailProvider = FutureProvider.family<QAPairEntity, String>((
  ref,
  id,
) async {
  final usecase = ref.watch(getQAPairByIdProvider);
  final res = await usecase(id);
  return res.fold((l) => throw Exception(l.message), (r) => r);
});
