import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Provider profile của bạn
import 'package:swp_app/features/profile/presentation/blocs/profile_providers.dart';

// ===== Theme =====
const _navy = Color.fromARGB(255, 255, 231, 207);
const _navySoft = Color(0xFF20314D);
const _orange = Color(0xFFFF8C42);
const _pillGrey = Color(0xFFF2F3F6);

// rail trái và card phải cao bằng nhau
const double kCardHeight = 110.0;
const double _kRailSep = 10.0;

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // ngày đang chọn
  final ValueNotifier<DateTime> _selectedDate = ValueNotifier<DateTime>(
    _truncate(DateTime.now()),
  );
  // danh sách ngày hiển thị
  late List<DateTime> _dates;
  late final ScrollController _railCtrl;

  late final Timer _minuteTicker;

  @override
  void initState() {
    super.initState();
    _dates = _seedFutureOnly(); // chỉ Today → tương lai
    _railCtrl = ScrollController();

    _minuteTicker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {}); // cập nhật badge Today
    });
  }

  @override
  void dispose() {
    _minuteTicker.cancel();
    _selectedDate.dispose();
    _railCtrl.dispose();
    super.dispose();
  }

  // Chỉ Today → +30 ngày (ẩn quá khứ lúc đầu)
  static List<DateTime> _seedFutureOnly() {
    final base = _truncate(DateTime.now());
    return List.generate(31, (i) => base.add(Duration(days: i))); // 0..30
  }

  // Thêm quá khứ khi overscroll trên cùng
  void _prependPastDays(int days) {
    final start = _dates.first; // đang là ngày sớm nhất (>= today)
    final ext = List.generate(
      days,
      (i) => start.subtract(Duration(days: i + 1)),
    ).reversed.toList();
    setState(() => _dates.insertAll(0, ext));

    // giữ nguyên vị trí hiển thị sau khi chèn trên (dời sang frame sau)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_railCtrl.hasClients) return;
      final itemExtent = kCardHeight + _kRailSep;
      _railCtrl.jumpTo(_railCtrl.offset + itemExtent * days);
    });
  }

  // Thêm tương lai khi gần cuối
  void _appendFutureDays(int days) {
    final end = _dates.last;
    final ext = List.generate(days, (i) => end.add(Duration(days: i + 1)));
    setState(() => _dates.addAll(ext));
  }

  void _goToToday() async {
    final today = _truncate(DateTime.now());
    final idx = _dates.indexWhere((d) => d == today);
    if (idx < 0) return; // safety

    // chọn Today (dời sang frame sau để tránh "dirty in wrong scope")
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectedDate.value = today;
    });

    // cuộn rail về Today (sau frame)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_railCtrl.hasClients) return;
      final itemExtent = kCardHeight + _kRailSep;
      HapticFeedback.lightImpact();
      await _railCtrl.animateTo(
        idx * itemExtent,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
  }

  static DateTime _truncate(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    final prof = ref.watch(profileNotifierProvider);

    final name = prof.when(
      data: (u) {
        final first = u.firstname ?? '';
        final last = u.lastname ?? '';
        final full = [first, last].where((e) => e.isNotEmpty).join(' ');
        return full.isEmpty ? 'User' : full;
      },
      loading: () => '…',
      error: (_, __) => 'User',
    );
    final avatarUrl = prof.when(
      data: (u) => u.avatarUrl,
      loading: () => null,
      error: (_, __) => null,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _navy,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              // ===== 1) HELLO =====
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color.fromARGB(87, 255, 167, 84),
                      backgroundImage:
                          (avatarUrl != null && avatarUrl.isNotEmpty)
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: (avatarUrl == null || avatarUrl.isEmpty)
                          ? const Icon(
                              Icons.person,
                              color: Color.fromARGB(255, 255, 102, 0),
                              size: 18,
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Hello!',
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 102, 0),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 2),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 255, 102, 0),
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // ===== 2) TITLE + SEGMENTED (cùng một hàng) =====
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 0, 20),
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 39,
                              height: 1.1,
                            ),
                            children: [
                              TextSpan(
                                text: 'Kiểm tra các báo cáo về AI ',
                                style: TextStyle(color: Colors.white),
                              ),
                              TextSpan(
                                text: 'dành cho bạn',
                                style: TextStyle(color: Color(0xFFFF8C42)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ===== 3) RAIL & LIST bắt đầu cùng hàng =====
              Expanded(
                child: Stack(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DateRail(
                          controller: _railCtrl,
                          dates: _dates,
                          selectedDateListenable: _selectedDate,
                          onSelect: (d) {
                            // đảm bảo không set trong layout
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _selectedDate.value = d;
                            });
                          },
                          onNeedMorePast: () => _prependPastDays(30),
                          onNeedMoreFuture: () => _appendFutureDays(30),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SchedulePanel(
                            selectedDateListenable: _selectedDate,
                          ),
                        ),
                      ],
                    ),

                    // ===== Nút Today nổi: chỉ hiện khi selected ≠ Today =====
                    Positioned(
                      top: 0,
                      left: 8, // sát rail trái
                      child: ValueListenableBuilder<DateTime>(
                        valueListenable: _selectedDate,
                        builder: (context, selected, _) {
                          final isToday = selected == _truncate(DateTime.now());
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: isToday
                                ? const SizedBox.shrink()
                                : Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(999),
                                      onTap: _goToToday,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _orange,
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color(0x33000000),
                                              blurRadius: 12,
                                              offset: Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(
                                              Icons.arrow_back_ios_new_rounded,
                                              size: 14,
                                              color: Colors.black,
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              'Today',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 12.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= LEFT DATE RAIL (NO AUTO-SELECT) =================
class _DateRail extends StatefulWidget {
  const _DateRail({
    required this.controller,
    required this.dates,
    required this.selectedDateListenable,
    required this.onSelect,
    required this.onNeedMorePast,
    required this.onNeedMoreFuture,
  });

  final ScrollController controller;
  final List<DateTime> dates;
  final ValueListenable<DateTime> selectedDateListenable;
  final ValueChanged<DateTime> onSelect;
  final VoidCallback onNeedMorePast;
  final VoidCallback onNeedMoreFuture;

  @override
  State<_DateRail> createState() => _DateRailState();
}

class _DateRailState extends State<_DateRail> {
  static const _railWidth = 125.0;
  static const double _itemExtent =
      kCardHeight + _kRailSep; // chỉ để tính height item; KHÔNG snap

  bool _loadingFuture = false;
  bool _loadingPast = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScrollEdge);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScrollEdge);
    super.dispose();
  }

  // Chỉ dùng để nạp thêm ngày khi gần cuối — KHÔNG chọn ngày
  void _onScrollEdge() {
    if (!widget.controller.hasClients) return;
    final pos = widget.controller.position;
    if (pos.pixels >= pos.maxScrollExtent - 60 && !_loadingFuture) {
      _loadingFuture = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onNeedMoreFuture();
        _loadingFuture = false;
      });
    }
  }

  // Chỉ dùng để nạp quá khứ khi overscroll trên đỉnh — KHÔNG chọn ngày
  bool _handleScrollNotification(ScrollNotification n) {
    if (n is OverscrollNotification && n.overscroll < 0 && !_loadingPast) {
      _loadingPast = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onNeedMorePast();
        _loadingPast = false;
      });
    }
    // Không xử lý ScrollEnd → không auto-select
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final fmtMonth = DateFormat('MMM');
    final fmtDay = DateFormat('dd');
    final fmtDow = DateFormat('EEE');
    final today = DateTime.now();
    final todayTrunc = DateTime(today.year, today.month, today.day);

    return ValueListenableBuilder<DateTime>(
      valueListenable: widget.selectedDateListenable,
      builder: (context, selected, _) {
        return SizedBox(
          width: _railWidth,
          child: NotificationListener<ScrollNotification>(
            onNotification: _handleScrollNotification,
            child: ListView.separated(
              controller: widget.controller,
              padding: const EdgeInsets.fromLTRB(0, 0, 8, 24),
              itemCount: widget.dates.length,
              separatorBuilder: (_, __) => const SizedBox(height: _kRailSep),
              itemBuilder: (context, i) {
                final d = widget.dates[i];
                final isToday = d == todayTrunc;
                final isSelected = d == selected;

                // Hiệu ứng mờ dần cho ngày sau selected (không ảnh hưởng chọn)
                final diffDays = d.difference(selected).inDays;
                double opacity = 1.0;
                if (diffDays > 0) {
                  opacity = (1.0 - diffDays * 0.15).clamp(0.35, 1.0);
                }

                return Opacity(
                  opacity: opacity,
                  child: GestureDetector(
                    // CHỈ TAP MỚI CHỌN
                    onTap: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        widget.onSelect(d);
                      });
                    },
                    child: Container(
                      height: kCardHeight,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color.fromARGB(255, 255, 149, 42)
                            : Colors.white,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(14),
                          bottomRight: Radius.circular(14),
                        ),
                        border: Border.all(
                          color: isSelected
                              ? _orange
                              : const Color.fromARGB(255, 156, 156, 156),
                          width: 1.2,
                        ),
                        boxShadow: isSelected
                            ? const [
                                BoxShadow(
                                  color: Color(0x26000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 6),
                                ),
                              ]
                            : null,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            fmtDay.format(d),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            fmtMonth.format(d),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black54,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: .3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (isToday)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _orange,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'Today',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          else
                            Text(
                              fmtDow.format(d),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black38,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// ================= RIGHT PANEL =================
class ScheduleReport {
  final String title;
  final String location;
  final String time;
  final String priority;
  final Color dotColor;
  final DateTime date;

  const ScheduleReport(
    this.title,
    this.location,
    this.time,
    this.priority,
    this.dotColor,
    this.date,
  );
}

class _SchedulePanel extends StatelessWidget {
  _SchedulePanel({super.key, required this.selectedDateListenable});
  final ValueListenable<DateTime> selectedDateListenable;

  // mock data
  final List<ScheduleReport> _all = [
    ScheduleReport(
      'Chatbot flagged: Hallucination',
      'AI Helper – Q&A',
      '8:30 AM',
      'High',
      Colors.lightBlueAccent,
      DateTime.now(),
    ),
    ScheduleReport(
      'Student dispute on scoring',
      'Class CS102',
      '9:45 AM',
      'Medium',
      Colors.tealAccent,
      DateTime.now(),
    ),
    ScheduleReport(
      'Escalation needed',
      'NLP Lab',
      '1:00 PM',
      'Critical',
      Colors.pinkAccent,
      DateTime.now().add(const Duration(days: 1)),
    ),
    ScheduleReport(
      'Review yesterday issue',
      'NLP Lab',
      '2:10 PM',
      'Low',
      Colors.amberAccent,
      DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  static DateTime _trunc(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime>(
      valueListenable: selectedDateListenable,
      builder: (context, selected, _) {
        final day = _trunc(selected);
        final items = _all.where((e) => _trunc(e.date) == day).toList();

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(0, 0, 16, 24),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) => _ReportCard(it: items[i]),
        );
      },
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.it});
  final ScheduleReport it;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/reports/detail', extra: it),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        constraints: const BoxConstraints(minHeight: kCardHeight),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 6, right: 8),
              decoration: BoxDecoration(
                color: it.dotColor,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          it.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                            height: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        it.time,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: const [
                      Icon(
                        Icons.place_rounded,
                        size: 16,
                        color: Colors.black45,
                      ),
                      SizedBox(width: 6),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _PriorityPill(level: it.priority),
                      const Spacer(),
                      InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () {},
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.more_horiz_rounded,
                            size: 18,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityPill extends StatelessWidget {
  const _PriorityPill({required this.level});
  final String level;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: _pillGrey,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: const [
              Icon(Icons.circle, size: 6, color: Colors.black45),
              SizedBox(width: 2),
              Icon(Icons.circle, size: 6, color: Colors.black26),
              SizedBox(width: 2),
              Icon(Icons.circle, size: 6, color: Colors.black12),
            ],
          ),
          const SizedBox(width: 8),
          const Text(
            'Priority',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Color(0xFFE5E7EB)),
            ),
            child: Text(
              level,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
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
                            Colors.white.withOpacity(0.10), // mờ trên
                            Colors.white.withOpacity(0.70), // giữa rõ
                            Colors.white.withOpacity(0.70), // giữa rõ
                            Colors.white.withOpacity(0.10), // mờ dưới
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
