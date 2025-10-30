import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';

/// Card màu cam, hiển thị thời gian thực theo Việt Nam (GMT+7) + đồng bộ NTP ngầm.
class VietnamRealtimeClockCard extends StatefulWidget {
  const VietnamRealtimeClockCard({
    super.key,
    this.height = 164,
    this.greetingName = 'Minh Tâm', // 👈 tuỳ biến tên ở đây
  });

  final double height;
  final String greetingName;

  @override
  State<VietnamRealtimeClockCard> createState() =>
      _VietnamRealtimeClockCardState();
}

class _VietnamRealtimeClockCardState extends State<VietnamRealtimeClockCard> {
  late Timer _ticker;
  Duration _ntpOffset = Duration.zero;
  DateTime _now = DateTime.now();
  Timer? _periodicSync; // đồng bộ NTP định kỳ nhẹ nhàng (ẩn)

  @override
  void initState() {
    super.initState();
    _syncNtp(); // đồng bộ NTP lúc mở
    _startTicker(); // cập nhật mỗi giây
    _startPeriodicNtpSync(); // sync lại 15 phút/lần (ẩn)
  }

  void _startTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  void _startPeriodicNtpSync() {
    _periodicSync = Timer.periodic(
      const Duration(minutes: 15),
      (_) => _syncNtp(),
    );
  }

  Future<void> _syncNtp() async {
    try {
      final ntpNow = await NTP.now(timeout: const Duration(seconds: 5));
      setState(() => _ntpOffset = ntpNow.difference(DateTime.now()));
    } catch (_) {
      // Nếu lỗi mạng → dùng giờ máy, không hiển thị gì cả
    }
  }

  @override
  void dispose() {
    _ticker.cancel();
    _periodicSync?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Giờ Việt Nam (GMT+7) + hiệu chỉnh offset NTP
    final correctedNow = _now
        .add(_ntpOffset)
        .toUtc()
        .add(const Duration(hours: 7));

    final weekday = _capitalizeFirst(
      DateFormat.EEEE('vi_VN').format(correctedNow),
    ); // Thứ Tư, ...
    final dateStr = DateFormat(
      'dd/MM/yyyy',
      'vi_VN',
    ).format(correctedNow); // 29/10/2025
    final timeStr = DateFormat(
      'HH:mm:ss',
      'vi_VN',
    ).format(correctedNow); // 15:42:05

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF9F55), Color(0xFFFF8C42)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: DefaultTextStyle(
        style: const TextStyle(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Hàng trên: Thứ + ngày (trái) | Hello, Minh Tâm (phải)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Trái: icon + weekday + date
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$weekday  ',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            height: 1.1,
                          ),
                        ),
                        TextSpan(
                          text: dateStr,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Phải: pill Hello, Minh Tâm
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withOpacity(0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.waving_hand_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Hello, ${widget.greetingName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ===== Giờ to ở giữa (trải rộng)
            Text(
              timeStr,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                height: 1.05,
              ),
            ),

            const SizedBox(height: 8),

            // ===== Dòng phụ: quốc gia + múi giờ
            Row(
              children: const [
                Icon(Icons.location_on_rounded, size: 16, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  'Việt Nam • GMT+7 (Asia/Ho_Chi_Minh)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _capitalizeFirst(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
    // Intl đôi khi trả "thứ tư", mình capitalize cho đẹp tiêu đề
  }
}
