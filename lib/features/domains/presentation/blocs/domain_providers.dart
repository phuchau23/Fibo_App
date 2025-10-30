import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';

import 'package:swp_app/data/services/api_client.dart';
import 'package:swp_app/features/domains/data/repository/domain_repository_impl.dart';
import 'package:swp_app/features/domains/domain/usecases/delete_domain.dart';
import '../../data/datasources/domain_remote_datasource.dart';
import '../../domain/entities/domain_entity.dart';
import '../../domain/repositories/domain_repository.dart';
import '../../domain/usecases/get_domains.dart';
import '../../domain/usecases/create_domain.dart';
import '../../domain/usecases/update_domain.dart';

class DomainsState {
  final bool loading;
  final String? error;
  final DomainPage? page;

  const DomainsState({required this.loading, this.error, this.page});

  DomainsState copyWith({bool? loading, String? error, DomainPage? page}) {
    return DomainsState(
      loading: loading ?? this.loading,
      error: error,
      page: page ?? this.page,
    );
  }

  static const initial = DomainsState(loading: false);
}

// DI
final _apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref));
final _remoteProvider = Provider<DomainRemoteDataSource>(
  (ref) => DomainRemoteDataSource(ref.watch(_apiClientProvider)),
);
final _repoProvider = Provider<DomainRepository>(
  (ref) => DomainRepositoryImpl(ref.watch(_remoteProvider)),
);

final getDomainsProvider = Provider<GetDomains>(
  (ref) => GetDomains(ref.watch(_repoProvider)),
);
final createDomainProvider = Provider<CreateDomain>(
  (ref) => CreateDomain(ref.watch(_repoProvider)),
);
final updateDomainProvider = Provider<UpdateDomain>(
  (ref) => UpdateDomain(ref.watch(_repoProvider)),
);

class DomainsNotifier extends StateNotifier<DomainsState> {
  final GetDomains _getDomains;
  final CreateDomain _createDomain;
  final UpdateDomain _updateDomain;
  final DeleteDomain _deleteDomain;

  DomainsNotifier(
    this._getDomains,
    this._createDomain,
    this._updateDomain,
    this._deleteDomain,
  ) : super(DomainsState.initial);

  Future<void> fetch({int page = 1, int pageSize = 10}) async {
    state = state.copyWith(loading: true, error: null);
    final Either<String, DomainPage> res = await _getDomains(
      page: page,
      pageSize: pageSize,
    );
    res.fold(
      (l) => state = state.copyWith(loading: false, error: l),
      (r) => state = state.copyWith(loading: false, page: r),
    );
  }

  Future<String?> create({
    required String name,
    required String description,
  }) async {
    final res = await _createDomain(name: name, description: description);
    return res.fold((l) => l, (r) {
      // Refresh first page after create
      fetch(page: 1, pageSize: state.page?.pageSize ?? 10);
      return null;
    });
  }

  Future<String?> update({
    required String id,
    required String name,
    required String description,
  }) async {
    final res = await _updateDomain(
      id: id,
      name: name,
      description: description,
    );
    return res.fold((l) => l, (r) {
      // Refresh current page after update
      fetch(
        page: state.page?.currentPage ?? 1,
        pageSize: state.page?.pageSize ?? 10,
      );
      return null;
    });
  }

  Future<String?> delete({required String id}) async {
    try {
      final res = await _deleteDomain(id: id); // 👈 gọi usecase rõ ràng
      return res.fold((l) => l, (r) async {
        // Sau khi xóa: nếu trang hiện tại rỗng thì lùi về trang trước (nếu có)
        final currentPage = state.page?.currentPage ?? 1;
        final pageSize = state.page?.pageSize ?? 10;
        final totalItems = (state.page?.totalItems ?? 0) - 1; // vừa xóa 1

        final lastPageAfterDelete = (totalItems <= 0)
            ? 1
            : ((totalItems - 1) ~/ pageSize) + 1;

        final nextPage = currentPage > lastPageAfterDelete
            ? lastPageAfterDelete
            : currentPage;

        await fetch(page: nextPage, pageSize: pageSize);
        return null;
      });
    } catch (e) {
      return 'Xóa thất bại: $e';
    }
  }
}

final deleteDomainProvider = Provider<DeleteDomain>(
  (ref) => DeleteDomain(ref.watch(_repoProvider)),
);

final domainsNotifierProvider =
    StateNotifierProvider<DomainsNotifier, DomainsState>((ref) {
      return DomainsNotifier(
        ref.watch(getDomainsProvider),
        ref.watch(createDomainProvider),
        ref.watch(updateDomainProvider),
        ref.watch(deleteDomainProvider),
      );
    });
