import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swp_app/features/notification/domain/entities/notification_entities.dart';
import 'package:swp_app/features/notification/presentation/blocs/notification_providers.dart';
import 'package:swp_app/features/notification/presentation/pages/notification_list_page.dart';
import 'package:swp_app/features/topic/presentation/blocs/topics_providers.dart';

class NotificationIcon extends ConsumerStatefulWidget {
  const NotificationIcon({super.key});

  @override
  ConsumerState<NotificationIcon> createState() => _NotificationIconState();
}

class _NotificationIconState extends ConsumerState<NotificationIcon> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNotifications();
    });
  }

  Future<void> _initializeNotifications() async {
    try {
      final lecturerIdAsync = ref.read(lecturerIdProvider);
      await lecturerIdAsync.when(
        data: (lecturerId) async {
          final notifier = ref.read(notificationNotifierProvider.notifier);
          notifier.configureSource(lecturerId: lecturerId);
          await notifier.fetch();

          // Connect to SignalR
          final signalR = ref.read(signalRServiceProvider);
          try {
            await signalR.connect();
            if (lecturerId != null) {
              await signalR.joinLecturerGroup(lecturerId);
            }

            // Listen for real-time notifications
            signalR.notificationStream.listen((notification) {
              if (mounted) {
                final entity = NotificationEntity(
                  id: notification.id,
                  type: notification.type,
                  title: notification.title,
                  description: notification.description,
                  icon: notification.icon,
                  relatedEntityId: notification.relatedEntityId,
                  relatedEntityType: notification.relatedEntityType,
                  createdAt: DateTime.parse(notification.createdAt),
                  isNew: notification.isNew,
                  data: notification.data,
                );
                notifier.addNotification(entity);
              }
            });
          } catch (e) {
            print('Error connecting to SignalR: $e');
          }
        },
        loading: () {},
        error: (_, __) {},
      );
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(notificationNotifierProvider).unreadCount;

    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const NotificationListPage()));
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(87, 255, 167, 84),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Color.fromARGB(255, 255, 102, 0),
              size: 20,
            ),
          ),
          if (unreadCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  unreadCount > 9 ? '9+' : unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
