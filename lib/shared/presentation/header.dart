import 'package:flutter/material.dart';

class OrangeBannerHeader extends StatelessWidget {
  final VoidCallback? onMenu;
  final Widget? centerLogo;
  final String? title;

  const OrangeBannerHeader({
    super.key,
    this.onMenu,
    this.centerLogo,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    const double stripHeight = 77; // dải cam
    const double pillHeight = 66; // pill trắng
    const double headerHeight = 90;

    return SizedBox(
      height: headerHeight,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // nền trong suốt để lộ ảnh nền toàn trang
          const Positioned.fill(child: ColoredBox(color: Colors.transparent)),

          // dải ảnh ở giữa (dùng đúng bg_header_2.jpg + làm sáng nhẹ)
          Positioned(
            top: 14,
            left: 12,
            right: 12,
            height: stripHeight,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage('assets/images/bg_header.jpg'),
                  fit: BoxFit.fill,
                  colorFilter: ColorFilter.mode(
                    Colors.white24, // lớp trắng nhẹ
                    BlendMode.lighten, // làm sáng ảnh
                  ),
                ),
              ),
            ),
          ),

          // pill logo ở giữa
          Positioned(
            top: 14 + (stripHeight - pillHeight) / 2,
            child: Container(
              height: pillHeight,
              width: MediaQuery.of(context).size.width * 0.55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child:
                  centerLogo ??
                  Image.asset('assets/images/logo_fpt.png', height: 42),
            ),
          ),
        ],
      ),
    );
  }
}
