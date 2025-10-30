import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swp_app/features/class/presentation/blocs/student_provider.dart';
import 'package:swp_app/features/groups/presentation/pages/groups_page.dart';

final studentSearchQueryProvider = StateProvider<String>((ref) => '');

/// Bảng màu cam-trắng đồng bộ
class _OP {
  static const creamBg = Color(0xFFFFF8F2);
  static const orange600 = Color(0xFFFF8C42);
  static const orange500 = Color(0xFFFF9F55);
  static const orange300 = Color(0xFFFFC78E);
  static const orange100 = Color(0xFFFFE7CF);
  static const brown900 = Color(0xFF732C00);
  static const brown800 = Color(0xFF9B4A00);
  static const hint = Color(0xFF9B4A00);
}

class ClassStudentsPage extends ConsumerStatefulWidget {
  final String classId;
  const ClassStudentsPage({super.key, required this.classId});

  @override
  ConsumerState<ClassStudentsPage> createState() => _ClassStudentsPageState();
}

class _ClassStudentsPageState extends ConsumerState<ClassStudentsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final n = ref.read(
        classStudentsNotifierProvider(widget.classId).notifier,
      );
      n.reset();
      n.fetch();
    });
  }

  @override
  void didUpdateWidget(covariant ClassStudentsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.classId != widget.classId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final n = ref.read(
          classStudentsNotifierProvider(widget.classId).notifier,
        );
        n.reset();
        n.fetch();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(classStudentsNotifierProvider(widget.classId));
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _OP.creamBg,
        appBar: AppBar(
          backgroundColor: _OP.creamBg,
          elevation: 0,
          centerTitle: true,
          titleSpacing: 0,
          toolbarHeight: 60,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: _OP.brown800),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Lớp học',
            style: theme.textTheme.titleLarge?.copyWith(
              color: _OP.brown800,
              fontWeight: FontWeight.w800,
              letterSpacing: .3,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: _OP.brown800),
              onPressed: () {},
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(68),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 380),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: _OP.orange100),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                        color: _OP.orange500.withOpacity(.15),
                      ),
                    ],
                  ),
                  child: TabBar(
                    dividerColor: Colors.transparent,
                    labelPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 6,
                    ),
                    labelStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    isScrollable: false,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(
                        colors: [_OP.orange600, _OP.orange500],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: _OP.brown800.withOpacity(.85),
                    tabs: const [
                      Tab(text: 'Tất Cả'),
                      Tab(text: 'Nhóm'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: _buildBody(context, ref, state),
            ),
            GroupsPage(classId: widget.classId), // đã cam-trắng ở màn Groups
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, dynamic state) {
    if (state.loading == true) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error is String && (state.error as String).isNotEmpty) {
      return Center(
        child: Text(
          state.error as String,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (state.data != null) {
      return _ClassStudentsBody(
        data: state.data,
        onReload: () => ref
            .read(classStudentsNotifierProvider(widget.classId).notifier)
            .fetch(),
      );
    }
    return const SizedBox.shrink();
  }
}

class _ClassStudentsBody extends ConsumerWidget {
  final dynamic data; // ClassWithStudentsEntity
  final VoidCallback onReload;
  const _ClassStudentsBody({required this.data, required this.onReload});

  String _initials(String firstName, String lastName) {
    final a = firstName.trim().isNotEmpty ? firstName.trim()[0] : '';
    final b = lastName.trim().isNotEmpty ? lastName.trim()[0] : '';
    final text = (a + b).toUpperCase();
    return text.isEmpty ? '?' : text;
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF23A559);
      case 'inactive':
      case 'banned':
        return const Color(0xFFE53935);
      default:
        return _OP.orange600;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final query = ref.watch(studentSearchQueryProvider);

    final allStudents = ((data.students ?? const <dynamic>[]) as List)
        .whereType<dynamic>()
        .toList();

    if (allStudents.isEmpty) {
      return _EmptyRoster(
        title: 'Lớp chưa có sinh viên',
        message:
            'Bạn có thể nhập danh sách từ hệ thống hoặc mời sinh viên tham gia.',
        onReload: onReload,
      );
    }

    final students = allStudents.where((s) {
      final first = (s.firstName ?? '').toString();
      final last = (s.lastName ?? '').toString();
      final full = ('$first $last').toLowerCase();
      final q = query.toLowerCase().trim();
      if (q.isEmpty) return true;
      return full.contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar – đồng bộ cam-trắng
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _OP.orange100),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                offset: const Offset(0, 6),
                color: _OP.orange500.withOpacity(.12),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              const Icon(Icons.search_rounded, size: 20, color: _OP.brown800),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  onChanged: (v) =>
                      ref.read(studentSearchQueryProvider.notifier).state = v,
                  decoration: const InputDecoration(
                    hintText: 'Tìm theo tên sinh viên…',
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: _OP.brown900),
                ),
              ),
              if (query.isNotEmpty)
                IconButton(
                  tooltip: 'Xoá',
                  icon: const Icon(Icons.close, size: 18, color: _OP.brown800),
                  onPressed: () =>
                      ref.read(studentSearchQueryProvider.notifier).state = '',
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            'Sinh viên (${students.length})',
            style: theme.textTheme.titleLarge?.copyWith(
              color: _OP.brown800,
              fontWeight: FontWeight.w800,
              letterSpacing: .2,
            ),
          ),
        ),

        if (students.isEmpty)
          Expanded(
            child: _EmptyResult(
              query: query,
              onClear: () =>
                  ref.read(studentSearchQueryProvider.notifier).state = '',
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: students.length,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemBuilder: (context, index) {
                final s = students[index];
                final first = (s.firstName ?? '').toString();
                final last = (s.lastName ?? '').toString();
                final email = (s.email ?? '').toString();
                final mssv = (s.studentId ?? '').toString();
                final status = (s.status ?? '').toString();

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: _StudentRowCard(
                    avatarText: _initials(first, last),
                    title: '$first $last',
                    subline: 'MSSV :   $mssv',
                    metricLeftLabel: 'Email :',
                    metricLeftValue: email,
                    statusText: status.isEmpty ? 'Active' : status,
                    statusColor: _statusColor(status),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _EmptyRoster extends StatelessWidget {
  const _EmptyRoster({
    required this.title,
    required this.message,
    required this.onReload,
  });
  final String title;
  final String message;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _OP.orange100),
          boxShadow: [
            BoxShadow(
              blurRadius: 14,
              offset: const Offset(0, 6),
              color: _OP.orange500.withOpacity(.12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.group_off, size: 56, color: _OP.brown800),
            const SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: _OP.brown800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _OP.brown800.withOpacity(.7),
                height: 1.35,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: _OP.orange600),
              onPressed: onReload,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Tải lại',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyResult extends StatelessWidget {
  const _EmptyResult({required this.query, required this.onClear});
  final String query;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, size: 52, color: _OP.brown800),
          const SizedBox(height: 8),
          Text(
            'Không có kết quả',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: _OP.brown800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Không tìm thấy sinh viên cho “$query”.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _OP.brown800.withOpacity(.75),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.clear, color: _OP.brown800),
            label: const Text(
              'Xoá bộ lọc',
              style: TextStyle(color: _OP.brown800),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _OP.orange100),
              backgroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentRowCard extends StatelessWidget {
  const _StudentRowCard({
    required this.avatarText,
    required this.title,
    required this.subline,
    required this.metricLeftLabel,
    required this.metricLeftValue,
    required this.statusText,
    required this.statusColor,
  });

  final String avatarText;
  final String title;
  final String subline;
  final String metricLeftLabel;
  final String metricLeftValue;
  final String statusText;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _OP.orange100),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 6),
            color: _OP.orange500.withOpacity(.12),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: _OP.orange100,
            child: Text(
              avatarText,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: _OP.brown900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // tên + badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: _OP.brown900,
                              letterSpacing: .2,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusPill(text: statusText, color: statusColor),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _OP.brown800.withOpacity(.75),
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '$metricLeftLabel ',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _OP.brown800.withOpacity(.7),
                      ),
                    ),
                    Text(
                      metricLeftValue,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: _OP.brown900),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final on = color.computeLuminance() > .5 ? Colors.black : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(color: on, shape: BoxShape.circle),
          ),
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: on,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
