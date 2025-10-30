import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swp_app/features/groups/domain/entities/group_entity.dart';
import 'package:swp_app/features/groups/domain/entities/group_member_entity.dart';
import 'package:swp_app/features/groups/groups_module.dart';
import 'package:swp_app/features/class/presentation/blocs/student_provider.dart';
import 'package:swp_app/features/groups/presentation/blocs/group_providers.dart';

/// Palette cam–trắng đồng bộ
class _OP {
  static const creamBg = Color(0xFFFFF8F2);
  static const orange600 = Color(0xFFFF8C42);
  static const orange500 = Color(0xFFFF9F55);
  static const orange300 = Color(0xFFFFC78E);
  static const orange150 = Color(0xFFFFE4C1);
  static const orange100 = Color(0xFFFFE7CF);
  static const brown900 = Color(0xFF732C00);
  static const brown800 = Color(0xFF9B4A00);
}

class GroupDetailPage extends ConsumerWidget {
  final String classId;
  final GroupEntity group;
  const GroupDetailPage({
    super.key,
    required this.classId,
    required this.group,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final membersAsync = ref.watch(groupMembersProvider(group.id));
    final addState = ref.watch(addMembersControllerProvider);
    final removeState = ref.watch(removeMemberControllerProvider);

    // Listen add
    ref.listen(addMembersControllerProvider, (prev, next) async {
      if (next.hasError) {
        _safeSnack(context, 'Lỗi thêm thành viên: ${next.error}');
      } else if (prev?.isLoading == true && next.hasValue) {
        // Chờ dữ liệu mới xong hẳn
        await Future.wait([
          ref.refresh(groupMembersProvider(group.id).future),
          ref.refresh(groupsByClassProvider(classId).future),
          ref.refresh(studentsWithoutGroupProvider(classId).future),
        ]);
        _safeSnack(context, 'Đã thêm thành viên');
      }
    });

    // Listen remove
    ref.listen(removeMemberControllerProvider, (prev, next) async {
      if (next.hasError) {
        _safeSnack(context, 'Lỗi xoá thành viên: ${next.error}');
      } else if (prev?.isLoading == true && next.hasValue) {
        // Chờ dữ liệu mới xong hẳn
        await Future.wait([
          ref.refresh(groupMembersProvider(group.id).future),
          ref.refresh(groupsByClassProvider(classId).future),
          ref.refresh(studentsWithoutGroupProvider(classId).future),
        ]);
        _safeSnack(context, 'Đã xoá thành viên');
      }
    });

    final busy = addState.isLoading || removeState.isLoading;

    return Scaffold(
      backgroundColor: _OP.creamBg,
      appBar: AppBar(
        backgroundColor: _OP.creamBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          group.name,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleLarge?.copyWith(
            color: _OP.brown800,
            fontWeight: FontWeight.w900,
            letterSpacing: .2,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: membersAsync.maybeWhen(
              data: (m) => _MembersCountChip(count: m.length),
              orElse: () => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
      body: membersAsync.when(
        loading: () => const _CenteredLoader(),
        error: (e, _) => _PrettyState(
          icon: Icons.error_outline,
          title: 'Không tải được thành viên',
          subtitle: e.toString(),
          action: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _OP.orange600),
            onPressed: () => ref.invalidate(groupMembersProvider(group.id)),
            child: const Text('Thử lại'),
          ),
        ),
        data: (members) {
          return RefreshIndicator(
            color: _OP.orange600,
            onRefresh: () async =>
                ref.invalidate(groupMembersProvider(group.id)),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: _HeaderCard(
                      name: group.name,
                      description: group.description,
                      createdAt: group.createdAt,
                      onAdd: () => _openAddMembersSheet(
                        context,
                        ref,
                        classId,
                        group.id,
                        members,
                      ),
                      busy: busy,
                    ),
                  ),
                ),
                if (members.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _PrettyState(
                      icon: Icons.people_outline,
                      title: 'Chưa có thành viên',
                      subtitle: 'Hãy thêm sinh viên vào nhóm để bắt đầu.',
                      action: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: _OP.orange600,
                        ),
                        onPressed: busy
                            ? null
                            : () => _openAddMembersSheet(
                                context,
                                ref,
                                classId,
                                group.id,
                                members,
                              ),
                        icon: const Icon(Icons.person_add, color: Colors.white),
                        label: const Text(
                          'Thêm thành viên',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList.separated(
                      itemCount: members.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (ctx, i) {
                        final m = members[i];
                        final fullName = '${m.firstName} ${m.lastName}'.trim();
                        final display = fullName.isEmpty ? m.email : fullName;
                        final subtitle = m.email;

                        return _MemberCard(
                          title: display,
                          subtitle: subtitle,
                          onRemove: busy
                              ? null
                              : () async {
                                  final ok = await _confirm(
                                    context,
                                    'Xoá ${display ?? 'thành viên'} khỏi nhóm?',
                                  );
                                  if (ok != true) return;
                                  await ref
                                      .read(
                                        removeMemberControllerProvider.notifier,
                                      )
                                      .submit(
                                        groupId: group.id,
                                        userId: m.userId,
                                      );
                                },
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: membersAsync.maybeWhen(
        data: (members) => FloatingActionButton.extended(
          backgroundColor: _OP.orange600,
          onPressed: busy
              ? null
              : () => _openAddMembersSheet(
                  context,
                  ref,
                  classId,
                  group.id,
                  members, // <-- dùng members trong scope hiện tại
                ),
          icon: const Icon(Icons.person_add_rounded, color: Colors.white),
          label: const Text('Thêm', style: TextStyle(color: Colors.white)),
        ),
        orElse: () => null,
      ),
    );
  }

  Future<void> _openAddMembersSheet(
    BuildContext context,
    WidgetRef ref,
    String classId,
    String groupId,
    List<GroupMemberEntity> currentMembers,
  ) async {
    // 1) Luôn fetch MỚI danh sách SV chưa thuộc nhóm mỗi lần mở sheet
    try {
      await ref.refresh(studentsWithoutGroupProvider(classId).future);
    } catch (_) {}

    // 2) Lấy state hiện tại (đã mới)
    final async = ref.read(studentsWithoutGroupProvider(classId));
    final String? errorText = async.hasError ? async.error.toString() : null;
    final roster = async.value ?? const <dynamic>[]; // List<StudentEntity>

    // 3) Bỏ những SV đã là thành viên group hiện tại
    final currentIds = currentMembers.map((e) => e.userId).toSet();

    final List<_Candidate> base =
        roster.where((s) => !currentIds.contains(s.id)).map((s) {
          final full = ('${s.firstName} ${s.lastName}').trim();
          return _Candidate(
            id: s.id,
            title: full.isNotEmpty ? full : s.email,
            subtitle: s.email,
          );
        }).toList()..sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        final selected = <String>{};
        final controller = TextEditingController();
        List<_Candidate> filtered = List.of(base);

        void applyFilter(String q) {
          final qq = q.trim().toLowerCase();
          filtered = qq.isEmpty
              ? List.of(base)
              : base
                    .where(
                      (c) =>
                          c.title.toLowerCase().contains(qq) ||
                          c.subtitle.toLowerCase().contains(qq),
                    )
                    .toList();
        }

        applyFilter('');

        return StatefulBuilder(
          builder: (ctx, setState) {
            void onSearchChanged(String v) => setState(() => applyFilter(v));
            final hasError = errorText != null && errorText.isNotEmpty;

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: 12 + MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: _OP.orange100,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Thêm thành viên',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: _OP.brown800,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Tìm kiếm
                  TextField(
                    controller: controller,
                    onChanged: onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Tìm theo tên hoặc email...',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: _OP.brown800,
                      ),
                      isDense: true,
                      filled: true,
                      fillColor: _OP.orange100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _OP.orange150),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _OP.orange150),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: _OP.orange500,
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Toolbar
                  Row(
                    children: [
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: _OP.brown800,
                        ),
                        onPressed: filtered.isEmpty
                            ? null
                            : () {
                                setState(() {
                                  for (final c in filtered) selected.add(c.id);
                                });
                              },
                        icon: const Icon(Icons.done_all_rounded),
                        label: const Text('Chọn tất cả'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: _OP.brown800,
                        ),
                        onPressed: selected.isEmpty
                            ? null
                            : () => setState(selected.clear),
                        child: const Text('Bỏ chọn'),
                      ),
                      const Spacer(),
                      if (selected.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _OP.orange100,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${selected.length} đã chọn',
                            style: Theme.of(ctx).textTheme.labelMedium
                                ?.copyWith(
                                  color: _OP.brown800,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  if (hasError)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: _PrettyState(
                        compact: true,
                        icon: Icons.error_outline,
                        title: 'Không tải được danh sách sinh viên',
                        subtitle: errorText!,
                      ),
                    )
                  else if (base.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: _PrettyState(
                        compact: true,
                        icon: Icons.people_outline,
                        title: 'Không còn sinh viên để thêm',
                        subtitle:
                            'Tất cả sinh viên trong lớp đã là thành viên nhóm này.',
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 6),
                        itemBuilder: (_, i) {
                          final c = filtered[i];
                          final checked = selected.contains(c.id);
                          final letter =
                              (c.title.isNotEmpty
                                      ? c.title[0]
                                      : (c.subtitle.isNotEmpty
                                            ? c.subtitle[0]
                                            : '?'))
                                  .toUpperCase();

                          return InkWell(
                            onTap: () {
                              setState(() {
                                checked
                                    ? selected.remove(c.id)
                                    : selected.add(c.id);
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _OP.orange150),
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: checked,
                                    onChanged: (v) {
                                      setState(() {
                                        v == true
                                            ? selected.add(c.id)
                                            : selected.remove(c.id);
                                      });
                                    },
                                    activeColor: _OP.orange600,
                                  ),
                                  const SizedBox(width: 6),
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: _OP.orange100,
                                    child: Text(
                                      letter,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: _OP.brown900,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(ctx)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                                color: _OP.brown900,
                                              ),
                                        ),
                                        Text(
                                          c.subtitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(ctx)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: _OP.brown800.withOpacity(
                                                  .8,
                                                ),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: _OP.orange150),
                            foregroundColor: _OP.brown800,
                            backgroundColor: Colors.white,
                          ),
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Huỷ'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: _OP.orange600,
                          ),
                          icon: const Icon(
                            Icons.person_add,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Thêm',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: (selected.isEmpty || base.isEmpty)
                              ? null
                              : () async {
                                  // 1) Gửi submit
                                  await ref
                                      .read(
                                        addMembersControllerProvider.notifier,
                                      )
                                      .submit(
                                        groupId: groupId,
                                        userIds: selected.toList(),
                                      );
                                  final s = ref.read(
                                    addMembersControllerProvider,
                                  );
                                  if (s.hasError) return;

                                  // 2) Đồng bộ lại dữ liệu và CHỜ xong
                                  await Future.wait([
                                    ref.refresh(
                                      groupMembersProvider(groupId).future,
                                    ),
                                    ref.refresh(
                                      groupsByClassProvider(classId).future,
                                    ),
                                    ref.refresh(
                                      studentsWithoutGroupProvider(
                                        classId,
                                      ).future,
                                    ),
                                  ]);

                                  // 3) Đóng sheet
                                  if (ctx.mounted) Navigator.of(ctx).pop();
                                },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// ---- UI PARTIALS ----

class _MembersCountChip extends StatelessWidget {
  const _MembersCountChip({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 231, 207),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _OP.orange150),
      ),
      child: Row(
        children: [
          const Icon(Icons.people_alt_rounded, size: 16, color: _OP.brown800),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: const TextStyle(
              color: _OP.brown800,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.name,
    required this.description,
    required this.createdAt,
    required this.onAdd,
    required this.busy,
  });

  final String name;
  final String? description;
  final DateTime createdAt;
  final VoidCallback onAdd;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [_OP.orange300, _OP.orange150],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: _OP.orange150),
        boxShadow: [
          BoxShadow(
            color: _OP.orange500.withOpacity(.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: _OP.brown900,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .2,
                  ),
                ),
                if ((description?.isNotEmpty ?? false)) ...[
                  const SizedBox(height: 6),
                  Text(
                    description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _OP.brown800.withOpacity(.9),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: _OP.brown800,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tạo: ${_fmt(createdAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _OP.brown800.withOpacity(.75),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: _OP.orange600),
            onPressed: busy ? null : onAdd,
            icon: busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.person_add, color: Colors.white),
            label: const Text('Thêm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    final mon = d.month.toString().padLeft(2, '0');
    final y = d.year.toString();
    return '$h:$m - $day/$mon/$y';
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({
    required this.title,
    required this.subtitle,
    required this.onRemove,
  });

  final String? title;
  final String? subtitle;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final display = title ?? '';
    final leadingLetter =
        (display.isNotEmpty
                ? display[0]
                : (subtitle?.isNotEmpty == true ? subtitle![0] : '?'))
            .toUpperCase();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _OP.orange150),
            boxShadow: [
              BoxShadow(
                color: _OP.orange500.withOpacity(.10),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 6),
            leading: CircleAvatar(
              backgroundColor: _OP.orange100,
              child: Text(
                leadingLetter,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: _OP.brown900,
                ),
              ),
            ),
            title: Text(
              display,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: .2,
                color: _OP.brown900,
              ),
            ),
            subtitle: subtitle == null
                ? null
                : Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _OP.brown800.withOpacity(.85),
                    ),
                  ),
            trailing: IconButton.filledTonal(
              style: IconButton.styleFrom(backgroundColor: _OP.orange100),
              tooltip: 'Xoá khỏi nhóm',
              icon: const Icon(Icons.person_remove, color: _OP.brown800),
              onPressed: onRemove,
            ),
          ),
        ),
      ),
    );
  }
}

class _PrettyState extends StatelessWidget {
  const _PrettyState({
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final pad = compact ? 8.0 : 20.0;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: compact ? 32 : 48,
              color: _OP.brown800.withOpacity(.6),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _OP.brown800,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _OP.brown800, fontSize: 13),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 12), action!],
          ],
        ),
      ),
    );
  }
}

class _CenteredLoader extends StatelessWidget {
  const _CenteredLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(color: _OP.orange600),
      ),
    );
  }
}

Future<bool?> _confirm(BuildContext context, String message) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Xác nhận'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Huỷ'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: _OP.orange600),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Đồng ý', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

void _safeSnack(BuildContext ctx, String message) {
  final messenger = ScaffoldMessenger.maybeOf(ctx);
  if (messenger != null) {
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
    return;
  }
  final rootNav = Navigator.maybeOf(ctx, rootNavigator: true);
  final rootCtx = rootNav?.context;
  final rootMessenger = rootCtx != null
      ? ScaffoldMessenger.maybeOf(rootCtx)
      : null;
  rootMessenger
    ?..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(message)));
}

class _Candidate {
  final String id;
  final String title;
  final String subtitle;
  _Candidate({required this.id, required this.title, required this.subtitle});
}
