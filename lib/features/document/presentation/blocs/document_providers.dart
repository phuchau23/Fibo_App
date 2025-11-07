// Following project rules:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swp_app/data/services/api_client.dart';
import 'package:swp_app/features/document/data/datasources/document_remote_datasource.dart';
import 'package:swp_app/features/document/data/repository/document_repository_impl.dart';
import 'package:swp_app/features/document/domain/entities/document_entities.dart';
import 'package:swp_app/features/document/domain/repositories/document_repository.dart';
import 'package:swp_app/features/document/domain/usecases/document_usecases.dart';

final docApiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref));

final documentRemoteProvider = Provider<DocumentRemoteDataSource>(
  (ref) => DocumentRemoteDataSource(ref.watch(docApiClientProvider)),
);

final documentRepositoryProvider = Provider<DocumentRepository>(
  (ref) => DocumentRepositoryImpl(ref.watch(documentRemoteProvider)),
);

final getDocumentTypesProvider = Provider<GetDocumentTypes>(
  (ref) => GetDocumentTypes(ref.watch(documentRepositoryProvider)),
);
final createDocumentTypeProvider = Provider<CreateDocumentType>(
  (ref) => CreateDocumentType(ref.watch(documentRepositoryProvider)),
);
final getDocumentsByTopicProvider = Provider<GetDocumentsByTopic>(
  (ref) => GetDocumentsByTopic(ref.watch(documentRepositoryProvider)),
);
final uploadDocumentProvider = Provider<UploadDocument>(
  (ref) => UploadDocument(ref.watch(documentRepositoryProvider)),
);
final updateDocumentProvider = Provider<UpdateDocument>(
  (ref) => UpdateDocument(ref.watch(documentRepositoryProvider)),
);
final deleteDocumentProvider = Provider<DeleteDocument>(
  (ref) => DeleteDocument(ref.watch(documentRepositoryProvider)),
);
final getDocumentByIdProvider = Provider<GetDocumentById>(
  (ref) => GetDocumentById(ref.watch(documentRepositoryProvider)),
);

// States
class DocumentTypesState {
  final bool loading;
  final String? error;
  final List<DocumentTypeEntity> items;
  const DocumentTypesState({
    this.loading = false,
    this.error,
    this.items = const [],
  });
}

class DocumentTypesNotifier extends StateNotifier<DocumentTypesState> {
  DocumentTypesNotifier(this._getTypes, this._createType)
    : super(const DocumentTypesState());

  final GetDocumentTypes _getTypes;
  final CreateDocumentType _createType;

  Future<void> fetch() async {
    state = const DocumentTypesState(loading: true);
    final res = await _getTypes(page: 1, pageSize: 100);
    state = res.fold(
      (l) => DocumentTypesState(loading: false, error: l.message),
      (r) => DocumentTypesState(loading: false, items: r.items),
    );
  }

  Future<String?> create(String name) async {
    final res = await _createType(name);
    return res.fold((l) => l.message, (r) {
      state = DocumentTypesState(loading: false, items: [...state.items, r]);
      return null;
    });
  }
}

final documentTypesNotifierProvider =
    StateNotifierProvider<DocumentTypesNotifier, DocumentTypesState>((ref) {
      return DocumentTypesNotifier(
        ref.watch(getDocumentTypesProvider),
        ref.watch(createDocumentTypeProvider),
      );
    });

class DocumentsState {
  final bool loading;
  final String? error;
  final PagedEntity<DocumentEntity>? page;
  const DocumentsState({this.loading = false, this.error, this.page});
}

class DocumentsNotifier extends StateNotifier<DocumentsState> {
  DocumentsNotifier(this._getDocs) : super(const DocumentsState());
  final GetDocumentsByTopic _getDocs;
  int _page = 1;
  final int _pageSize = 10;
  String? _topicId;

  Future<void> fetch({required String topicId, int? page}) async {
    _topicId = topicId;
    state = DocumentsState(loading: true, page: state.page);
    final res = await _getDocs(
      topicId: topicId,
      page: page ?? _page,
      pageSize: _pageSize,
    );
    state = res.fold(
      (l) => DocumentsState(loading: false, error: l.message, page: state.page),
      (r) {
        _page = r.currentPage;
        return DocumentsState(loading: false, page: r);
      },
    );
  }

  Future<void> refresh() async {
    if (_topicId != null) {
      await fetch(topicId: _topicId!);
    }
  }
}

final documentsNotifierProvider =
    StateNotifierProvider<DocumentsNotifier, DocumentsState>((ref) {
      return DocumentsNotifier(ref.watch(getDocumentsByTopicProvider));
    });

final documentDetailProvider =
    FutureProvider.family<DocumentDetailEntity, String>((ref, id) async {
      final usecase = ref.watch(getDocumentByIdProvider);
      final res = await usecase(id);
      return res.fold((l) => throw Exception(l.message), (r) => r);
    });
