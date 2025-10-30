import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

// ApiClient (baseUrl, interceptors...) export từ barrel
import 'package:swp_app/data/data.dart';

// singular: master_topic
import 'package:swp_app/features/master_topic/data/datasource/master_topics_remote_datasource.dart';
import 'package:swp_app/features/master_topic/data/repository/master_topics_repository_impl.dart';

import 'package:swp_app/features/master_topic/domain/entities/master_topic_entity.dart';
import 'package:swp_app/features/master_topic/domain/repositories/master_topics_repository.dart';
import 'package:swp_app/features/master_topic/domain/usecases/create_master_topic_usecase.dart';
import 'package:swp_app/features/master_topic/domain/usecases/get_master_topic_by_id_usecase.dart';
import 'package:swp_app/features/master_topic/domain/usecases/get_master_topics_page_usecase.dart';
import 'package:swp_app/features/master_topic/domain/usecases/update_master_topic_usecase.dart';
import 'package:swp_app/features/master_topic/domain/usecases/delete_master_topic_usecase.dart';

/// ====== Core DI ======
final dioProvider = Provider<Dio>((_) => Dio());

// ❗ FIX: truyền Dio vào ApiClient
final _apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref));

final _remoteDSProvider = Provider<MasterTopicsRemoteDataSource>(
  (ref) => MasterTopicsRemoteDataSource(ref.read(_apiClientProvider)),
);

final _repoProvider = Provider<MasterTopicsRepository>(
  (ref) => MasterTopicsRepositoryImpl(ref.read(_remoteDSProvider)),
);

final getPageUseCaseProvider = Provider<GetMasterTopicsPageUseCase>(
  (ref) => GetMasterTopicsPageUseCase(ref.read(_repoProvider)),
);
final getByIdUseCaseProvider = Provider<GetMasterTopicByIdUseCase>(
  (ref) => GetMasterTopicByIdUseCase(ref.read(_repoProvider)),
);
final createUseCaseProvider = Provider<CreateMasterTopicUseCase>(
  (ref) => CreateMasterTopicUseCase(ref.read(_repoProvider)),
);
final updateUseCaseProvider = Provider<UpdateMasterTopicUseCase>(
  (ref) => UpdateMasterTopicUseCase(ref.read(_repoProvider)),
);

// ❗ FIX: đúng tên class UseCase (chữ C hoa)
final deleteUseCaseProvider = Provider<DeleteMasterTopicUsecase>(
  (ref) => DeleteMasterTopicUsecase(ref.read(_repoProvider)),
);

/// ====== List Notifier ======
class MasterTopicsListState {
  final bool isLoading;
  final String? error;
  final PageEntity<MasterTopicEntity>? page;

  MasterTopicsListState({this.isLoading = false, this.error, this.page});

  MasterTopicsListState copyWith({
    bool? isLoading,
    String? error,
    PageEntity<MasterTopicEntity>? page,
  }) {
    return MasterTopicsListState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      page: page ?? this.page,
    );
  }
}

class MasterTopicsListNotifier extends StateNotifier<MasterTopicsListState> {
  final GetMasterTopicsPageUseCase _getPage;
  MasterTopicsListNotifier(this._getPage) : super(MasterTopicsListState());

  Future<void> fetch({int page = 1, int pageSize = 10}) async {
    state = state.copyWith(isLoading: true, error: null);
    final Either<Failure, PageEntity<MasterTopicEntity>> res = await _getPage(
      page: page,
      pageSize: pageSize,
    );
    state = res.fold(
      (l) => state.copyWith(isLoading: false, error: l.message),
      (r) => state.copyWith(isLoading: false, page: r),
    );
  }
}

final masterTopicsListProvider =
    StateNotifierProvider<MasterTopicsListNotifier, MasterTopicsListState>(
      (ref) => MasterTopicsListNotifier(ref.read(getPageUseCaseProvider)),
    );

/// ====== Create / Update ======
class MasterTopicCUState {
  final bool isSubmitting;
  final String? error;
  final MasterTopicEntity? result;
  MasterTopicCUState({this.isSubmitting = false, this.error, this.result});

  MasterTopicCUState copyWith({
    bool? isSubmitting,
    String? error,
    MasterTopicEntity? result,
  }) => MasterTopicCUState(
    isSubmitting: isSubmitting ?? this.isSubmitting,
    error: error,
    result: result,
  );
}

class MasterTopicCreateNotifier extends StateNotifier<MasterTopicCUState> {
  final CreateMasterTopicUseCase _create;
  MasterTopicCreateNotifier(this._create) : super(MasterTopicCUState());

  Future<void> submit({
    required String domainId,
    String? semesterId,
    required List<String> lecturerIds,
    required String name,
    String? description,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null, result: null);
    final res = await _create(
      domainId: domainId,
      semesterId: semesterId,
      lecturerIds: lecturerIds,
      name: name,
      description: description,
    );
    state = res.fold(
      (l) => state.copyWith(isSubmitting: false, error: l.message),
      (r) => state.copyWith(isSubmitting: false, result: r),
    );
  }
}

final masterTopicCreateProvider =
    StateNotifierProvider<MasterTopicCreateNotifier, MasterTopicCUState>(
      (ref) => MasterTopicCreateNotifier(ref.read(createUseCaseProvider)),
    );

class MasterTopicUpdateNotifier extends StateNotifier<MasterTopicCUState> {
  final UpdateMasterTopicUseCase _update;
  MasterTopicUpdateNotifier(this._update) : super(MasterTopicCUState());

  Future<void> submit({
    required String id,
    required String domainId,
    String? semesterId,
    required List<String> lecturerIds,
    required String name,
    String? description,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null, result: null);
    final res = await _update(
      id: id,
      domainId: domainId,
      semesterId: semesterId,
      lecturerIds: lecturerIds,
      name: name,
      description: description,
    );
    state = res.fold(
      (l) => state.copyWith(isSubmitting: false, error: l.message),
      (r) => state.copyWith(isSubmitting: false, result: r),
    );
  }
}

final masterTopicUpdateProvider =
    StateNotifierProvider<MasterTopicUpdateNotifier, MasterTopicCUState>(
      (ref) => MasterTopicUpdateNotifier(ref.read(updateUseCaseProvider)),
    );

/// ====== Detail by id ======
final masterTopicByIdProvider =
    FutureProvider.family<MasterTopicEntity, String>((ref, id) async {
      final usecase = ref.read(getByIdUseCaseProvider);
      final res = await usecase(id);
      return res.fold((l) => throw Exception(l.message), (r) => r);
    });

/// ====== Delete ======
class MasterTopicDeleteNotifier extends StateNotifier<AsyncValue<void>> {
  final DeleteMasterTopicUsecase _delete;
  MasterTopicDeleteNotifier(this._delete) : super(const AsyncData(null));

  /// return null nếu OK, hoặc message nếu lỗi
  Future<String?> remove(String id) async {
    state = const AsyncLoading();
    final res = await _delete(id: id);
    return res.fold(
      (l) {
        state = const AsyncData(null);
        return l.message;
      },
      (r) {
        state = const AsyncData(null);
        return null;
      },
    );
  }
}

final masterTopicDeleteProvider =
    StateNotifierProvider<MasterTopicDeleteNotifier, AsyncValue<void>>(
      (ref) => MasterTopicDeleteNotifier(ref.read(deleteUseCaseProvider)),
    );
