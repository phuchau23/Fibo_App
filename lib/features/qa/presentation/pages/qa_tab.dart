import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swp_app/features/document/domain/entities/document_entities.dart';
import 'package:swp_app/features/document/presentation/blocs/document_providers.dart';
import 'package:swp_app/features/qa/domain/entities/qa_entities.dart';
import 'package:swp_app/features/qa/presentation/blocs/qa_providers.dart';
import 'package:swp_app/features/topic/domain/entities/topic_entity.dart';
import 'package:swp_app/features/topic/presentation/blocs/topics_providers.dart';

class QaTab extends ConsumerStatefulWidget {
  final int sessionId;
  final String? initialTopicId;
  final String? initialTopicName;
  final String? initialAnswerId;
  final String? initialAnswerContent;
  const QaTab({
    super.key,
    required this.sessionId,
    this.initialTopicId,
    this.initialTopicName,
    this.initialAnswerId,
    this.initialAnswerContent,
  });

  @override
  ConsumerState<QaTab> createState() => _QaTabState();
}

class _QaTabState extends ConsumerState<QaTab>
    with AutomaticKeepAliveClientMixin {
  String? _pendingAnswerId;
  String? _pendingAnswerContent;
  String? _selectedTopicId;
  String? _selectedTopicName;
  String? _selectedDocumentId;
  String? _selectedDocumentName;
  bool _initialized = false;

  bool get _hasFilters =>
      (_selectedTopicId != null) || (_selectedDocumentId != null);

  @override
  void initState() {
    super.initState();
    _pendingAnswerId = widget.initialAnswerId;
    _pendingAnswerContent = widget.initialAnswerContent;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureBasics();
    });
  }

  @override
  void didUpdateWidget(covariant QaTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sessionId != widget.sessionId) {
      setState(() {
        _selectedTopicId = null;
        _selectedTopicName = null;
        _selectedDocumentId = null;
        _selectedDocumentName = null;
        _initialized = false;
        _pendingAnswerId = widget.initialAnswerId;
        _pendingAnswerContent = widget.initialAnswerContent;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ensureBasics();
      });
    } else if (oldWidget.initialTopicId != widget.initialTopicId ||
        oldWidget.initialAnswerId != widget.initialAnswerId ||
        oldWidget.initialAnswerContent != widget.initialAnswerContent) {
      _pendingAnswerId = widget.initialAnswerId;
      _pendingAnswerContent = widget.initialAnswerContent;
      setState(() {
        _selectedTopicId = widget.initialTopicId;
        _selectedTopicName = widget.initialTopicName;
        _selectedDocumentId = null;
        _selectedDocumentName = null;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await ref
            .read(qaPairsNotifierProvider.notifier)
            .fetch(topicId: widget.initialTopicId);
        await _maybeOpenInitialAnswer();
      });
    }
  }

  Future<void> _ensureBasics() async {
    final topicsState = ref.read(topicsNotifierProvider);
    if (!topicsState.loading && topicsState.page == null) {
      await ref.read(topicsNotifierProvider.notifier).fetch(page: 1);
    }

    final lecturerId = await ref.read(lecturerIdProvider.future);
    if (!mounted) return;

    final notifier = ref.read(qaPairsNotifierProvider.notifier);
    notifier.configure(lecturerId: lecturerId);

    setState(() {
      _initialized = true;
      _selectedTopicId = widget.initialTopicId;
      _selectedTopicName = widget.initialTopicName;
      _selectedDocumentId = null;
      _selectedDocumentName = null;
    });
    if (lecturerId != null) {
      await notifier.fetch(topicId: widget.initialTopicId);
      await _maybeOpenInitialAnswer();
    }
  }

  Future<void> _pickTopic() async {
    final topicsState = ref.read(topicsNotifierProvider);
    final selected = await showModalBottomSheet<TopicEntity?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _TopicPickerSheet(
        state: topicsState,
        currentTopicId: _selectedTopicId,
      ),
    );
    if (!mounted) return;
    if (selected == null && _selectedTopicId == null) {
      return;
    }
    setState(() {
      _selectedTopicId = selected?.id;
      _selectedTopicName = selected?.name;
      _selectedDocumentId = null;
      _selectedDocumentName = null;
      _pendingAnswerId = null;
      _pendingAnswerContent = null;
    });
    await ref
        .read(qaPairsNotifierProvider.notifier)
        .fetch(topicId: selected?.id);
  }

  Future<void> _pickDocument() async {
    if (_selectedTopicId == null) return;
    final usecase = ref.read(getDocumentsByTopicProvider);
    final res = await usecase(
      topicId: _selectedTopicId!,
      page: 1,
      pageSize: 100,
    );
    final documents = res.fold<List<DocumentEntity>>((l) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.message)));
      return const [];
    }, (r) => r.items);
    if (!mounted) return;
    final selected = await showModalBottomSheet<DocumentEntity?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DocumentPickerSheet(
        documents: documents,
        currentId: _selectedDocumentId,
      ),
    );
    if (selected != null || _selectedDocumentId != null) {
      setState(() {
        _selectedDocumentId = selected?.id;
        _selectedDocumentName = selected?.title;
        _pendingAnswerId = null;
        _pendingAnswerContent = null;
      });
      await ref
          .read(qaPairsNotifierProvider.notifier)
          .fetch(topicId: _selectedTopicId, documentId: selected?.id);
    }
  }

  Future<void> _refresh() async {
    await ref.read(qaPairsNotifierProvider.notifier).refresh();
  }

  Future<void> _clearFilters() async {
    if (!_hasFilters) return;
    setState(() {
      _selectedTopicId = null;
      _selectedTopicName = null;
      _selectedDocumentId = null;
      _selectedDocumentName = null;
      _pendingAnswerId = null;
      _pendingAnswerContent = null;
    });
    await ref.read(qaPairsNotifierProvider.notifier).fetch();
  }

  Future<void> _removeTopicFilter() async {
    if (_selectedTopicId == null) return;
    setState(() {
      _selectedTopicId = null;
      _selectedTopicName = null;
      _selectedDocumentId = null;
      _selectedDocumentName = null;
      _pendingAnswerId = null;
      _pendingAnswerContent = null;
    });
    await ref.read(qaPairsNotifierProvider.notifier).fetch();
  }

  Future<void> _removeDocumentFilter() async {
    if (_selectedDocumentId == null) return;
    setState(() {
      _selectedDocumentId = null;
      _selectedDocumentName = null;
      _pendingAnswerId = null;
      _pendingAnswerContent = null;
    });
    await ref
        .read(qaPairsNotifierProvider.notifier)
        .fetch(topicId: _selectedTopicId);
  }

  Future<void> _goToPage(int page) async {
    await ref.read(qaPairsNotifierProvider.notifier).goToPage(page);
  }

  Future<void> _maybeOpenInitialAnswer() async {
    final id = _pendingAnswerId;
    final normalizedContent = _normalizeText(_pendingAnswerContent);
    if (id == null && (normalizedContent == null)) return;
    if (!mounted) return;

    QAPairEntity? pair;
    final items =
        ref.read(qaPairsNotifierProvider).page?.items ?? const <QAPairEntity>[];
    for (final item in items) {
      if (id != null && item.id == id) {
        pair = item;
        break;
      }
    }

    if (pair == null && normalizedContent != null) {
      for (final item in items) {
        if (_normalizeText(item.answerText) == normalizedContent) {
          pair = item;
          break;
        }
      }
    }

    if (pair == null && id != null) {
      pair = await _fetchPairById(id);
    }

    if (pair != null && mounted) {
      _pendingAnswerId = null;
      _pendingAnswerContent = null;
      await Future.delayed(const Duration(milliseconds: 120));
      await _showPairDetail(pair, highlight: true);
    } else if (mounted) {
      _pendingAnswerId = null;
      _pendingAnswerContent = null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy Q&A nguồn phù hợp.')),
      );
    }
  }

  Future<QAPairEntity?> _fetchPairById(String id) async {
    try {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );
      }
      final value = await ref.read(qaDetailProvider(id).future);
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      return value;
    } catch (_) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      return null;
    }
  }

  String? _normalizeText(String? input) {
    if (input == null) return null;
    final normalized = input
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .toLowerCase();
    return normalized.isEmpty ? null : normalized;
  }

  void _openCreateSheet() async {
    final topicsState = ref.read(topicsNotifierProvider);
    final topics = topicsState.page?.items ?? const <TopicEntity>[];

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CreateQAPairSheet(
        topics: topics,
        initialTopicId: _selectedTopicId,
        initialDocumentId: _selectedDocumentId,
        onCreated: () async {
          Navigator.of(ctx).pop();
          await ref.read(qaPairsNotifierProvider.notifier).refresh();
        },
      ),
    );
  }

  Future<void> _openDetail(QAPairEntity pair) async {
    await _showPairDetail(pair);
  }

  Future<void> _showPairDetail(
    QAPairEntity pair, {
    bool highlight = false,
  }) async {
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QaDetailSheet(pair: pair, highlightAnswer: highlight),
    );
  }

  Future<void> _editPair(QAPairEntity pair) async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => UpdateQAPairSheet(
        pair: pair,
        onUpdated: () async {
          Navigator.of(ctx).pop(true);
        },
      ),
    );
    if (updated == true) {
      await ref.read(qaPairsNotifierProvider.notifier).refresh();
    }
  }

  Future<void> _deletePair(QAPairEntity pair) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa Q&A?'),
        content: Text('Bạn chắc chắn muốn xóa "${pair.questionText}"?'),
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
      final res = await ref.read(deleteQAPairProvider)(pair.id);
      res.fold(
        (l) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.message))),
        (r) async => await _refresh(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final qaState = ref.watch(qaPairsNotifierProvider);
    final topicsState = ref.watch(topicsNotifierProvider);
    final pairs = qaState.page?.items ?? const <QAPairEntity>[];
    final pageMeta = qaState.page;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            children: [
              Text(
                'Q&A Management',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF101828),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _FilterButton(
                      icon: Icons.layers_outlined,
                      label: _selectedTopicName ?? 'Lọc theo Topic (tùy chọn)',
                      onPressed: (topicsState.loading && !_initialized)
                          ? null
                          : _pickTopic,
                      loading: topicsState.loading && !_initialized,
                      active: _selectedTopicId != null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FilterButton(
                      icon: Icons.description_outlined,
                      label: _selectedTopicId == null
                          ? 'Chọn Topic trước để lọc tài liệu'
                          : (_selectedDocumentName ??
                                'Lọc theo tài liệu (tùy chọn)'),
                      onPressed: _selectedTopicId == null
                          ? null
                          : _pickDocument,
                      active: _selectedDocumentId != null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _hasFilters ? _clearFilters : null,
                  icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                  label: const Text('Xóa lọc'),
                ),
              ),
              if (_hasFilters) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (_selectedTopicName != null)
                      Chip(
                        label: Text('Topic: $_selectedTopicName'),
                        onDeleted: () => _removeTopicFilter(),
                      ),
                    if (_selectedDocumentName != null)
                      Chip(
                        label: Text('Document: $_selectedDocumentName'),
                        onDeleted: () => _removeDocumentFilter(),
                      ),
                  ],
                ),
              ],
              if (qaState.error != null) ...[
                const SizedBox(height: 12),
                _ErrorBanner(message: qaState.error!),
              ],
              if (qaState.loading && pairs.isEmpty) ...[
                const SizedBox(height: 40),
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 40),
              ] else if (!qaState.loading && pairs.isEmpty) ...[
                const SizedBox(height: 40),
                _EmptyState(
                  message: _hasFilters
                      ? 'Không tìm thấy Q&A phù hợp với bộ lọc.'
                      : 'Chưa có Q&A nào được tạo.',
                ),
                const SizedBox(height: 40),
              ] else ...[
                const SizedBox(height: 12),
                for (final pair in pairs) ...[
                  _QACard(
                    pair: pair,
                    onTap: () => _openDetail(pair),
                    onEdit: () => _editPair(pair),
                    onDelete: () => _deletePair(pair),
                  ),
                  const SizedBox(height: 14),
                ],
              ],
              if (qaState.loading && pairs.isNotEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (pageMeta != null && pageMeta.totalPages > 1) ...[
                const SizedBox(height: 12),
                _PaginationBar(
                  currentPage: pageMeta.currentPage,
                  totalPages: pageMeta.totalPages,
                  onPrev: pageMeta.hasPreviousPage
                      ? () => _goToPage(pageMeta.currentPage - 1)
                      : null,
                  onNext: pageMeta.hasNextPage
                      ? () => _goToPage(pageMeta.currentPage + 1)
                      : null,
                ),
              ],
            ],
          ),
        ),
        Positioned.fill(
          child: SafeArea(
            minimum: const EdgeInsets.only(right: 16, bottom: 100),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton.extended(
                onPressed: _openCreateSheet,
                backgroundColor: const Color(0xFF2563EB),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Tạo Q&A',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _FilterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool active;
  final bool loading;
  const _FilterButton({
    required this.icon,
    required this.label,
    this.onPressed,
    this.active = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final iconColor = !enabled
        ? const Color(0xFF98A2B3)
        : (active ? const Color(0xFF2563EB) : const Color(0xFF475467));
    final textColor = !enabled
        ? const Color(0xFF98A2B3)
        : (active ? const Color(0xFF2563EB) : const Color(0xFF101828));
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        side: BorderSide(
          color: active ? const Color(0xFF2563EB) : const Color(0xFFE4E7EC),
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          if (loading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: enabled
                  ? const Color(0xFF98A2B3)
                  : const Color(0x8098A2B3),
            ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4E6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFDC2626)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF991B1B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.inbox_outlined, size: 48, color: Color(0xFF98A2B3)),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF475467),
          ),
        ),
      ],
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: onPrev,
          icon: const Icon(Icons.chevron_left),
          label: const Text('Trước'),
        ),
        const SizedBox(width: 16),
        Text(
          'Trang $currentPage / $totalPages',
          style: GoogleFonts.manrope(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF475467),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
          label: const Text('Sau'),
        ),
      ],
    );
  }
}

class _TopicPickerSheet extends StatelessWidget {
  final TopicsState state;
  final String? currentTopicId;
  const _TopicPickerSheet({required this.state, this.currentTopicId});

  @override
  Widget build(BuildContext context) {
    final topics = state.page?.items ?? const <TopicEntity>[];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Chọn Topic',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.all_inbox_outlined),
            title: const Text('Tất cả Q&A'),
            trailing: currentTopicId == null
                ? const Icon(Icons.check, color: Color(0xFF2563EB))
                : null,
            onTap: () => Navigator.of(context).pop(null),
          ),
          if (state.loading)
            const Center(child: CircularProgressIndicator())
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: topics.length,
                itemBuilder: (ctx, i) {
                  final t = topics[i];
                  final selected = currentTopicId == t.id;
                  return ListTile(
                    title: Text(t.name),
                    subtitle:
                        (t.description != null && t.description!.isNotEmpty)
                        ? Text(t.description!)
                        : null,
                    trailing: selected
                        ? const Icon(Icons.check, color: Color(0xFF2563EB))
                        : null,
                    onTap: () => Navigator.of(context).pop(t),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _DocumentPickerSheet extends StatelessWidget {
  final List<DocumentEntity> documents;
  final String? currentId;
  const _DocumentPickerSheet({required this.documents, this.currentId});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Chọn tài liệu liên quan (tùy chọn)',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('Không liên kết tài liệu'),
            trailing: currentId == null
                ? const Icon(Icons.check)
                : const SizedBox(),
            onTap: () => Navigator.of(context).pop(null),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: documents.length,
              itemBuilder: (ctx, i) {
                final doc = documents[i];
                final selected = currentId == doc.id;
                return ListTile(
                  title: Text(doc.title),
                  subtitle: Text('Version ${doc.version} • ${doc.status}'),
                  trailing: selected ? const Icon(Icons.check) : null,
                  onTap: () => Navigator.of(context).pop(doc),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QACard extends StatelessWidget {
  final QAPairEntity pair;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _QACard({
    required this.pair,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final r16 = BorderRadius.circular(18);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: r16,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: r16,
            border: Border.all(color: const Color(0xFFE4E7EC)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.question_answer,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pair.questionText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF101828),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      pair.answerText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        color: const Color(0xA6000000),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _Badge(
                          text: pair.status,
                          color: const Color(0xFFE0EAFF),
                          textColor: const Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _fmt(pair.updatedAt),
                          style: GoogleFonts.manrope(
                            fontSize: 11.5,
                            color: Colors.black45,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  final Color? textColor;
  const _Badge({required this.text, required this.color, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: textColor ?? const Color(0xFF475467),
        ),
      ),
    );
  }
}

class QaDetailSheet extends StatelessWidget {
  final QAPairEntity pair;
  final bool highlightAnswer;
  const QaDetailSheet({
    super.key,
    required this.pair,
    this.highlightAnswer = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Question',
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              pair.questionText,
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Answer',
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: highlightAnswer
                  ? const EdgeInsets.all(12)
                  : EdgeInsets.zero,
              decoration: highlightAnswer
                  ? BoxDecoration(
                      color: const Color(0xFFFFF7E6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFB020)),
                    )
                  : null,
              child: Text(
                pair.answerText,
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  color: const Color(0xFF101828),
                ),
              ),
            ),
            const SizedBox(height: 18),
            _detailRow('Status', pair.status),
            _detailRow('Created at', _fmt(pair.createdAt)),
            _detailRow('Updated at', _fmt(pair.updatedAt)),
            if (pair.documentId != null)
              _detailRow('Document ID', pair.documentId!),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
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
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF101828),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}

class CreateQAPairSheet extends ConsumerStatefulWidget {
  final List<TopicEntity> topics;
  final String? initialTopicId;
  final String? initialDocumentId;
  final VoidCallback onCreated;
  const CreateQAPairSheet({
    super.key,
    required this.topics,
    this.initialTopicId,
    this.initialDocumentId,
    required this.onCreated,
  });

  @override
  ConsumerState<CreateQAPairSheet> createState() => _CreateQAPairSheetState();
}

class _CreateQAPairSheetState extends ConsumerState<CreateQAPairSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _questionCtrl = TextEditingController();
  final TextEditingController _answerCtrl = TextEditingController();
  String? _topicId;
  String? _documentId;
  List<DocumentEntity> _documents = const <DocumentEntity>[];
  bool _loadingDocuments = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _topicId = widget.initialTopicId;
    _documentId = widget.initialDocumentId;
    if (_topicId != null) {
      Future.microtask(() => _loadDocuments(_topicId!));
    }
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    _answerCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDocuments(String topicId) async {
    setState(() {
      _loadingDocuments = true;
    });
    final usecase = ref.read(getDocumentsByTopicProvider);
    final res = await usecase(topicId: topicId, page: 1, pageSize: 100);
    if (!mounted) return;
    res.fold(
      (l) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.message)));
        setState(() {
          _documents = const <DocumentEntity>[];
          _documentId = null;
          _loadingDocuments = false;
        });
      },
      (r) {
        setState(() {
          _documents = r.items;
          if (!_documents.any((doc) => doc.id == _documentId)) {
            _documentId = null;
          }
          _loadingDocuments = false;
        });
      },
    );
  }

  void _onTopicChanged(String? value) {
    setState(() {
      _topicId = value;
      _documentId = null;
      _documents = const <DocumentEntity>[];
    });
    if (value != null) {
      _loadDocuments(value);
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _submitting = true);
    final res = await ref.read(createQAPairProvider)(
      topicId: _topicId,
      documentId: _documentId,
      questionText: _questionCtrl.text.trim(),
      answerText: _answerCtrl.text.trim(),
    );
    setState(() => _submitting = false);
    res.fold(
      (l) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.message))),
      (r) => widget.onCreated(),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                'Tạo Q&A mới',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                initialValue: _topicId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Liên kết Topic (tùy chọn)',
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Không liên kết Topic'),
                  ),
                  ...widget.topics.map(
                    (topic) => DropdownMenuItem<String?>(
                      value: topic.id,
                      child: Text(topic.name),
                    ),
                  ),
                ],
                onChanged: (value) => _onTopicChanged(value),
              ),
              if (_loadingDocuments) ...[
                const SizedBox(height: 8),
                const LinearProgressIndicator(minHeight: 4),
              ],
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                initialValue: _documentId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: _topicId == null
                      ? 'Chọn Topic để hiển thị Document'
                      : 'Liên kết Document (tùy chọn)',
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Không liên kết Document'),
                  ),
                  ..._documents.map(
                    (doc) => DropdownMenuItem<String?>(
                      value: doc.id,
                      child: Text(doc.title),
                    ),
                  ),
                ],
                onChanged: _topicId == null
                    ? null
                    : (value) => setState(() => _documentId = value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _questionCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Question'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Không được để trống'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _answerCtrl,
                maxLines: 6,
                decoration: const InputDecoration(labelText: 'Answer'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Không được để trống'
                    : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
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
                      : const Text('Tạo Q&A'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpdateQAPairSheet extends ConsumerStatefulWidget {
  final QAPairEntity pair;
  final Future<void> Function() onUpdated;
  const UpdateQAPairSheet({
    super.key,
    required this.pair,
    required this.onUpdated,
  });

  @override
  ConsumerState<UpdateQAPairSheet> createState() => _UpdateQAPairSheetState();
}

class _UpdateQAPairSheetState extends ConsumerState<UpdateQAPairSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionCtrl;
  late TextEditingController _answerCtrl;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _questionCtrl = TextEditingController(text: widget.pair.questionText);
    _answerCtrl = TextEditingController(text: widget.pair.answerText);
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    _answerCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _submitting = true);
    final res = await ref.read(updateQAPairProvider)(
      id: widget.pair.id,
      questionText: _questionCtrl.text.trim(),
      answerText: _answerCtrl.text.trim(),
    );
    setState(() => _submitting = false);
    res.fold(
      (l) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.message))),
      (r) async => await widget.onUpdated(),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                'Chỉnh sửa Q&A',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _questionCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Question'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Không được để trống'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _answerCtrl,
                maxLines: 6,
                decoration: const InputDecoration(labelText: 'Answer'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Không được để trống'
                    : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
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
                      : const Text('Lưu thay đổi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
