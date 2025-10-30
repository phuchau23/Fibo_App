class StudentEntity {
  final String id;
  final String? firstName;
  final String? lastName;
  final String email;
  final String studentId;
  final String roleInClass;
  final String status;

  const StudentEntity({
    required this.id,
    this.firstName,
    this.lastName,
    required this.email,
    required this.studentId,
    required this.roleInClass,
    required this.status,
  });

  String get displayName {
    final f = (firstName ?? '').trim();
    final l = (lastName ?? '').trim();
    final full = '$f $l'.trim();
    return full.isEmpty ? studentId : full;
  }
}
