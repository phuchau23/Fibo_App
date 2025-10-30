class LecturerEntity {
  final String id;
  final String fullName;
  const LecturerEntity({required this.id, required this.fullName});
}

class StudentEntity {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String studentId;
  final String roleInClass;
  final String status;

  const StudentEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.studentId,
    required this.roleInClass,
    required this.status,
  });

  String get fullName => '$firstName $lastName';
}

class ClassWithStudentsEntity {
  final String id;
  final String code;
  final String status;
  final DateTime createdAt;
  final LecturerEntity lecturer;
  final List<StudentEntity> students;

  const ClassWithStudentsEntity({
    required this.id,
    required this.code,
    required this.status,
    required this.createdAt,
    required this.lecturer,
    required this.students,
  });

  
}
