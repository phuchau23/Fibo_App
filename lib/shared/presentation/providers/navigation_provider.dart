import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NavigationTarget {
  home,
  classList,
  topic,
  course,
  courseFeedback, // Course tab với Feedback tab được chọn
  profile,
  notifications,
}

class NavigationRequest {
  final NavigationTarget target;
  final Map<String, dynamic>? params;

  const NavigationRequest({required this.target, this.params});
}

final navigationRequestProvider = StateProvider<NavigationRequest?>(
  (ref) => null,
);
