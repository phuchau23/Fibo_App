import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:swp_app/features/domains/presentation/blocs/domain_providers.dart';
import 'package:swp_app/features/domains/domain/entities/domain_entity.dart';
import 'package:swp_app/features/master_topic/presentation/pages/master_topics_tab_body.dart';
import 'package:swp_app/features/topic/presentation/pages/topic_tab_body.dart';
import 'package:swp_app/shared/presentation/header.dart';

class DomainTabsPage extends StatelessWidget {
  const DomainTabsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).viewPadding.top;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: SafeArea(
          child: _AppBackground(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Scaffold(
                backgroundColor: Colors.transparent, // 👈 để lộ ảnh nền
                body: Column(
                  children: [
                    SizedBox(height: topInset),
                    OrangeBannerHeader(
                      onMenu: () => Navigator.of(context).maybePop(),
                      title: 'FPT UNIVERSITY',
                    ),
                    Expanded(
                      child: NestedScrollView(
                        headerSliverBuilder: (context, inner) => [
                          SliverAppBar(
                            pinned: true,
                            elevation: 0,
                            backgroundColor:
                                Colors.transparent, // để nhìn xuyên nền
                            toolbarHeight: 0, // 👈 ẩn hoàn toàn phần title bar
                            bottom: PreferredSize(
                              preferredSize: const Size.fromHeight(64),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  12,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: _SegmentedTabBar(
                                    tabs: const [
                                      Tab(text: 'Domain'),
                                      Tab(text: 'Master Topic'),
                                      Tab(text: 'Topic'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                        body: TabBarView(
                          physics: BouncingScrollPhysics(),
                          children: [
                            _DomainTabBody(), // Tab chính
                            MasterTopicsTabBody(),
                            TopicTabBody(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ------------------------- Segmented TabBar ------------------------- */
class _SegmentedTabBar extends StatelessWidget {
  final List<Widget> tabs;
  const _SegmentedTabBar({required this.tabs});

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest.withOpacity(.5);
    final border = Border.all(color: Colors.black12, width: 0.5);

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: border,
      ),
      child: TabBar(
        tabs: tabs,
        isScrollable: false,
        dividerColor: Colors.transparent,
        labelPadding: EdgeInsets.zero,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: border,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        labelColor: Colors.black,
        unselectedLabelColor: Theme.of(
          context,
        ).colorScheme.onSurface.withOpacity(.6),
        labelStyle: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

/* ----------------------------- DOMAIN TAB ----------------------------- */
class _DomainTabBody extends ConsumerStatefulWidget {
  const _DomainTabBody({super.key});
  @override
  ConsumerState<_DomainTabBody> createState() => _DomainTabBodyState();
}

class _DomainTabBodyState extends ConsumerState<_DomainTabBody> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();

  String? _deletingId;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(domainsNotifierProvider.notifier).fetch(page: 1, pageSize: 10);
    });
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  Future<void> _refetch() async {
    final st = ref.read(domainsNotifierProvider);
    final p = st.page?.currentPage ?? 1;
    final s = st.page?.pageSize ?? 10;
    await ref
        .read(domainsNotifierProvider.notifier)
        .fetch(page: p, pageSize: s);
  }

  /* ------- dialogs ------- */
  Future<void> openCreateDialog() async {
    nameCtrl.clear();
    descCtrl.clear();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Domain'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Name'),
              const SizedBox(height: 8),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  hintText: 'Enter name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Details'),
              const SizedBox(height: 8),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Enter details',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final desc = descCtrl.text.trim();
              if (name.isEmpty) {
                _showSnack('Name is required', true);
                return;
              }
              final err = await ref
                  .read(domainsNotifierProvider.notifier)
                  .create(name: name, description: desc);
              if (!mounted) return;
              if (err != null) {
                _showSnack(err, true);
              } else {
                await _refetch();
                Navigator.of(ctx).pop(); // auto close
                _showSnack('Created successfully');
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> openEditDialog(DomainEntity item) async {
    nameCtrl.text = item.name;
    descCtrl.text = item.description;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit: ${item.name}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Name'),
              const SizedBox(height: 8),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              const Text('Details'),
              const SizedBox(height: 8),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final desc = descCtrl.text.trim();
              if (name.isEmpty) {
                _showSnack('Name is required', true);
                return;
              }
              final err = await ref
                  .read(domainsNotifierProvider.notifier)
                  .update(id: item.id, name: name, description: desc);
              if (!mounted) return;
              if (err != null) {
                _showSnack(err, true);
              } else {
                await _refetch();
                Navigator.of(ctx).pop(); // auto close
                _showSnack('Updated successfully');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(DomainEntity item) async {
    final res = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFE9E6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    size: 28,
                    color: Color(0xFFE53935),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Delete domain?',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '“${item.name.isEmpty ? 'Untitled' : item.name}” sẽ bị xóa vĩnh viễn.',
                  textAlign: TextAlign.center,
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (res != true) return;

    // Set trạng thái đang xóa để khóa nút
    setState(() => _deletingId = item.id);

    final err = await ref
        .read(domainsNotifierProvider.notifier)
        .delete(id: item.id);

    if (!mounted) return;
    setState(() => _deletingId = null);

    if (err != null) {
      _showSnack(err, true);
    } else {
      // Notifier đã refetch/điều chỉnh trang rồi (nếu bạn áp dụng logic fallback)
      // Ở đây vẫn đảm bảo refetch nếu bạn muốn chắc chắn đồng bộ:
      await _refetch();
      _showSnack('Deleted successfully');
    }
  }

  void _showSnack(String msg, [bool isError = false]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red[700] : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(domainsNotifierProvider);

    // optional: tránh null check operator trong lúc load
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
              return _DomainCardItem(
                item: item,
                onEdit: () => openEditDialog(item),
                onDelete: () => _confirmDelete(item),
                isBusy: _deletingId == item.id,
              );
            },
          ),
        ),

        // FAB: + tạo mới (đẩy lên cao hơn chút)
        Positioned(
          right: 16,
          bottom: 100, // từ 24 -> 40
          child: FloatingActionButton(
            onPressed: openCreateDialog,
            backgroundColor: const Color.fromARGB(255, 253, 115, 23),
            foregroundColor: Colors.white,
            elevation: 2,
            child: const Icon(Icons.add, size: 28),
          ),
        ),
      ],
    );
  }
}

// Yêu cầu các import (đã dùng trong project bạn):
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:lucide_icons/lucide_icons.dart';

class _DomainCardItem extends StatelessWidget {
  final DomainEntity item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isBusy;

  const _DomainCardItem({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.isBusy,
  });

  static const double _minHeight = 84;

  @override
  Widget build(BuildContext context) {
    final r16 = BorderRadius.circular(16);

    // trạng thái dựa trên isBusy
    final Color statusDot = isBusy
        ? const Color(0xFFEA8C00)
        : const Color(0xFF28C76F);
    final String statusText = isBusy ? 'IN PROGRESS' : 'OPEN';

    Color _vibrantPastelColor(int seed) {
      final colors = [
        const Color(0xFF7DE2D1), // mint
        const Color(0xFFA78BFA), // lilac
        const Color(0xFFFCD34D), // lemon
        const Color(0xFFFB7185), // coral pink
        const Color(0xFF86EFAC), // green
        const Color(0xFF60A5FA), // blue
      ];
      final index = seed % colors.length;
      return colors[index];
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: r16,
        onTap: () => _showDomainDetailsSheet(context, item),
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
              // dải màu mảnh bên trái
              Positioned.fill(
                left: 0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 3.5,
                    decoration: BoxDecoration(
                      color: _vibrantPastelColor(
                        item.name.hashCode,
                      ), // 🌈 màu pastel đậm hơn
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              // nội dung chính
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 15), // chừa chỗ cho dải màu
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // hàng nhãn + chip trạng thái + action
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
                                  'Domains',
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
                            // chip trạng thái
                            _StatusChip(text: statusText, dotColor: statusDot),
                            const SizedBox(width: 10),
                          ],
                        ),
                        // tiêu đề chính
                        Text(
                          item.name.isEmpty ? 'Request title' : item.name,
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

                        // dòng phụ kiểu "For Donat Twerski   2m"
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                item.description.isEmpty
                                    ? 'For —'
                                    : 'For ${item.description}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.manrope(
                                  fontSize: 12.5,
                                  color: const Color(0xFF6B7280),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              '•',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFCBD5E1),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '2m', // nếu có updatedAt => thay bằng time-ago thực tế
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
}

/// Chip trạng thái (• OPEN)
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

void _showDomainDetailsSheet(BuildContext context, DomainEntity item) {
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
        initialChildSize: 0.55,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, controller) {
          final title = item.name.isEmpty ? 'Untitled' : item.name;
          final desc = (item.description ?? '').trim();
          final created = "${_fmtDt(item.createdAt)}"; // dùng formatter gọn hơn

          return ListView(
            controller: controller,
            padding: EdgeInsets.zero,
            children: [
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

              // HEADER GRADIENT
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
                    Text(
                      title,
                      style: GoogleFonts.manrope(
                        fontSize: 22,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF2B2B2B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Created • $created',
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

              // DESCRIPTION CARD
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
                        'Description',
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

              const SizedBox(height: 24),
            ],
          );
        },
      );
    },
  );
}

/// Helper datetime formatter: 24h HH:mm • dd/MM/yyyy
String _fmtDt(DateTime d) {
  final local = d.toLocal();
  final h = local.hour.toString().padLeft(2, '0');
  final m = local.minute.toString().padLeft(2, '0');
  final dd = local.day.toString().padLeft(2, '0');
  final mm = local.month.toString().padLeft(2, '0');
  final yyyy = local.year.toString();
  return '$h:$m • $dd/$mm/$yyyy';
}

class _AppBackground extends StatelessWidget {
  final Widget child;
  const _AppBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // SafeArea để KHÔNG lố vào vùng pin/giờ (status bar) và bottom inset
        Positioned.fill(
          child: SafeArea(
            top: true,
            bottom: true,
            left: false,
            right: false,
            child: ClipRect(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Ảnh nền: xoay đứng (90 độ), phủ kín SafeArea
                  // Dùng FittedBox + RotatedBox để đảm bảo cover mà không vỡ
                  FittedBox(
                    fit: BoxFit.cover,
                    child: RotatedBox(
                      quarterTurns: 1, // 👈 xoay 90 độ theo chiều kim đồng hồ
                      child: Image.asset('assets/images/bg_header_2.jpg'),
                    ),
                  ),

                  // Lớp gradient mờ dần: trên & dưới mờ, giữa rõ
                  IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 10), // mờ trên
                            Colors.white.withValues(alpha: 0.70), // giữa rõ
                            Colors.white.withValues(alpha: 0.70), // giữa rõ
                            Colors.white.withValues(alpha: 10), // mờ dưới
                          ],
                          stops: const [0.0, 0.35, 0.65, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Nội dung trang
        child,
      ],
    );
  }
}
