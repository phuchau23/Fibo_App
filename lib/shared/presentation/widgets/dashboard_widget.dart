import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swp_app/features/feedback/domain/entities/feedback_entities.dart';
import 'package:swp_app/features/feedback/presentation/blocs/feedback_providers.dart';
import 'package:swp_app/features/feedback/presentation/pages/feedback_tab.dart';
import 'package:swp_app/features/topic/presentation/blocs/topics_providers.dart';
import 'package:swp_app/shared/presentation/providers/navigation_provider.dart';

class DashboardWidget extends ConsumerWidget {
  const DashboardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lecturerIdAsync = ref.watch(lecturerIdProvider);
    final feedbackState = ref.watch(feedbackNotifierProvider);

    return lecturerIdAsync.when(
      data: (lecturerId) {
        // Configure feedback source if not already configured
        final notifier = ref.read(feedbackNotifierProvider.notifier);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifier.configureSource(lecturerId: lecturerId);
          if (feedbackState.page == null) {
            notifier.fetch();
          }
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Dashboard',
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _StatsSection(feedbackState: feedbackState),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Feedback',
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref
                          .read(navigationRequestProvider.notifier)
                          .state = const NavigationRequest(
                        target: NavigationTarget.courseFeedback,
                      );
                    },
                    child: Text(
                      'Xem tất cả',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFF8C42),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _RecentFeedbackList(feedbackState: feedbackState),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Text(
            'Error loading dashboard: $e',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  final FeedbackState feedbackState;
  const _StatsSection({required this.feedbackState});

  @override
  Widget build(BuildContext context) {
    final items = feedbackState.page?.items ?? const [];
    final total = items.length;
    final helpful = items.where((f) => f.helpful == 'Helpful').length;
    final unhelpful = items.where((f) => f.helpful == 'Unhelpful').length;
    final needReview = items.where((f) => f.helpful == 'NeedReview').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: 'Total',
              value: total.toString(),
              color: const Color(0xFF2563EB),
              icon: Icons.feedback_outlined,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'Helpful',
              value: helpful.toString(),
              color: const Color(0xFF22C55E),
              icon: Icons.thumb_up_outlined,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'Unhelpful',
              value: unhelpful.toString(),
              color: const Color(0xFFEF4444),
              icon: Icons.thumb_down_outlined,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'Need Review',
              value: needReview.toString(),
              color: const Color(0xFFF97316),
              icon: Icons.rate_review_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentFeedbackList extends StatelessWidget {
  final FeedbackState feedbackState;
  const _RecentFeedbackList({required this.feedbackState});

  @override
  Widget build(BuildContext context) {
    final items = feedbackState.page?.items ?? const [];
    final recent = items.take(5).toList();

    if (feedbackState.loading && items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (recent.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Text(
            'Chưa có feedback nào',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: recent.length,
        itemBuilder: (context, index) {
          final feedback = recent[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _FeedbackCard(feedback: feedback),
          );
        },
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final FeedbackEntity feedback;
  const _FeedbackCard({required this.feedback});

  @override
  Widget build(BuildContext context) {
    final user = feedback.user;
    Color statusColor;
    switch (feedback.helpful) {
      case 'Helpful':
        statusColor = const Color(0xFF22C55E);
        break;
      case 'Unhelpful':
        statusColor = const Color(0xFFEF4444);
        break;
      default:
        statusColor = const Color(0xFFF97316);
    }

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => FeedbackDetailSheet(feedback: feedback),
        );
      },
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFE0F2FE),
                  child: Text(
                    user.firstName.isNotEmpty
                        ? user.firstName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user.firstName} ${user.lastName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF101828),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        feedback.topic?.name ?? 'Unknown topic',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                feedback.helpful,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ),
            const SizedBox(height: 10),
            if ((feedback.comment ?? '').isNotEmpty)
              Expanded(
                child: Text(
                  feedback.comment!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: const Color(0xFF344054),
                    height: 1.4,
                  ),
                ),
              )
            else
              Expanded(
                child: Text(
                  feedback.answer?.content?.replaceAll(
                        RegExp(r'<[^>]*>'),
                        '',
                      ) ??
                      'No comment',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              _formatDate(feedback.createdAt),
              style: GoogleFonts.manrope(fontSize: 10, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    final now = DateTime.now();
    final diff = now.difference(local);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes == 0) {
          return 'Vừa xong';
        }
        return '${diff.inMinutes} phút trước';
      }
      return '${diff.inHours} giờ trước';
    } else if (diff.inDays == 1) {
      return 'Hôm qua';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    }
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  }
}
