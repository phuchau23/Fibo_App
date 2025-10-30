import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:swp_app/features/class/presentation/pages/class_list_page.dart';
import 'package:swp_app/features/domains/presentation/pages/domain_page.dart';
import 'package:swp_app/shared/presentation/pages/home_page.dart';
import 'package:swp_app/shared/presentation/pages/profile_page.dart';
import 'package:swp_app/shared/presentation/pages/report_page.dart';

class FooterMenu extends StatefulWidget {
  const FooterMenu({super.key});

  @override
  State<FooterMenu> createState() => _FooterMenuState();
}

class _FooterMenuState extends State<FooterMenu> {
  int myCurrentIndex = 0;
  bool _isNavVisible = true;

  final pages = [HomePage(), ClassListPage(), DomainTabsPage(), ProfilePage()];

  bool _onScroll(ScrollNotification n) {
    // Chỉ xử lý nếu trang hiện tại có thể cuộn
    final canScroll = n.metrics.maxScrollExtent > 0;
    if (!canScroll) {
      // Trang ngắn: luôn hiện nav, bỏ qua animation ẩn/hiện theo cuộn
      if (!_isNavVisible) setState(() => _isNavVisible = true);
      return false;
    }

    // Với trang dài: ẩn khi kéo xuống, hiện khi kéo lên
    if (n is ScrollUpdateNotification && n.dragDetails != null) {
      final dy = n.scrollDelta ?? 0.0;
      if (dy > 0 && _isNavVisible) {
        // cuộn xuống
        setState(() => _isNavVisible = false);
      } else if (dy < 0 && !_isNavVisible) {
        // cuộn lên
        setState(() => _isNavVisible = true);
      }
    }

    // Trường hợp thả tay, hệ thống có thể phát UserScroll end/start
    if (n is UserScrollNotification) {
      if (n.direction == ScrollDirection.reverse && _isNavVisible) {
        setState(() => _isNavVisible = false);
      } else if (n.direction == ScrollDirection.forward && !_isNavVisible) {
        setState(() => _isNavVisible = true);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Lắng nghe mọi ScrollNotification của page hiện tại
          Positioned.fill(
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScroll,
              child: pages[myCurrentIndex],
            ),
          ),

          // Bottom nav nổi + animation slide theo hướng cuộn
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              minimum: const EdgeInsets.only(bottom: 30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOutCubic,
                  offset: _isNavVisible ? Offset.zero : const Offset(0, 1.2),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    opacity: _isNavVisible ? 1 : 0,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.20),
                            blurRadius: 30,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BottomNavigationBar(
                          type: BottomNavigationBarType.fixed,
                          currentIndex: myCurrentIndex,
                          backgroundColor: Colors.white,
                          selectedItemColor: const Color.fromARGB(
                            255,
                            240,
                            80,
                            6,
                          ),
                          unselectedItemColor: Colors.grey,
                          selectedFontSize: 12,
                          showSelectedLabels: true,
                          showUnselectedLabels: false,
                          onTap: (index) =>
                              setState(() => myCurrentIndex = index),
                          items: const [
                            BottomNavigationBarItem(
                              icon: Icon(Icons.home_filled),
                              label: 'Home',
                            ),
                            BottomNavigationBarItem(
                              icon: Icon(Icons.people_alt_outlined),
                              label: 'Class',
                            ),
                            BottomNavigationBarItem(
                              icon: Icon(Icons.receipt_long),
                              label: 'Topic',
                            ),
                            BottomNavigationBarItem(
                              icon: Icon(Icons.person_outline),
                              label: 'Profile',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
