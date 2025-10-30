class GroupMemberEntity {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String studentId;
  final String roleInClass;
  final String status;

  const GroupMemberEntity({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.studentId,
    required this.roleInClass,
    required this.status,
  });
}
