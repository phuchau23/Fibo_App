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
  const QaTab({
    super.key,
    required this.sessionId,
    this.initialTopicId,
    this.initialTopicName,
    this.initialAnswerId,
  });

  @override
  ConsumerState<QaTab> createState() => _QaTabState();
}

class _QaTabState extends ConsumerState<QaTab>
    with AutomaticKeepAliveClientMixin {
  String? _selectedTopicId;
  String? _selectedTopicName;
  String? _selectedDocumentId;
  String? _selectedDocumentName;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
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
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ensureBasics();
      });
    }
  }

  Future<void> _ensureBasics() async {
    final topicsState = ref.read(topicsNotifierProvider);
    if (!topicsState.loading && topicsState.page == null) {
      await ref.read(topicsNotifierProvider.notifier).fetch(page: 1);
    }
    if (!mounted) return;
    setState(() {
      _initialized = true;
      if (widget.initialTopicId != null && widget.initialTopicName != null) {
        _selectedTopicId = widget.initialTopicId;
        _selectedTopicName = widget.initialTopicName;
        ref
            .read(qaPairsNotifierProvider.notifier)
            .fetch(topicId: widget.initialTopicId!);
      } else {
        _selectedTopicId = null;
        _selectedTopicName = null;
        _selectedDocumentId = null;
        _selectedDocumentName = null;
      }
    });
  }

  Future<void> _pickTopic() async {
    final topicsState = ref.read(topicsNotifierProvider);
    final selected = await showModalBottomSheet<TopicEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _TopicPickerSheet(state: topicsState),
    );
    if (selected != null) {
      setState(() {
        _selectedTopicId = selected.id;
        _selectedTopicName = selected.name;
        _selectedDocumentId = null;
        _selectedDocumentName = null;
      });
      await ref
          .read(qaPairsNotifierProvider.notifier)
          .fetch(topicId: selected.id);
    }
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
      });
      await ref
          .read(qaPairsNotifierProvider.notifier)
          .fetch(topicId: _selectedTopicId!, documentId: selected?.id);
    }
  }

  Future<void> _refresh() async {
    if (_selectedTopicId != null) {
      await ref.read(qaPairsNotifierProvider.notifier).refresh();
    }
  }

  void _openCreateSheet() async {
    if (_selectedTopicId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Hãy chọn Topic trước.')));
      return;
    }
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CreateQAPairSheet(
        topicId: _selectedTopicId!,
        topicName: _selectedTopicName ?? '',
        documents: documents,
        defaultDocumentId: _selectedDocumentId,
        onCreated: () async {
          Navigator.of(ctx).pop();
          await ref.read(qaPairsNotifierProvider.notifier).refresh();
        },
      ),
    );
  }

  void _openDetail(QAPairEntity pair) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QaDetailSheet(pair: pair),
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

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            physics: const BouncingScrollPhysics(),
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
              GestureDetector(
                onTap: _pickTopic,
                child: _SelectorCard(
                  icon: Icons.layers_outlined,
                  title: _selectedTopicName ?? 'Chọn Topic',
                  isLoading: topicsState.loading && !_initialized,
                ),
              ),
              if (_selectedTopicId != null) ...[
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _pickDocument,
                  child: _SelectorCard(
                    icon: Icons.description_outlined,
                    title:
                        _selectedDocumentName ?? 'Lọc theo tài liệu (tùy chọn)',
                    isLoading: false,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              if (qaState.loading && pairs.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (!qaState.loading &&
                  (_selectedTopicId == null || (pairs.isEmpty)))
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Text(
                    _selectedTopicId == null
                        ? 'Chưa chọn Topic nào'
                        : 'Chưa có Q&A cho lựa chọn hiện tại',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
              if (_selectedTopicId != null)
                for (final pair in pairs) ...[
                  _QACard(
                    pair: pair,
                    onTap: () => _openDetail(pair),
                    onEdit: () => _editPair(pair),
                    onDelete: () => _deletePair(pair),
                  ),
                  const SizedBox(height: 14),
                ],
              if (qaState.loading && pairs.isNotEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(),
                  ),
                ),
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

class _SelectorCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isLoading;
  const _SelectorCard({
    required this.icon,
    required this.title,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF98A2B3)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF101828),
              ),
            ),
          ),
          if (isLoading)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 24,
              color: Color(0xFF98A2B3),
            ),
        ],
      ),
    );
  }
}

class _TopicPickerSheet extends StatelessWidget {
  final TopicsState state;
  const _TopicPickerSheet({required this.state});

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
          if (state.loading)
            const Center(child: CircularProgressIndicator())
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: topics.length,
                itemBuilder: (ctx, i) {
                  final t = topics[i];
                  return ListTile(
                    title: Text(t.name),
                    subtitle:
                        (t.description != null && t.description!.isNotEmpty)
                        ? Text(t.description!)
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.05),
                blurRadius: 16,
                offset: const Offset(0, 8),
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
                        color: Colors.black.withOpacity(.65),
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
  const QaDetailSheet({super.key, required this.pair});

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
            Text(
              pair.answerText,
              style: GoogleFonts.manrope(
                fontSize: 15,
                color: const Color(0xFF101828),
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
  final String topicId;
  final String topicName;
  final List<DocumentEntity> documents;
  final String? defaultDocumentId;
  final VoidCallback onCreated;
  const CreateQAPairSheet({
    super.key,
    required this.topicId,
    required this.topicName,
    required this.documents,
    this.defaultDocumentId,
    required this.onCreated,
  });

  @override
  ConsumerState<CreateQAPairSheet> createState() => _CreateQAPairSheetState();
}

class _CreateQAPairSheetState extends ConsumerState<CreateQAPairSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _questionCtrl = TextEditingController();
  final TextEditingController _answerCtrl = TextEditingController();
  String? _documentId;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _documentId = widget.defaultDocumentId;
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
    final res = await ref.read(createQAPairProvider)(
      topicId: widget.topicId,
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
              const SizedBox(height: 4),
              Text(
                'Topic: ${widget.topicName}',
                style: GoogleFonts.manrope(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                value: _documentId,
                decoration: const InputDecoration(
                  labelText: 'Liên kết Document (tùy chọn)',
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Không liên kết'),
                  ),
                  ...widget.documents.map(
                    (doc) => DropdownMenuItem<String?>(
                      value: doc.id,
                      child: Text(doc.title),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _documentId = value),
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
