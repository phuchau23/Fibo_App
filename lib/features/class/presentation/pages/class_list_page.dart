import 'dart:async';
import 'package:animations/animations.dart'; // 👈 thêm
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swp_app/features/class/presentation/blocs/class_providers.dart';
import 'package:swp_app/features/class/presentation/pages/class_detail_page.dart';
// bỏ import này để tránh nhầm widget khác:
// import 'package:swp_app/features/class/presentation/widgets/class_list_item.dart';
import 'package:swp_app/features/class/presentation/widgets/search_widgets.dart';
import 'package:swp_app/shared/presentation/header.dart';

class ClassListPage extends ConsumerStatefulWidget {
  const ClassListPage({super.key});

  @override
  ConsumerState<ClassListPage> createState() => _ClassListPageState();
}

class _ClassListPageState extends ConsumerState<ClassListPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  Timer? _debouncer;

  // PALETTE (giữ lại nếu cần dùng nơi khác)
  static const orangeA = Color(0xFFFF8A00);
  static const orangeB = Color(0xFFFFA73D);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(lecturerClassesNotifierProvider.notifier)
          .fetch(page: 1, pageSize: 10);
    });

    _searchCtrl.addListener(() {
      _debouncer?.cancel();
      _debouncer = Timer(const Duration(milliseconds: 200), () {
        setState(() => _query = _searchCtrl.text.trim());
      });
    });
  }

  @override
  void dispose() {
    _debouncer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Status bar trong suốt để thấy ảnh nền + icon tối
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    final topInset = MediaQuery.of(context).viewPadding.top;

    final state = ref.watch(lecturerClassesNotifierProvider);
    final items = state.page?.items ?? [];

    final filtered = _query.isEmpty
        ? items
        : items.where((e) {
            final q = _query.toLowerCase();
            return e.code.toLowerCase().contains(q) ||
                e.status.toLowerCase().contains(q) ||
                e.semesterCode.toLowerCase().contains(q) ||
                e.semesterTerm.toLowerCase().contains(q);
          }).toList();

    final page = state.page;
    final pageSize = page?.pageSize ?? 10;
    final showPagination = (page?.totalItems ?? 0) >= pageSize;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      // 👇 Bọc toàn bộ trang bằng nền ảnh mờ
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
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: ListView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      children: [
                        CouponSearchBar(
                          controller: _searchCtrl,
                          hint: 'What are you looking for?',
                          onClaim: () {},
                        ),
                        const SizedBox(height: 12),

                        if (state.isLoading)
                          const LinearProgressIndicator(minHeight: 2),
                        if (state.error != null) ...[
                          const SizedBox(height: 8),
                          _ErrorBanner(message: state.error!),
                        ],

                        const SizedBox(height: 8),

                        // ✅ Map ra tile có OpenContainer transform
                        ...filtered.map(
                          (item) => _ClassCouponTile(
                            classId: item.id, // 👈 thêm
                            code: item.code,
                            status: item.status,
                            createdAt: item.createdAt,
                            semesterCode: item.semesterCode,
                            term: item.semesterTerm,
                            year: item.year,
                          ),
                        ),

                        if (page != null) ...[
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              'Trang ${page.currentPage}/${page.totalPages} · Tổng: ${page.totalItems}',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: Theme.of(context).hintColor,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],

                        if (page != null && showPagination)
                          _PaginationBar(
                            current: page.currentPage,
                            totalPages: page.totalPages,
                            onPrev: page.currentPage > 1
                                ? () => ref
                                      .read(
                                        lecturerClassesNotifierProvider
                                            .notifier,
                                      )
                                      .fetch(
                                        page: page.currentPage - 1,
                                        pageSize: page.pageSize,
                                      )
                                : null,
                            onNext: page.hasNextPage
                                ? () => ref
                                      .read(
                                        lecturerClassesNotifierProvider
                                            .notifier,
                                      )
                                      .fetch(
                                        page: page.currentPage + 1,
                                        pageSize: page.pageSize,
                                      )
                                : null,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ================= NỀN ẢNH TOÀN TRANG (xoay dọc + mờ trên/dưới) =================
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

/// ================= ITEM (OpenContainer) =================
class _ClassCouponTile extends StatelessWidget {
  final String classId;
  final String code;
  final String status;
  final DateTime createdAt;
  final String semesterCode;
  final String term;
  final int year;

  const _ClassCouponTile({
    required this.classId,
    required this.code,
    required this.status,
    required this.createdAt,
    required this.semesterCode,
    required this.term,
    required this.year,
  });

  String _formatTime(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$h:$m - $dd/$mm/$yyyy';
  }

  // Badge màu theo status
  (Color bg, Color fg, String label) _badge(String s) {
    final t = s.toLowerCase();
    if (t.contains('active') || t.contains('open')) {
      return (
        const Color(0xFFE8F7EE),
        const Color.fromARGB(255, 12, 186, 88),
        'Active',
      );
    }
    if (t.contains('pending') || t.contains('review')) {
      return (const Color(0xFFFFF4E5), const Color(0xFFB96A00), 'Pending');
    }
    if (t.contains('closed') || t.contains('end') || t.contains('inactive')) {
      return (const Color(0xFFFFEEEE), const Color(0xFFD22D2D), 'Closed');
    }
    return (const Color(0xFFEFF3FF), const Color(0xFF2F6FED), s);
  }

  @override
  Widget build(BuildContext context) {
    final subtle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Colors.black.withOpacity(.45),
      fontWeight: FontWeight.w600,
      letterSpacing: .2,
      fontSize: 11, // nhãn nhỏ như ảnh
    );

    final (bg, fg, label) = _badge(status);

    return OpenContainer(
      transitionDuration: const Duration(milliseconds: 420),
      openBuilder: (context, _) => ClassStudentsPage(classId: classId),
      closedElevation: 0,
      openElevation: 0,
      closedColor: Colors.transparent,
      openColor: Theme.of(context).scaffoldBackgroundColor,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      tappable: false,
      closedBuilder: (context, open) {
        return InkWell(
          onTap: open,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12), // card gọn
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF0F0F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== Header: Title + Status Badge
                  Row(
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              WidgetSpan(
                                alignment: PlaceholderAlignment.aboveBaseline,
                                baseline: TextBaseline.alphabetic,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    right: 4,
                                    bottom: 2,
                                  ),
                                  child: Text(
                                    'Group Class :  ',
                                    style: TextStyle(
                                      fontSize: 13, // nhỏ hơn
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                      letterSpacing: .3,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ),
                              const WidgetSpan(child: SizedBox(width: 18)),
                              TextSpan(
                                text: code,
                                style: const TextStyle(
                                  fontSize: 25, // chữ code to, cùng hàng badge
                                  fontWeight: FontWeight.w900,
                                  color: Color.fromARGB(255, 255, 69, 1),
                                  letterSpacing: .2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: fg.withOpacity(.18)),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            color: fg,
                            fontWeight: FontWeight.w900,
                            fontSize: 11, // cỡ badge nhỏ
                            letterSpacing: .2,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ===== Divider mảnh
                  const Divider(
                    height: 2,
                    thickness: .7,
                    color: Color.fromARGB(58, 90, 86, 86),
                  ),

                  const SizedBox(height: 10),

                  // ===== 2 cột: nhãn mờ + giá trị đậm
                  Row(
                    children: [
                      // Cột trái — giống "Classes Type"
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Semester', style: subtle),
                            const SizedBox(height: 6),
                            Text(
                              semesterCode, // giá trị đậm
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14, // value đậm vừa phải
                                fontWeight: FontWeight.w800,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Cột phải — giống "Time"
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Time', style: subtle),
                            const SizedBox(height: 6),
                            Text(
                              // Nếu sau này có start/end thì map "09:30 - 10:00 am"
                              _formatTime(createdAt),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.black45,
                              ),
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
        );
      },
    );
  }
}

class _StatusStyle {
  final String label;
  final Color fg;
  final Color bg;
  const _StatusStyle(this.label, this.fg, this.bg);
}

/// ================= PAGINATION + ERROR =================
class _PaginationBar extends StatelessWidget {
  final int current;
  final int totalPages;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _PaginationBar({
    required this.current,
    required this.totalPages,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _circleButton(
          icon: Icons.chevron_left,
          enabled: onPrev != null,
          onTap: onPrev,
        ),
        const SizedBox(width: 6),
        ...List.generate(totalPages, (i) {
          final page = i + 1;
          final selected = page == current;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFE55B5B) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE9E9E9)),
              ),
              child: Text(
                '$page',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          );
        }),
        const SizedBox(width: 6),
        _circleButton(
          icon: Icons.chevron_right,
          enabled: onNext != null,
          onTap: onNext,
        ),
      ],
    );
  }

  Widget _circleButton({
    required IconData icon,
    required bool enabled,
    VoidCallback? onTap,
  }) {
    return Opacity(
      opacity: enabled ? 1 : .35,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE9E9E9)),
          ),
          child: Icon(icon, size: 20),
        ),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade700, height: 1.25),
            ),
          ),
        ],
      ),
    );
  }
}
