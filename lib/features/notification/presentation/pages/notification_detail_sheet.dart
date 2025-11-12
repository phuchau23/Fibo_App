import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:swp_app/features/notification/domain/entities/notification_entities.dart';
import 'package:swp_app/features/notification/presentation/blocs/notification_providers.dart';

class NotificationDetailSheet extends ConsumerWidget {
  final NotificationEntity initialNotification;
  const NotificationDetailSheet({super.key, required this.initialNotification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(
      notificationDetailProvider(initialNotification.id),
    );
    final notification = detailAsync.maybeWhen(
      data: (data) => data,
      orElse: () => initialNotification,
    );

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Chi tiết thông báo',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            _InfoRow(label: 'Tiêu đề', value: notification.title),
            const SizedBox(height: 8),
            _InfoRow(label: 'Nội dung', value: notification.description),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Thời gian',
              value: DateFormat(
                'dd/MM/yyyy HH:mm',
              ).format(notification.createdAt.toLocal()),
            ),
            if (notification.relatedEntityType != null)
              const SizedBox(height: 8),
            if (notification.relatedEntityType != null)
              _InfoRow(
                label: 'Loại liên quan',
                value: notification.relatedEntityType!,
              ),
            if (notification.relatedEntityId != null) const SizedBox(height: 8),
            if (notification.relatedEntityId != null)
              _InfoRow(
                label: 'Mã liên quan',
                value: notification.relatedEntityId!,
              ),
            if ((notification.data ?? {}).isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Dữ liệu bổ sung',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF475467),
                ),
              ),
              const SizedBox(height: 8),
              ...notification.data!.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.key}: ',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF101828),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value?.toString() ?? '-',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            color: const Color(0xFF475467),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (_canOpenFeedback(notification))
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pop<String?>(notification.relatedEntityId);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Đi tới Feedback'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _canOpenFeedback(NotificationEntity notification) {
    final type = notification.relatedEntityType?.toLowerCase();
    return type == 'feedback' && notification.relatedEntityId != null;
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF475467),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF101828),
          ),
        ),
      ],
    );
  }
}
