import 'package:flutter/material.dart';

/// Nền mờ dùng chung cho toàn app
class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Ảnh nền phủ toàn màn
        Positioned.fill(
          child: Image.asset(
            'assets/images/bg_header_2.jpg',
            fit: BoxFit.cover,
            color: Colors.white.withValues(
              alpha: 0.55,
            ), // độ mờ trắng phủ lên ảnh
            colorBlendMode: BlendMode.lighten, // làm sáng nhẹ toàn ảnh
          ),
        ),
        // lớp mờ thêm (optional)
        Positioned.fill(
          child: Container(color: Colors.white.withValues(alpha: 0.2)),
        ),
        // nội dung app
        child,
      ],
    );
  }
}
