import 'package:flutter/material.dart';

import 'package:swp_app/features/document/presentation/pages/documents_tab.dart';
import 'package:swp_app/features/feedback/presentation/models/feedback_navigation.dart';
import 'package:swp_app/features/feedback/presentation/pages/feedback_tab.dart';
import 'package:swp_app/features/qa/presentation/pages/qa_tab.dart';
import 'package:swp_app/shared/presentation/header.dart';

class CoursePage extends StatefulWidget {
  final int sessionId;
  final int? initialTabIndex;
  const CoursePage({super.key, required this.sessionId, this.initialTabIndex});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> with TickerProviderStateMixin {
  late final TabController _tabController;
  late ValueKey<int> _documentsKey;
  late ValueKey<int> _qaKey;
  late ValueKey<int> _feedbackKey;
  String? _documentsInitialTopicId;
  String? _documentsInitialTopicName;
  String? _qaInitialTopicId;
  String? _qaInitialTopicName;
  String? _qaInitialAnswerId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex ?? 0,
    );
    _documentsKey = ValueKey(widget.sessionId);
    _qaKey = ValueKey(widget.sessionId);
    _feedbackKey = ValueKey(widget.sessionId);
  }

  @override
  void didUpdateWidget(covariant CoursePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sessionId != widget.sessionId) {
      _tabController.index = widget.initialTabIndex ?? 0;
      _documentsKey = ValueKey(widget.sessionId);
      _qaKey = ValueKey(widget.sessionId);
      _feedbackKey = ValueKey(widget.sessionId);
      _documentsInitialTopicId = null;
      _documentsInitialTopicName = null;
      _qaInitialTopicId = null;
      _qaInitialTopicName = null;
      _qaInitialAnswerId = null;
    }
  }

  void _handleFeedbackNavigation(FeedbackNavigationRequest request) {
    switch (request.target) {
      case FeedbackNavigationTarget.documents:
        setState(() {
          _documentsInitialTopicId = request.topicId;
          _documentsInitialTopicName = request.topicName;
          _documentsKey = ValueKey(widget.sessionId + 1);
          _tabController.index = 0;
        });
        break;
      case FeedbackNavigationTarget.qa:
        setState(() {
          _qaInitialTopicId = request.topicId;
          _qaInitialTopicName = request.topicName;
          _qaInitialAnswerId = request.answerId;
          _qaKey = ValueKey(widget.sessionId + 1);
          _tabController.index = 1;
        });
        break;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).viewPadding.top;
    return Scaffold(
      body: SafeArea(
        child: _CourseBackground(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Column(
                children: [
                  SizedBox(height: topInset),
                  OrangeBannerHeader(
                    onMenu: () => Navigator.of(context).maybePop(),
                    title: 'Course Center',
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
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: _SegmentedTabBar(
                                  controller: _tabController,
                                  tabs: const [
                                    Tab(text: 'Documents'),
                                    Tab(text: 'Q&A'),
                                    Tab(text: 'Feedback'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      body: TabBarView(
                        controller: _tabController,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          DocumentsTab(
                            key: _documentsKey,
                            sessionId: widget.sessionId,
                            initialTopicId: _documentsInitialTopicId,
                            initialTopicName: _documentsInitialTopicName,
                          ),
                          QaTab(
                            key: _qaKey,
                            sessionId: widget.sessionId,
                            initialTopicId: _qaInitialTopicId,
                            initialTopicName: _qaInitialTopicName,
                            initialAnswerId: _qaInitialAnswerId,
                          ),
                          FeedbackTab(
                            key: _feedbackKey,
                            sessionId: widget.sessionId,
                            onNavigate: _handleFeedbackNavigation,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SegmentedTabBar extends StatelessWidget {
  final List<Widget> tabs;
  final TabController controller;
  const _SegmentedTabBar({required this.tabs, required this.controller});

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
        controller: controller,
        tabs: tabs,
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

class _CourseBackground extends StatelessWidget {
  final Widget child;
  const _CourseBackground({required this.child});

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
