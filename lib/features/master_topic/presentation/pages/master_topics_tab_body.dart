import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swp_app/core/services/session_provider.dart';
import 'package:swp_app/features/domains/domain/entities/domain_entity.dart';
import 'package:swp_app/features/domains/presentation/blocs/domain_providers.dart';

import 'package:swp_app/features/master_topic/domain/entities/master_topic_entity.dart';
import 'package:swp_app/features/master_topic/presentation/blocs/master_topics_providers.dart';
import 'package:swp_app/features/semester/presentation/blocs/semester_providers.dart';

class MasterTopicsTabBody extends ConsumerStatefulWidget {
  const MasterTopicsTabBody({super.key});

  @override
  ConsumerState<MasterTopicsTabBody> createState() =>
      _MasterTopicsTabBodyState();
}

class _MasterTopicsTabBodyState extends ConsumerState<MasterTopicsTabBody> {
  // Paging
  int _page = 1;
  final int _pageSize = 10;
  String? _deletingId;

  // Create / Edit controllers
  final TextEditingController _domainIdCtrl = TextEditingController();
  final TextEditingController _semesterIdCtrl = TextEditingController();
  final TextEditingController _lecturersCtrl =
      TextEditingController(); // comma-separated
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(masterTopicsListProvider.notifier)
          .fetch(page: _page, pageSize: _pageSize);
    });
  }

  @override
  void dispose() {
    _domainIdCtrl.dispose();
    _semesterIdCtrl.dispose();
    _lecturersCtrl.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _refetch() async {
    await ref
        .read(masterTopicsListProvider.notifier)
        .fetch(page: _page, pageSize: _pageSize);
  }

  List<String> _parseLecturerIds(String raw) {
    return raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  /* ----------------------- CREATE DIALOG ----------------------- */
  Future<void> _openCreateDialog() async {
    // reset controllers
    _domainIdCtrl.clear();
    _semesterIdCtrl.clear();
    _lecturersCtrl.clear();
    _nameCtrl.clear();
    _descCtrl.clear();

    // Bảo đảm có data cho dropdowns
    final domainsSt = ref.read(domainsNotifierProvider);
    final semSt = ref.read(semestersProvider);
    if ((domainsSt.page?.items.isEmpty ?? true)) {
      await ref
          .read(domainsNotifierProvider.notifier)
          .fetch(page: 1, pageSize: 50);
    }
    if (semSt.items.isEmpty && !semSt.loading) {
      await ref.read(semestersProvider.notifier).fetch(page: 1, pageSize: 50);
    }

    String? selectedDomainId;
    String? selectedSemesterId;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final domains =
            ref.watch(domainsNotifierProvider).page?.items ??
            const <DomainEntity>[];
        final semState = ref.watch(semestersProvider);
        final semesters = semState.items;

        final border = OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        );

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFAFAFA),
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFEAEAEA), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.add_box_rounded,
                          color: Color(0xFFFF6A00),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Create master topic',
                          style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: .2,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),

                // Body
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: LayoutBuilder(
                    builder: (c, cons) {
                      final isWide = cons.maxWidth >= 640;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Grid 2 cột khi đủ rộng
                          Wrap(
                            spacing: 16,
                            runSpacing: 12,
                            children: [
                              // Domain
                              SizedBox(
                                width: isWide
                                    ? (cons.maxWidth - 16) / 2
                                    : cons.maxWidth,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _FieldLabel('Domain *'),
                                    DropdownButtonFormField<String>(
                                      value: selectedDomainId,
                                      isExpanded: true,
                                      decoration: InputDecoration(
                                        hintText: 'Select a domain',
                                        border: border,
                                        enabledBorder: border,
                                        focusedBorder: border.copyWith(
                                          borderSide: const BorderSide(
                                            color: Color(0xFFFB923C),
                                            width: 1.5,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 14,
                                            ),
                                      ),
                                      items: domains
                                          .map(
                                            (d) => DropdownMenuItem(
                                              value: d.id,
                                              child: Text(
                                                d.name.isEmpty
                                                    ? '(No name)'
                                                    : d.name,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (v) => selectedDomainId = v,
                                    ),
                                  ],
                                ),
                              ),

                              // Semester
                              SizedBox(
                                width: isWide
                                    ? (cons.maxWidth - 16) / 2
                                    : cons.maxWidth,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _FieldLabel('Semester'),
                                    DropdownButtonFormField<String>(
                                      value: selectedSemesterId,
                                      isExpanded: true,
                                      decoration: InputDecoration(
                                        hintText:
                                            'Select a semester (optional)',
                                        border: border,
                                        enabledBorder: border,
                                        focusedBorder: border.copyWith(
                                          borderSide: const BorderSide(
                                            color: Color(0xFFFB923C),
                                            width: 1.5,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 14,
                                            ),
                                      ),
                                      items: [
                                        const DropdownMenuItem<String>(
                                          value: null,
                                          child: Text('— None —'),
                                        ),
                                        ...semesters.map(
                                          (s) => DropdownMenuItem(
                                            value: s.id,
                                            child: Text(
                                              '${s.code} • ${s.term} ${s.year}',
                                            ),
                                          ),
                                        ),
                                      ],
                                      onChanged: (v) => selectedSemesterId = v,
                                    ),
                                  ],
                                ),
                              ),

                              // Name
                              SizedBox(
                                width: cons.maxWidth,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _FieldLabel('Name *'),
                                    TextField(
                                      controller: _nameCtrl,
                                      decoration: InputDecoration(
                                        hintText: 'Enter topic name',
                                        border: border,
                                        enabledBorder: border,
                                        focusedBorder: border.copyWith(
                                          borderSide: const BorderSide(
                                            color: Color(0xFFFB923C),
                                            width: 1.5,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 14,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Description
                              SizedBox(
                                width: cons.maxWidth,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _FieldLabel('Description'),
                                    TextField(
                                      controller: _descCtrl,
                                      maxLines: 4,
                                      decoration: InputDecoration(
                                        hintText: 'Write a short description…',
                                        border: border,
                                        enabledBorder: border,
                                        focusedBorder: border.copyWith(
                                          borderSide: const BorderSide(
                                            color: Color(0xFFFB923C),
                                            width: 1.5,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.fromLTRB(
                                              12,
                                              12,
                                              12,
                                              12,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                size: 18,
                                color: Colors.black38,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Lecturer sẽ tự động set theo tài khoản khi cần; ở bước tạo sẽ truyền null.',
                                  style: Theme.of(ctx).textTheme.bodySmall
                                      ?.copyWith(color: Colors.black45),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Footer actions
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Create'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6A00),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          final domainId = selectedDomainId;
                          final semesterId = selectedSemesterId;
                          final name = _nameCtrl.text.trim();
                          final desc = _descCtrl.text.trim();

                          if ((domainId == null || domainId.isEmpty) ||
                              name.isEmpty) {
                            _snack('Domain và Name là bắt buộc', true);
                            return;
                          }

                          await ref
                              .read(masterTopicCreateProvider.notifier)
                              .submit(
                                domainId: domainId,
                                semesterId:
                                    (semesterId == null || semesterId.isEmpty)
                                    ? null
                                    : semesterId,
                                lecturerIds: [], // 👈 theo yêu cầu: truyền null
                                name: name,
                                description: desc.isEmpty ? null : desc,
                              );

                          final st = ref.read(masterTopicCreateProvider);
                          if (!mounted) return;
                          if (st.error != null) {
                            _snack(st.error!, true);
                          } else {
                            Navigator.of(ctx).pop();
                            await _refetch();
                            _snack('Created successfully');
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /* ------------------------ EDIT DIALOG ------------------------ */
  Future<void> _openEditDialog(MasterTopicEntity item) async {
    // Lấy userId từ token (ẩn lecturerIds)
    final session = ref.read(sessionServiceProvider);
    final currentLecturerId = await session.userId ?? '';

    // Bảo đảm đã có data cho dropdowns
    final domainsSt = ref.read(domainsNotifierProvider);
    final semSt = ref.read(semestersProvider);
    if ((domainsSt.page?.items.isEmpty ?? true)) {
      await ref
          .read(domainsNotifierProvider.notifier)
          .fetch(page: 1, pageSize: 50);
    }
    if (semSt.items.isEmpty && !semSt.loading) {
      await ref.read(semestersProvider.notifier).fetch(page: 1, pageSize: 50);
    }

    // Giá trị mặc định
    String? selectedDomainId = item.domain.id;
    String? selectedSemesterId = item.semester?.id;
    _nameCtrl.text = item.name;
    _descCtrl.text = item.description ?? '';

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final domains =
            ref.watch(domainsNotifierProvider).page?.items ??
            const <DomainEntity>[];
        final semState = ref.watch(semestersProvider);
        final semesters = semState.items;

        final border = OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        );

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header đẹp
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    border: const Border(
                      bottom: BorderSide(color: Color(0xFFEAEAEA), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.edit_note_rounded,
                          color: Color(0xFFFF6A00),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edit master topic',
                              style: Theme.of(ctx).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: .2,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.name.isEmpty ? 'Untitled' : item.name,
                              style: Theme.of(ctx).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.black54),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),

                // Body form
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: LayoutBuilder(
                    builder: (c, cons) {
                      final isWide = cons.maxWidth >= 640;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Grid 2 cột khi đủ rộng
                          Wrap(
                            spacing: 16,
                            runSpacing: 12,
                            children: [
                              SizedBox(
                                width: isWide
                                    ? (cons.maxWidth - 16) / 2
                                    : cons.maxWidth,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _FieldLabel('Domain *'),
                                    DropdownButtonFormField<String>(
                                      value: selectedDomainId,
                                      isExpanded: true,
                                      decoration: InputDecoration(
                                        hintText: 'Select a domain',
                                        border: border,
                                        enabledBorder: border,
                                        focusedBorder: border.copyWith(
                                          borderSide: const BorderSide(
                                            color: Color(0xFFFB923C),
                                            width: 1.5,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 14,
                                            ),
                                      ),
                                      items: domains
                                          .map(
                                            (d) => DropdownMenuItem(
                                              value: d.id,
                                              child: Text(
                                                d.name.isEmpty
                                                    ? '(No name)'
                                                    : d.name,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (v) => selectedDomainId = v,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: isWide
                                    ? (cons.maxWidth - 16) / 2
                                    : cons.maxWidth,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _FieldLabel('Semester'),
                                    DropdownButtonFormField<String>(
                                      value: selectedSemesterId,
                                      isExpanded: true,
                                      decoration: InputDecoration(
                                        hintText:
                                            'Select a semester (optional)',
                                        border: border,
                                        enabledBorder: border,
                                        focusedBorder: border.copyWith(
                                          borderSide: const BorderSide(
                                            color: Color(0xFFFB923C),
                                            width: 1.5,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 14,
                                            ),
                                      ),
                                      items: [
                                        const DropdownMenuItem<String>(
                                          value: null,
                                          child: Text('— None —'),
                                        ),
                                        ...semesters.map(
                                          (s) => DropdownMenuItem(
                                            value: s.id,
                                            child: Text(
                                              '${s.code} • ${s.term} ${s.year}',
                                            ),
                                          ),
                                        ),
                                      ],
                                      onChanged: (v) => selectedSemesterId = v,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: cons.maxWidth,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _FieldLabel('Name *'),
                                    TextField(
                                      controller: _nameCtrl,
                                      decoration: InputDecoration(
                                        hintText: 'Enter topic name',
                                        border: border,
                                        enabledBorder: border,
                                        focusedBorder: border.copyWith(
                                          borderSide: const BorderSide(
                                            color: Color(0xFFFB923C),
                                            width: 1.5,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 14,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: cons.maxWidth,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _FieldLabel('Description'),
                                    TextField(
                                      controller: _descCtrl,
                                      maxLines: 4,
                                      decoration: InputDecoration(
                                        hintText: 'Write a short description…',
                                        border: border,
                                        enabledBorder: border,
                                        focusedBorder: border.copyWith(
                                          borderSide: const BorderSide(
                                            color: Color(0xFFFB923C),
                                            width: 1.5,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.fromLTRB(
                                              12,
                                              12,
                                              12,
                                              12,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                size: 18,
                                color: Colors.black38,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Lecturer sẽ tự động gán theo tài khoản của bạn.',
                                  style: Theme.of(ctx).textTheme.bodySmall
                                      ?.copyWith(color: Colors.black45),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Footer actions
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.save_rounded),
                        label: const Text('Save changes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6A00),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          final name = _nameCtrl.text.trim();
                          final desc = _descCtrl.text.trim();

                          if ((selectedDomainId == null ||
                                  selectedDomainId!.isEmpty) ||
                              name.isEmpty) {
                            _snack('Domain và Name là bắt buộc', true);
                            return;
                          }

                          await ref
                              .read(masterTopicUpdateProvider.notifier)
                              .submit(
                                id: item.id,
                                domainId: selectedDomainId!,
                                semesterId:
                                    (selectedSemesterId == null ||
                                        selectedSemesterId!.isEmpty)
                                    ? null
                                    : selectedSemesterId,
                                lecturerIds: [
                                  currentLecturerId,
                                ], // auto từ token
                                name: name,
                                description: desc.isEmpty ? null : desc,
                              );

                          final st = ref.read(masterTopicUpdateProvider);
                          if (!mounted) return;
                          if (st.error != null) {
                            _snack(st.error!, true);
                          } else {
                            Navigator.of(ctx).pop();
                            await _refetch();
                            _snack('Updated successfully');
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _snack(String msg, [bool isError = false]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red[700] : null,
      ),
    );
  }

  Future<void> _confirmDelete(MasterTopicEntity item) async {
    final yes = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete master topic?'),
        content: Text(
          '“${item.name.isEmpty ? 'Untitled' : item.name}” sẽ bị xóa vĩnh viễn.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (yes != true) return;

    setState(() => _deletingId = item.id);
    final err = await ref
        .read(masterTopicDeleteProvider.notifier)
        .remove(item.id);
    if (!mounted) return;
    setState(() => _deletingId = null);

    if (err != null) {
      _snack(err, true);
    } else {
      await _refetch();
      _snack('Deleted successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(masterTopicsListProvider);

    if (state.page?.items.isEmpty ?? true) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _refetch,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            itemCount: state.page!.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              final item = state.page!.items[i];
              return _MasterTopicCardItem(
                item: item,
                onEdit: () => _openEditDialog(item),
                onDelete: () => _confirmDelete(item),
                isBusy: _deletingId == item.id,
              );
            },
          ),
        ),

        // FAB
        Positioned(
          right: 16,
          bottom: 100,
          child: FloatingActionButton(
            onPressed: _openCreateDialog,
            backgroundColor: const Color.fromARGB(255, 253, 115, 23),
            foregroundColor: Colors.white,
            elevation: 2,
            child: const Icon(Icons.add, size: 28),
          ),
        ),

        // Simple pagination controls (Prev / Next)
        Positioned(
          left: 16,
          right: 16,
          bottom: 24,
          child: Row(
            children: [
              ElevatedButton(
                onPressed: (state.page?.hasPreviousPage ?? false)
                    ? () async {
                        setState(() => _page = (_page - 1).clamp(1, 99999));
                        await _refetch();
                      }
                    : null,
                child: const Text('Prev'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: (state.page?.hasNextPage ?? false)
                    ? () async {
                        setState(() => _page = _page + 1);
                        await _refetch();
                      }
                    : null,
                child: const Text('Next'),
              ),
              const Spacer(),
              if (state.page != null)
                Text(
                  'Total: ${state.page!.totalItems} • Page ${state.page!.currentPage}/${state.page!.totalPages}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MasterTopicCardItem extends StatelessWidget {
  final MasterTopicEntity item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isBusy;

  const _MasterTopicCardItem({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.isBusy,
  });

  static const double _minHeight = 84;

  @override
  Widget build(BuildContext context) {
    final r16 = BorderRadius.circular(16);

    final Color statusDot = isBusy
        ? const Color(0xFFEA8C00)
        : const Color(0xFF28C76F);
    final String statusText = isBusy ? 'IN PROGRESS' : 'OPEN';

    // dữ liệu hiển thị
    final title = (item.name.isEmpty) ? 'Untitled topic' : item.name;
    final subLeft = (item.description == null || item.description!.isEmpty)
        ? 'For —'
        : 'For ${item.description}';
    // nếu có domain/semester thì ghép thêm (an toàn null)
    final domainName = (() {
      try {
        // đổi theo model của bạn nếu khác
        return (item.domain?.name ?? '').trim();
      } catch (_) {
        return '';
      }
    })();
    final semesterCode = (() {
      try {
        return (item.semester?.code ?? '').trim();
      } catch (_) {
        return '';
      }
    })();

    final subRight = [
      if (domainName.isNotEmpty) domainName,
      if (semesterCode.isNotEmpty) semesterCode,
      '2m', // nếu có updatedAt/createdAt thì thay time-ago thật
    ].join('   •   ');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: r16,
        onTap: () => _showTopicDetailsSheet(context, item),
        child: Container(
          constraints: const BoxConstraints(minHeight: _minHeight),
          padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: r16,
            border: Border.all(color: const Color(0xFFEDEDED)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // dải màu vibrant-pastel bên trái
              Positioned.fill(
                left: 0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: _vibrantPastelColor(item.name.hashCode),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // hàng label + chip trạng thái + actions
                        Row(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.layers_rounded,
                                  size: 14,
                                  color: Color(0xFF98A2B3),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'TOPICS',
                                  style: GoogleFonts.manrope(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0,
                                    color: const Color(0xFF98A2B3),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            _StatusChip(text: statusText, dotColor: statusDot),
                            const SizedBox(width: 6),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // tiêu đề
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            fontSize: 16.5,
                            height: 1.3,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF101828),
                            letterSpacing: .2,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // dòng phụ trái/phải
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                subLeft,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.manrope(
                                  fontSize: 12.5,
                                  color: const Color(0xFF6B7280),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              subRight,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.manrope(
                                fontSize: 12.5,
                                color: const Color(0xFF98A2B3),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 220.ms).slideY(begin: .06, end: 0);
  }

  // Bảng màu vibrant-pastel tối ưu cho nền hồng/đào
  Color _vibrantPastelColor(int seed) {
    final colors = [
      const Color(0xFF7DE2D1), // mint
      const Color(0xFFA78BFA), // lilac
      const Color(0xFFFCD34D), // lemon
      const Color(0xFFFB7185), // coral pink
      const Color(0xFF86EFAC), // spring green
      const Color(0xFF60A5FA), // baby blue
    ];
    final index = seed.abs() % colors.length;
    return colors[index];
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final Color dotColor;
  const _StatusChip({required this.text, required this.dotColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6E8EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.manrope(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: .4,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

void _showTopicDetailsSheet(BuildContext context, MasterTopicEntity item) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: theme.colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.62,
        maxChildSize: 0.92,
        minChildSize: 0.45,
        builder: (_, controller) {
          final title = item.name.isEmpty ? 'Untitled' : item.name;
          final desc = (item.description ?? '').trim();
          final hasSemester = item.semester != null;

          return ListView(
            controller: controller,
            padding: EdgeInsets.zero,
            children: [
              // Grip
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white70 : Colors.black26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Header gradient
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [const Color(0xFF2C2C2C), const Color(0xFF1E1E1E)]
                        : [const Color(0xFFFFF3E9), const Color(0xFFFFE0CC)],
                  ),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(.06)
                        : Colors.black.withOpacity(.06),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: GoogleFonts.manrope(
                        fontSize: 22,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF2B2B2B),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(
                          icon: Icons.category_outlined,
                          label: item.domain.name,
                          isDark: isDark,
                        ),
                        if (hasSemester)
                          _InfoChip(
                            icon: Icons.date_range_outlined,
                            label:
                                '${item.semester!.code} • ${item.semester!.term} ${item.semester!.year}',
                            isDark: isDark,
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    // Created at (góc phải)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Created • ${_fmtDt(item.createdAt)}',
                        style: GoogleFonts.manrope(
                          fontSize: 12.5,
                          color: isDark
                              ? Colors.white70
                              : Colors.black.withOpacity(.55),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Description card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1C1C1C)
                      : const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withOpacity(.04),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                  ],
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(.06)
                        : Colors.black.withOpacity(.06),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Details',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (desc.isEmpty)
                        Text(
                          'No details provided.',
                          style: GoogleFonts.manrope(
                            fontSize: 15.5,
                            height: 1.6,
                            fontStyle: FontStyle.italic,
                            color: isDark
                                ? Colors.white70
                                : Colors.black.withOpacity(.6),
                          ),
                        )
                      else
                        SelectableText(
                          desc,
                          style: GoogleFonts.manrope(
                            fontSize: 15.5,
                            height: 1.6,
                            color: isDark
                                ? Colors.white.withOpacity(.9)
                                : Colors.black.withOpacity(.85),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Meta section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF171717)
                      : const Color(0xFFF9F9FB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(.06)
                        : Colors.black.withOpacity(.05),
                  ),
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.category_outlined,
                      label: 'Domain',
                      value: item.domain.name,
                      isDark: isDark,
                    ),
                    if (hasSemester)
                      _InfoRow(
                        icon: Icons.event_note_outlined,
                        label: 'Semester',
                        value:
                            '${item.semester!.code} • ${item.semester!.term} ${item.semester!.year}',
                        isDark: isDark,
                      ),
                    _InfoRow(
                      icon: Icons.access_time_rounded,
                      label: 'Created at',
                      value: _fmtDt(item.createdAt),
                      isDark: isDark,
                      showDivider: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
            ],
          );
        },
      );
    },
  );
}

/// Chip nho nhỏ cho metadata
class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101010) : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(.08)
              : Colors.black.withOpacity(.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark ? Colors.white70 : Colors.black.withOpacity(.65),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? Colors.white.withOpacity(.92)
                  : const Color(0xFF2B2B2B),
            ),
          ),
        ],
      ),
    );
  }
}

/// Hàng thông tin có icon + label trái, value phải
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          dense: true,
          leading: Icon(
            icon,
            size: 20,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          title: Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          trailing: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? Colors.white.withOpacity(.95)
                    : const Color(0xFF2B2B2B),
              ),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 0.7,
            indent: 14,
            endIndent: 14,
            color: isDark
                ? Colors.white.withOpacity(.06)
                : Colors.black.withOpacity(.06),
          ),
      ],
    );
  }
}

/// Format datetime: 24h HH:mm • dd/MM/yyyy
String _fmtDt(DateTime d) {
  final local = d.toLocal();
  final h = local.hour.toString().padLeft(2, '0');
  final m = local.minute.toString().padLeft(2, '0');
  final dd = local.day.toString().padLeft(2, '0');
  final mm = local.month.toString().padLeft(2, '0');
  final yyyy = local.year.toString();
  return '$h:$m • $dd/$mm/$yyyy';
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: Colors.black87,
          letterSpacing: .2,
        ),
      ),
    );
  }
}
