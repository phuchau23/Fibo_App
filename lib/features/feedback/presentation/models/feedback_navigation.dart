enum FeedbackNavigationTarget { qa, documents }

class FeedbackNavigationRequest {
  final FeedbackNavigationTarget target;
  final String? topicId;
  final String? topicName;
  final String? answerId;
  final String? answerContent;

  const FeedbackNavigationRequest({
    required this.target,
    this.topicId,
    this.topicName,
    this.answerId,
    this.answerContent,
  });
}
