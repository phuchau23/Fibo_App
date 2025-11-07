import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swp_app/features/feedback/domain/entities/feedback_entities.dart';
import 'package:swp_app/features/feedback/presentation/blocs/feedback_providers.dart';
import 'package:swp_app/features/feedback/presentation/models/feedback_navigation.dart';
import 'package:swp_app/features/topic/presentation/blocs/topics_providers.dart';

const _helpfulStatuses = ['Helpful', 'Unhelpful', 'NeedReview'];

class FeedbackTab extends ConsumerStatefulWidget {
  final int sessionId;
  final ValueChanged<FeedbackNavigationRequest>? onNavigate;
  const FeedbackTab({super.key, required this.sessionId, this.onNavigate});

  @override
  ConsumerState<FeedbackTab> createState() => _FeedbackTabState();
}

class _FeedbackTabState extends ConsumerState<FeedbackTab>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FeedbackTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sessionId != widget.sessionId) {
      _initialized = false;
      _searchCtrl.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _bootstrap(resetFilters: true);
      });
    }
  }

  Future<void> _bootstrap({bool resetFilters = false}) async {
    final lecturerId = await ref.read(lecturerIdProvider.future);
    if (!mounted) return;
    final notifier = ref.read(feedbackNotifierProvider.notifier);
    notifier.configureSource(lecturerId: lecturerId);
    if (resetFilters) {
      notifier.setHelpfulFilter(null);
      notifier.setSearchTerm('');
    }
    await notifier.fetch();
    setState(() => _initialized = true);
  }

  Future<void> _refresh() async {
    await ref.read(feedbackNotifierProvider.notifier).refresh();
  }

  void _onHelpfulSelected(String? helpful) {
    ref.read(feedbackNotifierProvider.notifier).setHelpfulFilter(helpful);
  }

  void _onSearchChanged(String value) {
    ref.read(feedbackNotifierProvider.notifier).setSearchTerm(value);
  }

  Future<void> _updateHelpful(FeedbackEntity feedback, String helpful) async {
    final res = await ref.read(updateFeedbackProvider)(
      id: feedback.id,
      helpful: helpful,
      comment: feedback.comment,
    );
    res.fold(
      (l) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.message))),
      (r) async => await _refresh(),
    );
  }

  Future<void> _deleteFeedback(FeedbackEntity feedback) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa feedback?'),
        content: const Text('Bấm xác nhận để xóa feedback này.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final res = await ref.read(deleteFeedbackProvider)(feedback.id);
      res.fold(
        (l) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.message))),
        (r) async => await _refresh(),
      );
    }
  }

  Future<void> _openDetail(FeedbackEntity feedback) async {
    final result = await showModalBottomSheet<FeedbackNavigationRequest?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FeedbackDetailSheet(feedback: feedback),
    );
    if (result != null) {
      widget.onNavigate?.call(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(feedbackNotifierProvider);

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            physics: const BouncingScrollPhysics(),
            children: [
              Text(
                'Feedback Management',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF101828),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchCtrl,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm theo tên, comment, nội dung answer...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF98A2B3),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.black.withOpacity(.08),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    selected: state.helpfulFilter == null,
                    label: const Text('Tất cả'),
                    onSelected: (_) => _onHelpfulSelected(null),
                  ),
                  ..._helpfulStatuses.map(
                    (status) => ChoiceChip(
                      selected: state.helpfulFilter == status,
                      label: Text(status),
                      onSelected: (_) => _onHelpfulSelected(status),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (state.loading && state.items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (!state.loading && state.items.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Text(
                    _initialized
                        ? 'Chưa có feedback phù hợp với bộ lọc.'
                        : 'Đang tải dữ liệu...',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                )
              else
                ...state.items.map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: FeedbackCard(
                      feedback: f,
                      onViewDetail: () => _openDetail(f),
                      onMarkHelpful: () => _updateHelpful(f, 'Helpful'),
                      onMarkNeedReview: () => _updateHelpful(f, 'NeedReview'),
                      onMarkUnhelpful: () => _updateHelpful(f, 'Unhelpful'),
                      onDelete: () => _deleteFeedback(f),
                    ),
                  ),
                ),
              if (state.loading && state.items.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class FeedbackCard extends StatelessWidget {
  final FeedbackEntity feedback;
  final VoidCallback onViewDetail;
  final VoidCallback onMarkHelpful;
  final VoidCallback onMarkUnhelpful;
  final VoidCallback onMarkNeedReview;
  final VoidCallback onDelete;

  const FeedbackCard({
    super.key,
    required this.feedback,
    required this.onViewDetail,
    required this.onMarkHelpful,
    required this.onMarkUnhelpful,
    required this.onMarkNeedReview,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final r16 = BorderRadius.circular(18);
    final user = feedback.user;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: r16,
        border: Border.all(color: const Color(0xFFE4E7EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
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
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.firstName} ${user.lastName}',
                      style: GoogleFonts.manrope(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF101828),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${user.studentId ?? user.email} • ${feedback.topic?.name ?? 'Unknown topic'}',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: Colors.black.withOpacity(.55),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'detail':
                      onViewDetail();
                      break;
                    case 'helpful':
                      onMarkHelpful();
                      break;
                    case 'unhelpful':
                      onMarkUnhelpful();
                      break;
                    case 'review':
                      onMarkNeedReview();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'detail',
                    child: Text('Xem chi tiết'),
                  ),
                  const PopupMenuItem(
                    value: 'helpful',
                    child: Text('Đánh dấu Helpful'),
                  ),
                  const PopupMenuItem(
                    value: 'unhelpful',
                    child: Text('Đánh dấu Unhelpful'),
                  ),
                  const PopupMenuItem(
                    value: 'review',
                    child: Text('Need review'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Xóa feedback'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _BadgeLabel(status: feedback.helpful),
          const SizedBox(height: 10),
          if ((feedback.comment ?? '').isNotEmpty)
            Text(
              '“${feedback.comment}”',
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF344054),
              ),
            ),
          const SizedBox(height: 10),
          if ((feedback.answer?.content ?? '').isNotEmpty)
            Text(
              feedback.answer!.content!.replaceAll(RegExp(r'<[^>]*>'), ''),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: Colors.black.withOpacity(.65),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            _formatDate(feedback.createdAt),
            style: GoogleFonts.manrope(fontSize: 11, color: Colors.black45),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}

class _BadgeLabel extends StatelessWidget {
  final String status;
  const _BadgeLabel({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'Helpful':
        color = const Color(0xFF22C55E);
        break;
      case 'Unhelpful':
        color = const Color(0xFFEF4444);
        break;
      default:
        color = const Color(0xFFF97316);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class FeedbackDetailSheet extends ConsumerStatefulWidget {
  final FeedbackEntity feedback;
  const FeedbackDetailSheet({super.key, required this.feedback});

  @override
  ConsumerState<FeedbackDetailSheet> createState() =>
      _FeedbackDetailSheetState();
}

class _FeedbackDetailSheetState extends ConsumerState<FeedbackDetailSheet> {
  late String _selectedHelpful;
  late TextEditingController _commentCtrl;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _selectedHelpful = widget.feedback.helpful;
    _commentCtrl = TextEditingController(text: widget.feedback.comment ?? '');
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _submitting = true);
    final res = await ref.read(updateFeedbackProvider)(
      id: widget.feedback.id,
      helpful: _selectedHelpful,
      comment: _commentCtrl.text.trim().isEmpty
          ? null
          : _commentCtrl.text.trim(),
    );
    setState(() => _submitting = false);
    res.fold(
      (l) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.message))),
      (r) async {
        await ref.read(feedbackNotifierProvider.notifier).refresh();
        if (mounted) Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final feedback = widget.feedback;
    final user = feedback.user;
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
              'Chi tiết Feedback',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),
            _InfoSection(
              title: 'Thông tin người dùng',
              rows: [
                _InfoRow(
                  label: 'Họ tên',
                  value: '${user.firstName} ${user.lastName}',
                ),
                if (user.studentId != null)
                  _InfoRow(label: 'MSSV', value: user.studentId!),
                _InfoRow(label: 'Email', value: user.email),
                _InfoRow(label: 'Vai trò', value: user.role),
                if (user.classInfo != null) ...[
                  if (user.classInfo!.code != null)
                    _InfoRow(label: 'Lớp', value: user.classInfo!.code!),
                  if (user.classInfo!.lecturer != null)
                    _InfoRow(
                      label: 'Giảng viên',
                      value: user.classInfo!.lecturer!.fullName ?? 'N/A',
                    ),
                ],
                if (user.group != null && user.group!.name != null)
                  _InfoRow(label: 'Nhóm', value: user.group!.name!),
              ],
            ),
            const SizedBox(height: 20),
            if (feedback.topic != null)
              _InfoSection(
                title: 'Topic',
                rows: [
                  _InfoRow(label: 'Tên', value: feedback.topic!.name ?? 'N/A'),
                ],
              ),
            const SizedBox(height: 20),
            _InfoSection(
              title: 'Đánh giá',
              rows: [
                _InfoRow(label: 'Trạng thái', value: feedback.helpful),
                if ((feedback.comment ?? '').isNotEmpty)
                  _InfoRow(label: 'Comment', value: feedback.comment!),
                _InfoRow(
                  label: 'Ngày tạo',
                  value: _formatDate(feedback.createdAt),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if ((feedback.answer?.content ?? '').isNotEmpty) ...[
              _InfoSection(
                title: 'Câu trả lời AI',
                rows: [
                  _InfoRow(
                    label: 'Nội dung',
                    value: feedback.answer!.content!.replaceAll(
                      RegExp(r'<[^>]*>'),
                      '',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
            DropdownButtonFormField<String>(
              value: _selectedHelpful,
              decoration: const InputDecoration(
                labelText: 'Cập nhật trạng thái đánh giá',
              ),
              items: _helpfulStatuses
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedHelpful = value);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _commentCtrl,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Ghi chú'),
            ),
            const SizedBox(height: 20),
            if (feedback.answer != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(
                    FeedbackNavigationRequest(
                      target: FeedbackNavigationTarget.qa,
                      topicId: feedback.topic?.id,
                      topicName: feedback.topic?.name,
                      answerId: feedback.answer!.id,
                    ),
                  ),
                  icon: const Icon(Icons.question_answer_outlined),
                  label: const Text('Đi tới Q&A nguồn'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            if (feedback.topic != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(
                    FeedbackNavigationRequest(
                      target: FeedbackNavigationTarget.documents,
                      topicId: feedback.topic!.id,
                      topicName: feedback.topic!.name,
                    ),
                  ),
                  icon: const Icon(Icons.menu_book_outlined),
                  label: const Text('Đi tới tài liệu của Topic'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Lưu cập nhật'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<_InfoRow> rows;
  const _InfoSection({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withOpacity(.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 8),
          ...rows,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF101828),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
