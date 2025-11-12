import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swp_app/features/notification/presentation/models/notification_navigation.dart';
import 'package:swp_app/shared/presentation/providers/navigation_provider.dart';

final fcmServiceProvider = Provider<FcmService>((ref) => FcmService(ref));

class FcmService {
  FcmService(this._ref);

  final Ref _ref;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  bool _initialized = false;
  bool _requestingPermission = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // Setup listeners first
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    // Request permission ngay khi app khởi động (best practice)
    await _requestPermission();

    // Sync token sau khi có permission
    await _syncToken();
  }

  Future<void> _requestPermission() async {
    if (_requestingPermission) return;
    _requestingPermission = true;
    try {
      // Kiểm tra permission status hiện tại
      final currentSettings = await _messaging.getNotificationSettings();
      debugPrint(
        'FCM current permission status: ${currentSettings.authorizationStatus}',
      );

      // Nếu đã được cấp rồi thì không cần request lại
      if (currentSettings.authorizationStatus ==
              AuthorizationStatus.authorized ||
          currentSettings.authorizationStatus ==
              AuthorizationStatus.provisional) {
        debugPrint('✅ FCM permission already granted, skipping request');
        return;
      }

      // Request permission (chỉ hiển thị dialog nếu chưa được cấp)
      debugPrint('📱 Requesting FCM permission...');
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );
      debugPrint(
        'FCM permission request result: ${settings.authorizationStatus}',
      );

      // Log chi tiết
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ FCM permission granted');
      } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('❌ FCM permission denied');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.notDetermined) {
        debugPrint('⚠️ FCM permission not determined');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        debugPrint('⚠️ FCM permission provisional');
      }
    } finally {
      _requestingPermission = false;
    }
  }

  /// Request notification permission explicitly (call this after user interaction)
  Future<bool> requestNotificationPermission() async {
    if (_requestingPermission) return false;
    _requestingPermission = true;
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );
      debugPrint('FCM permission status: ${settings.authorizationStatus}');
      final granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      // Sync token after permission is granted
      if (granted) {
        await _syncToken();
      }

      return granted;
    } finally {
      _requestingPermission = false;
    }
  }

  Future<void> _syncToken() async {
    final token = await _messaging.getToken();
    if (token != null) {
      _ref.read(fcmDeviceTokenProvider.notifier).state = token;
      debugPrint('FCM token: $token');
    }
    _messaging.onTokenRefresh.listen((token) {
      _ref.read(fcmDeviceTokenProvider.notifier).state = token;
      debugPrint('FCM token refreshed: $token');
    });
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final title =
        message.notification?.title ?? message.data['title'] ?? 'Thông báo mới';
    final body =
        message.notification?.body ??
        message.data['body'] ??
        'Bạn có thông báo mới.';
    final action = _parseAction(message);
    _ref.read(inAppNotificationProvider.notifier).state =
        InAppNotificationPayload(title: title, body: body, action: action);
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    final action = _parseAction(message);
    if (action != null) {
      _ref.read(pendingNotificationActionProvider.notifier).state = action;
    }
    _ref.read(navigationRequestProvider.notifier).state =
        const NavigationRequest(target: NavigationTarget.notifications);
  }

  void handleForegroundTap(NotificationNavigationAction action) {
    _ref.read(pendingNotificationActionProvider.notifier).state = action;
    _ref.read(navigationRequestProvider.notifier).state =
        const NavigationRequest(target: NavigationTarget.notifications);
  }

  NotificationNavigationAction? _parseAction(RemoteMessage message) {
    final data = message.data;
    final notificationId = data['notificationId'] ?? data['id'];
    if (notificationId == null) return null;
    final feedbackId = data['feedbackId'] ?? data['relatedEntityId'];
    return NotificationNavigationAction(
      notificationId: notificationId,
      feedbackId: feedbackId,
    );
  }
}
