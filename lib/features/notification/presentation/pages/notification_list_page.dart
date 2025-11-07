import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:swp_app/features/notification/domain/entities/notification_entities.dart';
import 'package:swp_app/features/notification/presentation/blocs/notification_providers.dart';
import 'package:swp_app/features/topic/presentation/blocs/topics_providers.dart';

class NotificationListPage extends ConsumerStatefulWidget {
  const NotificationListPage({super.key});

  @override
  ConsumerState<NotificationListPage> createState() =>
      _NotificationListPageState();
}

class _NotificationListPageState extends ConsumerState<NotificationListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    final lecturerId = await ref.read(lecturerIdProvider.future);
    if (!mounted) return;
    final notifier = ref.read(notificationNotifierProvider.notifier);
    notifier.configureSource(lecturerId: lecturerId);
    await notifier.fetch();

    // Connect to SignalR and join lecturer group
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
  }

  Future<void> _refresh() async {
    await ref.read(notificationNotifierProvider.notifier).refresh();
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 30) {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationNotifierProvider);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 231, 207),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color.fromARGB(255, 255, 102, 0),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF101828),
          ),
        ),
        actions: [
          if (state.items.any((n) => n.isNew))
            TextButton(
              onPressed: () {
                // Mark all as read
                for (final notification in state.items.where((n) => n.isNew)) {
                  ref
                      .read(notificationNotifierProvider.notifier)
                      .markAsRead(notification.id);
                }
              },
              child: Text(
                'Đánh dấu đã đọc',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFFF8C42),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: state.loading && state.items.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : state.items.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Empty',
                      style: GoogleFonts.manrope(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You don\'t have any notification at this time',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final notification = state.items[index];
                  return _NotificationCard(
                    notification: notification,
                    onTap: () {
                      ref
                          .read(notificationNotifierProvider.notifier)
                          .markAsRead(notification.id);
                    },
                    timeAgo: _formatTimeAgo(notification.createdAt),
                  );
                },
              ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;
  final String timeAgo;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: notification.isNew
                    ? const Color(0xFF2563EB)
                    : Colors.grey[300]!,
                width: notification.isNew ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: notification.isNew
                        ? const Color(0xFF2563EB).withOpacity(.1)
                        : Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications,
                    color: notification.isNew
                        ? const Color(0xFF2563EB)
                        : Colors.grey[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: notification.isNew
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: notification.isNew
                              ? const Color(0xFF101828)
                              : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.description,
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: notification.isNew
                              ? const Color(0xFF475467)
                              : Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        timeAgo,
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                if (notification.isNew)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(left: 8, top: 4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
