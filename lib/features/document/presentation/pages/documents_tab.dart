import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swp_app/features/document/domain/entities/document_entities.dart';
import 'package:swp_app/features/document/presentation/blocs/document_providers.dart';
import 'package:swp_app/features/topic/domain/entities/topic_entity.dart';
import 'package:swp_app/features/topic/presentation/blocs/topics_providers.dart';
import 'package:swp_app/features/document/presentation/pages/document_detail_sheet.dart'
    as doc_detail;

class DocumentsTab extends ConsumerStatefulWidget {
  final int sessionId;
  final String? initialTopicId;
  final String? initialTopicName;
  const DocumentsTab({
    super.key,
    required this.sessionId,
    this.initialTopicId,
    this.initialTopicName,
  });

  @override
  ConsumerState<DocumentsTab> createState() => _DocumentsTabState();
}

class _DocumentsTabState extends ConsumerState<DocumentsTab>
    with AutomaticKeepAliveClientMixin {
  String? _selectedTopicId;
  String? _selectedTopicName;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  @override
  void didUpdateWidget(covariant DocumentsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sessionId != widget.sessionId) {
      _initialized = false;
      _initialize();
    }
  }

  Future<void> _initialize() async {
    final typesState = ref.read(documentTypesNotifierProvider);
    if (!typesState.loading && typesState.items.isEmpty) {
      await ref.read(documentTypesNotifierProvider.notifier).fetch();
    }
    final lecturerId = await ref.read(lecturerIdProvider.future);
    if (lecturerId != null) {
      final topicsState = ref.read(myTopicsNotifierProvider);
      if (!topicsState.loading && topicsState.page == null) {
        await ref
            .read(myTopicsNotifierProvider.notifier)
            .fetch(page: 1, lecturerId: lecturerId);
        if (!mounted) return;
      }
    }
    if (!mounted) return;
    setState(() {
      _initialized = true;
      if (widget.initialTopicId != null && widget.initialTopicName != null) {
        _selectedTopicId = widget.initialTopicId;
        _selectedTopicName = widget.initialTopicName;
        ref
            .read(documentsNotifierProvider.notifier)
            .fetch(topicId: widget.initialTopicId!);
      } else {
        _selectedTopicId = null;
        _selectedTopicName = null;
      }
    });
  }

  Future<void> _pickTopic() async {
    final lecturerId = await ref.read(lecturerIdProvider.future);
    var topicsState = ref.read(myTopicsNotifierProvider);
    if ((topicsState.page == null || topicsState.page!.items.isEmpty) &&
        !topicsState.loading &&
        lecturerId != null) {
      await ref
          .read(myTopicsNotifierProvider.notifier)
          .fetch(page: 1, lecturerId: lecturerId);
      if (!mounted) return;
      topicsState = ref.read(myTopicsNotifierProvider);
    }

    final topics = topicsState.page?.items ?? const <TopicEntity>[];
    if (topics.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn chưa phụ trách Topic nào.')),
      );
      return;
    }

    if (!mounted) return;
    final selected = await showModalBottomSheet<TopicEntity?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          _TopicPickerSheet(topics: topics, selectedId: _selectedTopicId),
    );

    if (selected != null) {
      if (!mounted) return;
      setState(() {
        _selectedTopicId = selected.id;
        _selectedTopicName = selected.name;
      });
      await ref
          .read(documentsNotifierProvider.notifier)
          .fetch(topicId: selected.id);
    }
  }

  Future<void> _refresh() async {
    if (_selectedTopicId != null) {
      await ref.read(documentsNotifierProvider.notifier).refresh();
    }
  }

  void _openUploadSheet() {
    if (_selectedTopicId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hãy chọn Topic trước khi upload.')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => UploadDocumentSheet(
        topicId: _selectedTopicId!,
        topicName: _selectedTopicName ?? '',
        onUploaded: () async {
          Navigator.of(ctx).pop();
          await ref.read(documentsNotifierProvider.notifier).refresh();
        },
      ),
    );
  }

  Future<void> _openDetail(DocumentEntity doc) async {
    await doc_detail.showDocumentDetailSheet(context, documentId: doc.id);
  }

  void _openUpdateSheet(DocumentEntity doc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => UpdateDocumentSheet(
        document: doc,
        onUpdated: () async {
          Navigator.of(ctx).pop();
          await ref.read(documentsNotifierProvider.notifier).refresh();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final docsState = ref.watch(documentsNotifierProvider);
    final topicsState = ref.watch(myTopicsNotifierProvider);

    final docs = docsState.page?.items ?? const <DocumentEntity>[];

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            children: [
              Text(
                'Documents',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF101828),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickTopic,
                child: _TopicSelectorCard(
                  title: _selectedTopicName ?? 'Chọn Topic',
                  isLoading: topicsState.loading && !_initialized,
                ),
              ),
              const SizedBox(height: 20),
              if (docsState.loading && docs.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (!docsState.loading &&
                  (_selectedTopicId == null || docs.isEmpty))
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        _selectedTopicId == null
                            ? 'Chưa chọn Topic nào'
                            : 'Chưa có tài liệu cho Topic này',
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              if (_selectedTopicId != null)
                for (final doc in docs) ...[
                  _DocumentCard(
                    document: doc,
                    onEdit: () => _openUpdateSheet(doc),
                    onTap: () => _openDetail(doc),
                    onDelete: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Xóa tài liệu?'),
                          content: Text('Bạn có chắc muốn xóa "${doc.title}"?'),
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
                        await ref.read(deleteDocumentProvider)(doc.id);
                        await ref
                            .read(documentsNotifierProvider.notifier)
                            .refresh();
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                ],
              if (docsState.loading && docs.isNotEmpty)
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
                onPressed: _openUploadSheet,
                backgroundColor: const Color(0xFFFF7B54),
                label: const Text(
                  'Upload',
                  style: TextStyle(color: Colors.white),
                ),
                icon: const Icon(Icons.upload_file, color: Colors.white),
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

class _TopicSelectorCard extends StatelessWidget {
  final String title;
  final bool isLoading;
  const _TopicSelectorCard({required this.title, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final border = Border.all(color: const Color(0x14000000));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: border,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.layers_outlined, color: Color(0xFF98A2B3)),
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
            ),
          if (!isLoading)
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

class _DocumentCard extends StatelessWidget {
  final DocumentEntity document;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  const _DocumentCard({
    required this.document,
    required this.onDelete,
    required this.onTap,
    required this.onEdit,
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
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
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
                  color: const Color(0xFFFFF0D5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.insert_drive_file,
                  color: Color(0xFFF97316),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 16.5,
                        height: 1.3,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF101828),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _Badge(
                          text: 'Version ${document.version}',
                          color: const Color(0xFFEEF2FF),
                        ),
                        const SizedBox(width: 6),
                        _Badge(
                          text: document.status,
                          color: const Color(0xFFFFF4E5),
                          textColor: const Color(0xFFF97316),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Created at ${_fmt(document.createdAt)}',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: const Color(0x73000000),
                        fontWeight: FontWeight.w600,
                      ),
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
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
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

class _TopicPickerSheet extends StatelessWidget {
  final List<TopicEntity> topics;
  final String? selectedId;
  const _TopicPickerSheet({required this.topics, this.selectedId});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Chọn Topic',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: topics.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final t = topics[i];
                final isSelected = selectedId == t.id;
                return GestureDetector(
                  onTap: () => Navigator.pop(context, t),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFF4E5)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFF97316)
                            : const Color(0xFFE4E7EC),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                const Color(0xFFF97316),
                                const Color(0xFFFACC15),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.name,
                                style: GoogleFonts.manrope(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF101828),
                                ),
                              ),
                              if ((t.description ?? '').isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    t.description!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.manrope(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFFF97316),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UploadDocumentSheet extends ConsumerStatefulWidget {
  final String topicId;
  final String topicName;
  final VoidCallback onUploaded;
  const UploadDocumentSheet({
    super.key,
    required this.topicId,
    required this.topicName,
    required this.onUploaded,
  });

  @override
  ConsumerState<UploadDocumentSheet> createState() =>
      _UploadDocumentSheetState();
}

class _UploadDocumentSheetState extends ConsumerState<UploadDocumentSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleCtrl = TextEditingController();
  String? _selectedTypeId;
  PlatformFile? _pickedFile;
  bool _submitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: false);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedFile = result.files.first;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_pickedFile?.path == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Hãy chọn file tải lên.')));
      return;
    }
    if (_selectedTypeId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Chọn Document Type.')));
      return;
    }

    setState(() => _submitting = true);
    final multipart = await MultipartFile.fromFile(
      _pickedFile!.path!,
      filename: _pickedFile!.name,
    );
    final res = await ref.read(uploadDocumentProvider)(
      topicId: widget.topicId,
      documentTypeId: _selectedTypeId!,
      title: _titleCtrl.text.trim(),
      file: multipart,
    );
    setState(() => _submitting = false);
    res.fold(
      (l) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.message))),
      (r) => widget.onUploaded(),
    );
  }

  Future<void> _createNewType() async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tạo Document Type'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Tên loại tài liệu'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Tạo'),
          ),
        ],
      ),
    );

    if (name == null || name.isEmpty) return;
    final err = await ref
        .read(documentTypesNotifierProvider.notifier)
        .create(name);
    if (err != null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(err)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final typesState = ref.watch(documentTypesNotifierProvider);
    final types = typesState.items;

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
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Upload Document',
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
              DropdownButtonFormField<String>(
                key: ValueKey('upload-type-${_selectedTypeId ?? 'none'}'),
                initialValue: _selectedTypeId,
                items: types
                    .map(
                      (t) => DropdownMenuItem(value: t.id, child: Text(t.name)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedTypeId = v),
                decoration: const InputDecoration(labelText: 'Document Type'),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _createNewType,
                  icon: const Icon(Icons.add),
                  label: const Text('Tạo loại mới'),
                ),
              ),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Không được để trống'
                    : null,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.attach_file),
                label: Text(_pickedFile?.name ?? 'Chọn file'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Tải lên'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpdateDocumentSheet extends ConsumerStatefulWidget {
  final DocumentEntity document;
  final VoidCallback onUpdated;
  const UpdateDocumentSheet({
    super.key,
    required this.document,
    required this.onUpdated,
  });

  @override
  ConsumerState<UpdateDocumentSheet> createState() =>
      _UpdateDocumentSheetState();
}

class _UpdateDocumentSheetState extends ConsumerState<UpdateDocumentSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _versionCtrl;
  String? _selectedTopicId;
  String? _selectedTypeId;
  PlatformFile? _pickedFile;
  bool _saving = false;
  bool _optionsLoading = true;
  String _currentStatus = 'Draft';
  String? _statusAction;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.document.title);
    _versionCtrl = TextEditingController(
      text: widget.document.version.toString(),
    );
    _selectedTopicId = widget.document.topicId;
    _selectedTypeId = widget.document.documentTypeId;
    _currentStatus = widget.document.status;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOptions();
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _versionCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    setState(() => _optionsLoading = true);
    final lecturerId = await ref.read(lecturerIdProvider.future);
    if (lecturerId != null) {
      await ref
          .read(myTopicsNotifierProvider.notifier)
          .fetch(lecturerId: lecturerId);
    }
    final typesState = ref.read(documentTypesNotifierProvider);
    if (!typesState.loading && typesState.items.isEmpty) {
      await ref.read(documentTypesNotifierProvider.notifier).fetch();
    }
    if (mounted) {
      setState(() => _optionsLoading = false);
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: false);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedFile = result.files.first;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_selectedTopicId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Hãy chọn Topic.')));
      return;
    }
    if (_selectedTypeId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Hãy chọn Document Type.')));
      return;
    }
    final version = int.tryParse(_versionCtrl.text.trim());
    if (version == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Version phải là số nguyên.')),
      );
      return;
    }

    MultipartFile? multipart;
    if (_pickedFile?.path != null) {
      multipart = await MultipartFile.fromFile(
        _pickedFile!.path!,
        filename: _pickedFile!.name,
      );
    }

    setState(() => _saving = true);
    final result = await ref.read(updateDocumentProvider)(
      id: widget.document.id,
      topicId: _selectedTopicId!,
      documentTypeId: _selectedTypeId!,
      title: _titleCtrl.text.trim(),
      version: version,
      file: multipart,
    );
    setState(() => _saving = false);
    result.fold(
      (l) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.message))),
      (r) => widget.onUpdated(),
    );
  }

  Future<void> _publish() async {
    setState(() => _statusAction = 'publish');
    final res = await ref.read(publishDocumentProvider)(widget.document.id);
    setState(() => _statusAction = null);
    res.fold(
      (l) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.message))),
      (r) async {
        setState(() => _currentStatus = 'Active');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã xuất bản tài liệu.')));
        await ref.read(documentsNotifierProvider.notifier).refresh();
      },
    );
  }

  Future<void> _unpublish() async {
    setState(() => _statusAction = 'unpublish');
    final res = await ref.read(unpublishDocumentProvider)(widget.document.id);
    setState(() => _statusAction = null);
    res.fold(
      (l) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.message))),
      (r) async {
        setState(() => _currentStatus = 'Draft');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã chuyển tài liệu về trạng thái Draft.'),
          ),
        );
        await ref.read(documentsNotifierProvider.notifier).refresh();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final topicState = ref.watch(myTopicsNotifierProvider);
    final typeState = ref.watch(documentTypesNotifierProvider);
    final topics = [...(topicState.page?.items ?? const <TopicEntity>[])];
    if (_selectedTopicId != null &&
        topics.every((t) => t.id != _selectedTopicId)) {
      topics.add(
        TopicEntity(
          id: _selectedTopicId!,
          name: 'Topic hiện tại',
          status: 'Active',
          createdAt: DateTime.now(),
          description: null,
        ),
      );
    }
    final types = [...typeState.items];
    if (_selectedTypeId != null &&
        types.every((t) => t.id != _selectedTypeId)) {
      types.add(
        DocumentTypeEntity(
          id: _selectedTypeId!,
          name: 'Document type hiện tại',
          status: 'Active',
          createdAt: DateTime.now(),
        ),
      );
    }
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Update Document',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              if (_optionsLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (!_optionsLoading) ...[
                DropdownButtonFormField<String>(
                  key: ValueKey('update-topic-${_selectedTopicId ?? 'none'}'),
                  initialValue: _selectedTopicId,
                  decoration: const InputDecoration(labelText: 'Topic'),
                  items: topics
                      .map(
                        (topic) => DropdownMenuItem(
                          value: topic.id,
                          child: Text(topic.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedTopicId = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  key: ValueKey('update-type-${_selectedTypeId ?? 'none'}'),
                  initialValue: _selectedTypeId,
                  decoration: const InputDecoration(labelText: 'Document Type'),
                  items: types
                      .map(
                        (type) => DropdownMenuItem(
                          value: type.id,
                          child: Text(type.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _selectedTypeId = value),
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Không được để trống'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _versionCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Version'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Không được để trống'
                    : null,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.attach_file),
                label: Text(_pickedFile?.name ?? 'Chọn file mới (tùy chọn)'),
              ),
              const SizedBox(height: 8),
              Text(
                'Nếu không chọn file mới, hệ thống sẽ giữ nguyên file hiện tại.',
                style: GoogleFonts.manrope(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _StatusChip(status: _currentStatus),
                  const SizedBox(width: 12),
                  Text(
                    'Trạng thái hiện tại',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475467),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          (_statusAction != null ||
                              _currentStatus.toLowerCase() == 'active')
                          ? null
                          : _publish,
                      child: _statusAction == 'publish'
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Xuất bản'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          (_statusAction != null ||
                              _currentStatus.toLowerCase() == 'draft')
                          ? null
                          : _unpublish,
                      child: _statusAction == 'unpublish'
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Hủy xuất bản'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _saving
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

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (status.toLowerCase()) {
      case 'active':
        bg = const Color(0xFFEFF4FF);
        fg = const Color(0xFF2563EB);
        break;
      case 'needreview':
        bg = const Color(0xFFFFF7E6);
        fg = const Color(0xFFF97316);
        break;
      default:
        bg = const Color(0xFFF4F4F5);
        fg = const Color(0xFF475467);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
