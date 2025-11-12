import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationNavigationAction {
  final String notificationId;
  final String? feedbackId;

  const NotificationNavigationAction({
    required this.notificationId,
    this.feedbackId,
  });
}

class InAppNotificationPayload {
  final String title;
  final String body;
  final NotificationNavigationAction? action;

  const InAppNotificationPayload({
    required this.title,
    required this.body,
    this.action,
  });
}

final pendingNotificationActionProvider =
    StateProvider<NotificationNavigationAction?>((ref) => null);

final inAppNotificationProvider = StateProvider<InAppNotificationPayload?>(
  (ref) => null,
);

final fcmDeviceTokenProvider = StateProvider<String?>((ref) => null);
