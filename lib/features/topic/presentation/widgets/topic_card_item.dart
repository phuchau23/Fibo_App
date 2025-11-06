import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swp_app/features/topic/domain/entities/topic_entity.dart';

class TopicCardItem extends StatelessWidget {
  final TopicEntity item;
  final VoidCallback onTap;

  const TopicCardItem({super.key, required this.item, required this.onTap});

  static const double _minHeight = 84;

  @override
  Widget build(BuildContext context) {
    final r16 = BorderRadius.circular(16);
    final title = item.name.isEmpty ? 'Untitled topic' : item.name;
    final statusDot = const Color(0xFF28C76F);
    final statusText = 'OPEN';

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
      const Color(0xFF7DE2D1),
      const Color(0xFFA78BFA),
      const Color(0xFFFCD34D),
      const Color(0xFFFB7185),
      const Color(0xFF86EFAC),
      const Color(0xFF60A5FA),
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
