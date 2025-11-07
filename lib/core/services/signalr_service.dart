import 'dart:async';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:swp_app/core/services/session_service.dart';
import 'package:swp_app/features/notification/data/models/notification_models.dart';

class SignalRService {
  static const String hubUrl = 'https://fibo.io.vn/course/hubs/notification';
  HubConnection? _connection;
  final SessionService _sessionService;
  final StreamController<NotificationModel> _notificationController =
      StreamController<NotificationModel>.broadcast();

  Stream<NotificationModel> get notificationStream =>
      _notificationController.stream;

  SignalRService(this._sessionService);

  Future<void> connect() async {
    if (_connection != null &&
        _connection!.state == HubConnectionState.Connected) {
      return;
    }

    try {
      final token = await _sessionService.token;
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token available');
      }

      final connectionOptions = HttpConnectionOptions(
        accessTokenFactory: () async => token,
        logMessageContent: true,
      );

      _connection = HubConnectionBuilder()
          .withUrl(hubUrl, options: connectionOptions)
          .withAutomaticReconnect()
          .build();

      // Listen for notifications
      _connection!.on('ReceiveNotification', (arguments) {
        if (arguments != null && arguments.isNotEmpty) {
          try {
            final notificationData = arguments[0] as Map<String, dynamic>;
            final notification = NotificationModel.fromJson(notificationData);
            _notificationController.add(notification);
          } catch (e) {
            print('Error parsing notification: $e');
          }
        }
      });

      await _connection!.start();
      print('✅ SignalR connected');
    } catch (e) {
      print('❌ SignalR connection error: $e');
      rethrow;
    }
  }

  Future<void> joinLecturerGroup(String lecturerId) async {
    if (_connection?.state != HubConnectionState.Connected) {
      await connect();
    }

    try {
      await _connection!.invoke('JoinLecturerGroup', args: [lecturerId]);
      print('✅ Joined lecturer group: $lecturerId');
    } catch (e) {
      print('❌ Error joining lecturer group: $e');
      rethrow;
    }
  }

  Future<void> leaveLecturerGroup(String lecturerId) async {
    if (_connection?.state != HubConnectionState.Connected) {
      return;
    }

    try {
      await _connection!.invoke('LeaveLecturerGroup', args: [lecturerId]);
      print('✅ Left lecturer group: $lecturerId');
    } catch (e) {
      print('❌ Error leaving lecturer group: $e');
    }
  }

  Future<void> disconnect() async {
    if (_connection != null) {
      await _connection!.stop();
      _connection = null;
      print('✅ SignalR disconnected');
    }
  }

  bool get isConnected => _connection?.state == HubConnectionState.Connected;

  void dispose() {
    _notificationController.close();
    disconnect();
  }
}
