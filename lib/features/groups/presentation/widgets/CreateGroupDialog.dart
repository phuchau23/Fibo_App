import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swp_app/features/groups/presentation/blocs/group_providers.dart';

class CreateGroupDialog extends ConsumerStatefulWidget {
  const CreateGroupDialog({super.key, required this.classId});
  final String classId;

  @override
  ConsumerState<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends ConsumerState<CreateGroupDialog> {
  late final TextEditingController nameCtrl;
  late final TextEditingController descCtrl;
  late final FocusNode nameFocus;
  late final FocusNode descFocus;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController();
    descCtrl = TextEditingController();
    nameFocus = FocusNode();
    descFocus = FocusNode();

    // Autofocus sau frame đầu để an toàn
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) nameFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    nameFocus.dispose();
    descFocus.dispose();
    super.dispose();
  }

  // --- helpers ---
  void _safePop<T extends Object?>(BuildContext context, [T? result]) {
    // bỏ focus + defer sang frame kế tiếp để tránh _dependents.isEmpty
    FocusScope.of(context).unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop<T>(result);
    });
  }

  Future<void> _submit() async {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tên nhóm không được trống')),
      );
      return;
    }

    // Chỉ trigger submit, KHÔNG pop tại đây
    await ref
        .read(createGroupControllerProvider.notifier)
        .submit(
          // Nếu notifier của bạn dùng tên method khác (vd: create),
          // đổi "submit" thành tên method thực tế tại đây.
          classId: widget.classId,
          name: name,
          description: descCtrl.text.trim().isEmpty
              ? null
              : descCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createGroupControllerProvider);
    final isLoading = createState.isLoading;

    // Lắng nghe state để pop sau khi thành công hoặc show lỗi
    ref.listen(createGroupControllerProvider, (prev, next) {
      if (prev?.isLoading == true && next.hasValue && mounted) {
        _safePop(context, true); // tạo thành công
      }
      if (next.hasError && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error.toString())));
      }
    });

    return WillPopScope(
      onWillPop: () async => !isLoading, // chặn back khi đang submit
      child: AlertDialog(
        elevation: 2,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        contentPadding: EdgeInsets.zero,
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

        title: Row(
          children: const [
            Icon(Icons.group_add_outlined),
            SizedBox(width: 10),
            Text('Tạo nhóm mới', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),

        content: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            8 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  focusNode: nameFocus,
                  enabled: !isLoading,
                  textInputAction: TextInputAction.next,
                  maxLength: 60,
                  decoration: InputDecoration(
                    labelText: 'Tên nhóm',
                    hintText: 'VD: Nhóm 3 – Mobile SWP',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    counterText: '',
                  ),
                  onSubmitted: (_) {
                    if (!mounted) return;
                    if (!isLoading) descFocus.requestFocus();
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  focusNode: descFocus,
                  enabled: !isLoading,
                  textInputAction: TextInputAction.done,
                  maxLength: 160,
                  maxLines: 3,
                  minLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Mô tả (tuỳ chọn)',
                    hintText: 'Mô tả ngắn về mục tiêu, phạm vi, công việc…',
                    prefixIcon: const Icon(Icons.description_outlined),
                    alignLabelWithHint: true,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    counterText: '',
                  ),
                  onSubmitted: (_) {
                    if (!isLoading) _submit();
                  },
                ),
                if (createState.hasError) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(.25)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            createState.error.toString(),
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        actions: [
          TextButton.icon(
            onPressed: isLoading
                ? null
                : () => _safePop(context, false), // KHÔNG dùng maybePop
            icon: const Icon(Icons.close),
            label: const Text('Huỷ'),
          ),
          FilledButton.icon(
            onPressed: isLoading ? null : _submit,
            icon: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle_outline),
            label: const Text('Tạo'),
          ),
        ],
      ),
    );
  }
}
