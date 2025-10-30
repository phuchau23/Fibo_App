import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swp_app/features/topic/domain/entities/topic_entity.dart';
import 'package:swp_app/features/topic/presentation/blocs/topics_providers.dart';

class TopicTabBody extends ConsumerStatefulWidget {
  const TopicTabBody({super.key});

  @override
  ConsumerState<TopicTabBody> createState() => _TopicTabBodyState();
}

class _TopicTabBodyState extends ConsumerState<TopicTabBody> {
  Future<void> _refetch() async {
    final st = ref.read(topicsNotifierProvider);
    final p = st.page?.currentPage ?? 1;
    await ref.read(topicsNotifierProvider.notifier).fetch(page: p);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final st = ref.read(topicsNotifierProvider);
      if (st.page == null && !st.loading) {
        ref.read(topicsNotifierProvider.notifier).fetch(page: 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(topicsNotifierProvider);

    if (st.loading && st.page == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if ((st.error ?? '').isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 42,
              ),
              const SizedBox(height: 8),
              Text(
                'Lỗi tải Topics',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                st.error!,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    ref.read(topicsNotifierProvider.notifier).fetch(),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final page = st.page!;
    return RefreshIndicator(
      onRefresh: _refetch,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: page.items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final t = page.items[i];
          return _TopicCardItem(
            item: t,
            onTap: () => _showTopicDetailsSheet(context, t),
          );
        },
      ),
    );
  }
}

/* ---------------- CARD ---------------- */

class _TopicCardItem extends StatelessWidget {
  final TopicEntity item;
  final VoidCallback onTap;

  const _TopicCardItem({required this.item, required this.onTap});

  static const double _minHeight = 84;

  @override
  Widget build(BuildContext context) {
    final r16 = BorderRadius.circular(16);
    final title = item.name.isEmpty ? 'Untitled topic' : item.name;
    final statusDot = const Color(0xFF28C76F);
    final statusText = 'OPEN';
    final time = _timeAgo(item.createdAt);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: r16,
        onTap: onTap,
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
                        // Header line
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

/* ---------------- STATUS CHIP ---------------- */

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

/* ---------------- DETAILS SHEET ---------------- */

void _showTopicDetailsSheet(BuildContext context, TopicEntity item) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final title = item.name.isEmpty ? 'Untitled' : item.name;
  final desc = (item.description ?? '').trim();

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
              // Description
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
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF171717)
                      : const Color(0xFFF9F9FB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
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

/* ---------------- SUB WIDGETS ---------------- */

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.isDark,
  });

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
          Icon(icon, size: 16, color: isDark ? Colors.white70 : Colors.black54),
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final bool showDivider;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.showDivider = true,
  });

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

/* ---------------- HELPERS ---------------- */

String _timeAgo(DateTime dt) {
  final d = DateTime.now().toLocal().difference(dt.toLocal());
  if (d.inMinutes < 1) return 'now';
  if (d.inMinutes < 60) return '${d.inMinutes}m';
  if (d.inHours < 24) return '${d.inHours}h';
  return '${d.inDays}d';
}

String _fmtDt(DateTime d) {
  final local = d.toLocal();
  final h = local.hour.toString().padLeft(2, '0');
  final m = local.minute.toString().padLeft(2, '0');
  final dd = local.day.toString().padLeft(2, '0');
  final mm = local.month.toString().padLeft(2, '0');
  final yyyy = local.year.toString();
  return '$h:$m • $dd/$mm/$yyyy';
}
