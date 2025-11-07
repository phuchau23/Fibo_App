class ApiEndpoints {
  //auth
  static const String register = '/auth/api/users/register';
  static const String login = '/auth/api/users/login';
  static const String loginGoogle = '/auth/api/users/login-gg';
  static const String changePassword = '/auth/api/users/change-password';
  static const String forgotPassword = '/auth/api/users/forgot-password';
  static const String resetPassword = '/auth/api/users/reset-password';
  static String userById(String userId) => '/auth/api/users/$userId';

  // classess
  static const String classes = '/auth/api/classes';

  //domain
  static const String domain = '/course/api/domains';
  static String domainById(String id) => '/course/api/domains/$id';
  static const String masterTopic = '/course/api/master-topics';
  static String masterTopicById(String id) => '/course/api/master-topics/$id';
  static const String topics = '/course/api/topics';
  static String topicById(String id) => '/course/api/topics/$id';
  static String topicsByMaster(String masterTopicId) =>
      '/course/api/topics/master-topic/$masterTopicId';

  //group
  static const String groupsByClass =
      '/auth/api/groups/class'; // + '/{classId}'
  static const String groupMembers =
      '/auth/api/groups'; // + '/{groupId}/members'
  static const String groupsRoot = '/auth/api/groups'; // POST create

  // notifications
  static String notificationsByLecturer(String lecturerId) =>
      '/course/api/notifications/lecturer/$lecturerId';
  static const String notifications = '/course/api/notifications';
  static String notificationById(String id) => '/course/api/notifications/$id';

  static const String multipartContentType = 'multipart/form-data';
}
