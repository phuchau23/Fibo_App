import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swp_app/core/services/session_provider.dart';
import 'package:swp_app/core/services/signalr_service.dart';
import 'package:swp_app/data/services/api_client.dart';
import 'package:swp_app/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:swp_app/features/notification/data/repository/notification_repository_impl.dart';
import 'package:swp_app/features/notification/domain/entities/notification_entities.dart';
import 'package:swp_app/features/notification/domain/repositories/notification_repository.dart';
import 'package:swp_app/features/notification/domain/usecases/notification_usecases.dart';

final notificationApiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref),
);

final notificationRemoteProvider = Provider<NotificationRemoteDataSource>(
  (ref) => NotificationRemoteDataSourceImpl(
    ref.watch(notificationApiClientProvider),
  ),
);

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepositoryImpl(ref.watch(notificationRemoteProvider)),
);

final getNotificationsByLecturerProvider = Provider<GetNotificationsByLecturer>(
  (ref) =>
      GetNotificationsByLecturer(ref.watch(notificationRepositoryProvider)),
);

final getAllNotificationsProvider = Provider<GetAllNotifications>(
  (ref) => GetAllNotifications(ref.watch(notificationRepositoryProvider)),
);

final getNotificationByIdProvider = Provider<GetNotificationById>(
  (ref) => GetNotificationById(ref.watch(notificationRepositoryProvider)),
);

final markNotificationReadProvider = Provider<MarkNotificationRead>(
  (ref) => MarkNotificationRead(ref.watch(notificationRepositoryProvider)),
);

final markAllNotificationsReadProvider = Provider<MarkAllNotificationsRead>(
  (ref) => MarkAllNotificationsRead(ref.watch(notificationRepositoryProvider)),
);

final signalRServiceProvider = Provider<SignalRService>((ref) {
  final sessionService = ref.watch(sessionServiceProvider);
  final service = SignalRService(sessionService);
  ref.onDispose(() => service.dispose());
  return service;
});

class NotificationState {
  final bool loading;
  final String? error;
  final NotificationPagedEntity? page;
  final List<NotificationEntity> items;
  final int unreadCount;

  const NotificationState({
    this.loading = false,
    this.error,
    this.page,
    this.items = const [],
    this.unreadCount = 0,
  });

  NotificationState copyWith({
    bool? loading,
    String? error,
    NotificationPagedEntity? page,
    List<NotificationEntity>? items,
    int? unreadCount,
  }) {
    return NotificationState(
      loading: loading ?? this.loading,
      error: error,
      page: page ?? this.page,
      items: items ?? this.items,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier(
    this._getNotificationsByLecturer,
    this._markNotificationRead,
    this._markAllNotificationsRead,
  ) : super(const NotificationState());

  final GetNotificationsByLecturer _getNotificationsByLecturer;
  final MarkNotificationRead _markNotificationRead;
  final MarkAllNotificationsRead _markAllNotificationsRead;
  int _page = 1;
  final int _pageSize = 20;
  String? _lecturerId;

  void configureSource({String? lecturerId}) {
    _lecturerId = lecturerId;
  }

  Future<void> fetch({int? page}) async {
    if (_lecturerId == null) return;

    state = state.copyWith(loading: true, error: null);
    final res = await _getNotificationsByLecturer(
      _lecturerId!,
      page: page ?? _page,
      pageSize: _pageSize,
    );
    state = res.fold((l) => state.copyWith(loading: false, error: l.message), (
      r,
    ) {
      _page = r.currentPage;
      final unreadCount = r.items.where((n) => n.isNew).length;
      return state.copyWith(
        loading: false,
        page: r,
        items: r.items,
        unreadCount: unreadCount,
      );
    });
  }

  Future<void> refresh() async => fetch(page: _page);

  void addNotification(NotificationEntity notification) {
    final updatedItems = [notification, ...state.items];
    final unreadCount = updatedItems.where((n) => n.isNew).length;
    state = state.copyWith(items: updatedItems, unreadCount: unreadCount);
  }

  Future<void> markAsRead(String notificationId) async {
    if (_lecturerId == null) return;
    final previousState = state;
    final updatedItems = state.items.map((n) {
      if (n.id == notificationId) {
        return _cloneNotification(n, isNew: false);
      }
      return n;
    }).toList();
    final unreadCount = updatedItems.where((n) => n.isNew).length;
    state = state.copyWith(items: updatedItems, unreadCount: unreadCount);

    final result = await _markNotificationRead(
      lecturerId: _lecturerId!,
      notificationId: notificationId,
      isRead: true,
    );

    result.fold((l) {
      state = previousState;
    }, (_) {});
  }

  Future<void> markAllAsRead() async {
    if (_lecturerId == null) return;
    final previousState = state;
    final updatedItems = state.items
        .map((n) => _cloneNotification(n, isNew: false))
        .toList();
    state = state.copyWith(items: updatedItems, unreadCount: 0);

    final result = await _markAllNotificationsRead(_lecturerId!);
    result.fold((l) {
      state = previousState;
    }, (_) {});
  }

  NotificationEntity _cloneNotification(
    NotificationEntity entity, {
    bool? isNew,
  }) {
    return NotificationEntity(
      id: entity.id,
      type: entity.type,
      title: entity.title,
      description: entity.description,
      icon: entity.icon,
      relatedEntityId: entity.relatedEntityId,
      relatedEntityType: entity.relatedEntityType,
      createdAt: entity.createdAt,
      isNew: isNew ?? entity.isNew,
      data: entity.data,
    );
  }
}

final notificationNotifierProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
      return NotificationNotifier(
        ref.watch(getNotificationsByLecturerProvider),
        ref.watch(markNotificationReadProvider),
        ref.watch(markAllNotificationsReadProvider),
      );
    });

final notificationDetailProvider =
    FutureProvider.family<NotificationEntity, String>((ref, id) async {
      final usecase = ref.watch(getNotificationByIdProvider);
      final res = await usecase(id);
      return res.fold((l) => throw Exception(l.message), (r) => r);
    });
