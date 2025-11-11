import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swp_app/features/class/presentation/pages/class_list_page.dart';
import 'package:swp_app/features/topic/presentation/pages/topic_page.dart';
import 'package:swp_app/features/course/presentation/pages/course_page.dart';
import 'package:swp_app/shared/presentation/pages/home_page.dart';
import 'package:swp_app/shared/presentation/pages/profile_page.dart';
import 'package:swp_app/shared/presentation/providers/navigation_provider.dart';

class FooterMenu extends ConsumerStatefulWidget {
  const FooterMenu({super.key});

  @override
  ConsumerState<FooterMenu> createState() => _FooterMenuState();
}

class _FooterMenuState extends ConsumerState<FooterMenu> {
  int myCurrentIndex = 0;
  bool _isNavVisible = true;
  int _courseVersion = 0;
  int _coursesSessionId = 0;

  void _handleNavigationRequest(NavigationRequest request) {
    setState(() {
      switch (request.target) {
        case NavigationTarget.home:
          myCurrentIndex = 0;
          break;
        case NavigationTarget.classList:
          myCurrentIndex = 1;
          break;
        case NavigationTarget.topic:
          myCurrentIndex = 2;
          break;
        case NavigationTarget.course:
          _courseVersion++;
          _coursesSessionId++;
          myCurrentIndex = 3;
          break;
        case NavigationTarget.courseFeedback:
          _courseVersion++;
          _coursesSessionId++;
          myCurrentIndex = 3;
          // Store initial tab index for CoursePage
          _initialCourseTabIndex = 2; // Feedback tab is index 2
          break;
        case NavigationTarget.profile:
          myCurrentIndex = 4;
          break;
      }
    });
  }

  int? _initialCourseTabIndex;

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const HomePage();
      case 1:
        return const ClassListPage();
      case 2:
        return const TopicPage();
      case 3:
        final page = CoursePage(
          key: ValueKey(_courseVersion),
          sessionId: _coursesSessionId,
          initialTabIndex: _initialCourseTabIndex,
        );
        // Reset after use
        _initialCourseTabIndex = null;
        return page;
      case 4:
        return const ProfilePage();
      default:
        return const SizedBox.shrink();
    }
  }

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
    // Listen to navigation requests
    ref.listen<NavigationRequest?>(navigationRequestProvider, (previous, next) {
      if (next != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleNavigationRequest(next);
          // Clear the request after handling
          ref.read(navigationRequestProvider.notifier).state = null;
        });
      }
    });

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Lắng nghe mọi ScrollNotification của page hiện tại
          Positioned.fill(
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScroll,
              child: _buildPage(myCurrentIndex),
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
                          onTap: (index) {
                            setState(() {
                              if (index == 3) {
                                _courseVersion++;
                                _coursesSessionId++;
                              }
                              myCurrentIndex = index;
                            });
                          },
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
                              icon: Icon(Icons.menu_book_outlined),
                              label: 'Course',
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
