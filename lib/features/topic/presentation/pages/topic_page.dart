import 'package:flutter/material.dart';

import 'package:swp_app/features/topic/presentation/pages/all_topic_tab_body.dart';
import 'package:swp_app/features/topic/presentation/pages/my_topic_tab_body.dart';
import 'package:swp_app/shared/presentation/header.dart';

class TopicPage extends StatelessWidget {
  const TopicPage({super.key});
  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).viewPadding.top;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: _AppBackground(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Column(
                  children: [
                    SizedBox(height: topInset),
                    OrangeBannerHeader(
                      onMenu: () => Navigator.of(context).maybePop(),
                      title: 'FPT UNIVERSITY',
                    ),
                    Expanded(
                      child: NestedScrollView(
                        headerSliverBuilder: (context, inner) => [
                          SliverAppBar(
                            pinned: true,
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                            toolbarHeight: 0,
                            bottom: PreferredSize(
                              preferredSize: const Size.fromHeight(64),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  12,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: _SegmentedTabBar(
                                    tabs: const [
                                      Tab(text: 'All Topic'),
                                      Tab(text: 'My Topic'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                        body: const TabBarView(
                          physics: BouncingScrollPhysics(),
                          children: [AllTopicTabBody(), MyTopicTabBody()],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ------------------------- Segmented TabBar ------------------------- */
class _SegmentedTabBar extends StatelessWidget {
  final List<Widget> tabs;
  const _SegmentedTabBar({required this.tabs});

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest.withOpacity(.5);
    final border = Border.all(color: Colors.black12, width: 0.5);

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: border,
      ),
      child: TabBar(
        tabs: tabs,
        isScrollable: false,
        dividerColor: Colors.transparent,
        labelPadding: EdgeInsets.zero,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: border,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        labelColor: Colors.black,
        unselectedLabelColor: Theme.of(
          context,
        ).colorScheme.onSurface.withOpacity(.6),
        labelStyle: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: Theme.of(context).textTheme.titleMedium,
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
                  FittedBox(
                    fit: BoxFit.cover,
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: Image.asset('assets/images/bg_header_2.jpg'),
                    ),
                  ),
                  IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 10),
                            Colors.white.withValues(alpha: 0.70),
                            Colors.white.withValues(alpha: 0.70),
                            Colors.white.withValues(alpha: 10),
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
        child,
      ],
    );
  }
}
