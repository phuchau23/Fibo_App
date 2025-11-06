import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swp_app/features/topic/domain/entities/topic_entity.dart';
import 'package:swp_app/features/topic/domain/entities/topic_detail_entity.dart';
import 'package:swp_app/features/topic/presentation/blocs/topics_providers.dart';

void showTopicDetailsSheet(BuildContext context, TopicEntity item) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return ProviderScope(
        parent: ProviderScope.containerOf(context),
        child: _TopicDetailSheetContent(topicId: item.id),
      );
    },
  );
}

class _TopicDetailSheetContent extends ConsumerStatefulWidget {
  final String topicId;
  const _TopicDetailSheetContent({required this.topicId});

  @override
  ConsumerState<_TopicDetailSheetContent> createState() =>
      _TopicDetailSheetContentState();
}

class _TopicDetailSheetContentState
    extends ConsumerState<_TopicDetailSheetContent> {
  TopicDetailEntity? _detail;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final useCase = ref.read(getTopicByIdUseCaseProvider);
    final result = await useCase(widget.topicId);

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _loading = false;
          _error = failure.message;
        });
      },
      (detail) {
        setState(() {
          _loading = false;
          _detail = detail;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const _LoadingView();
    }

    if (_error != null) {
      return _ErrorView(message: _error!);
    }

    if (_detail == null) {
      return const _ErrorView(message: 'No data available');
    }

    return _DetailContent(detail: _detail!);
  }
}

class _DetailContent extends StatelessWidget {
  final TopicDetailEntity detail;
  const _DetailContent({required this.detail});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final title = detail.name.isEmpty ? 'Untitled' : detail.name;
    final desc = (detail.description ?? '').trim();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
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
            // Header
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
                      'Created • ${_fmtDt(detail.createdAt)}',
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
                      'Description',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF333333),
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
            // Master Topic Info
            if (detail.masterTopic != null) ...[
              _SectionCard(
                title: 'Master Topic',
                isDark: isDark,
                children: [
                  _InfoRow(
                    icon: Icons.label_outline,
                    label: 'Name',
                    value: detail.masterTopic!.name,
                    isDark: isDark,
                  ),
                  if (detail.masterTopic!.description != null)
                    _InfoRow(
                      icon: Icons.description_outlined,
                      label: 'Description',
                      value: detail.masterTopic!.description!,
                      isDark: isDark,
                    ),
                  _InfoRow(
                    icon: Icons.access_time_rounded,
                    label: 'Created at',
                    value: _fmtDt(detail.masterTopic!.createdAt),
                    isDark: isDark,
                    showDivider: false,
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            // Domain Info
            if (detail.masterTopic?.domain != null) ...[
              _SectionCard(
                title: 'Domain',
                isDark: isDark,
                children: [
                  _InfoRow(
                    icon: Icons.category_outlined,
                    label: 'Name',
                    value: detail.masterTopic!.domain!.name,
                    isDark: isDark,
                  ),
                  if (detail.masterTopic!.domain!.description != null)
                    _InfoRow(
                      icon: Icons.description_outlined,
                      label: 'Description',
                      value: detail.masterTopic!.domain!.description!,
                      isDark: isDark,
                    ),
                  _InfoRow(
                    icon: Icons.access_time_rounded,
                    label: 'Created at',
                    value: _fmtDt(detail.masterTopic!.domain!.createdAt),
                    isDark: isDark,
                    showDivider: false,
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            // Semester Info
            if (detail.masterTopic?.semester != null) ...[
              _SectionCard(
                title: 'Semester',
                isDark: isDark,
                children: [
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Code',
                    value: detail.masterTopic!.semester!.code,
                    isDark: isDark,
                  ),
                  _InfoRow(
                    icon: Icons.event_outlined,
                    label: 'Term',
                    value: detail.masterTopic!.semester!.term,
                    isDark: isDark,
                  ),
                  if (detail.masterTopic!.semester!.year != null)
                    _InfoRow(
                      icon: Icons.calendar_month_outlined,
                      label: 'Year',
                      value: detail.masterTopic!.semester!.year.toString(),
                      isDark: isDark,
                    ),
                  if (detail.masterTopic!.semester!.startDate != null)
                    _InfoRow(
                      icon: Icons.play_arrow_outlined,
                      label: 'Start Date',
                      value: _fmtDt(detail.masterTopic!.semester!.startDate!),
                      isDark: isDark,
                    ),
                  if (detail.masterTopic!.semester!.endDate != null)
                    _InfoRow(
                      icon: Icons.stop_outlined,
                      label: 'End Date',
                      value: _fmtDt(detail.masterTopic!.semester!.endDate!),
                      isDark: isDark,
                      showDivider: false,
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            // Basic Info
            _SectionCard(
              title: 'Topic Information',
              isDark: isDark,
              children: [
                _InfoRow(
                  icon: Icons.info_outline,
                  label: 'Status',
                  value: detail.status,
                  isDark: isDark,
                ),
                _InfoRow(
                  icon: Icons.access_time_rounded,
                  label: 'Created at',
                  value: _fmtDt(detail.createdAt),
                  isDark: isDark,
                  showDivider: false,
                ),
              ],
            ),
            const SizedBox(height: 28),
          ],
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final bool isDark;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.isDark,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171717) : const Color(0xFFF9F9FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF2B2B2B),
              ),
            ),
          ),
          ...children,
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

class _LoadingView extends StatelessWidget {
  const _LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.3,
      builder: (_, __) => const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.4,
      builder: (_, __) => Center(
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
                'Error loading topic details',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
