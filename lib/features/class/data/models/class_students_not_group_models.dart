import 'package:json_annotation/json_annotation.dart';

part 'class_students_not_group_models.g.dart';

/// ========== STUDENT ==========
@JsonSerializable()
class StudentModel {
  final String id;
  final String? firstName;
  final String? lastName;
  final String email;
  final String studentId;
  final String roleInClass;
  final String status;

  const StudentModel({
    required this.id,
    this.firstName,
    this.lastName,
    required this.email,
    required this.studentId,
    required this.roleInClass,
    required this.status,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) =>
      _$StudentModelFromJson(json);
  Map<String, dynamic> toJson() => _$StudentModelToJson(this);
}

/// ========== LECTURER (mini) ==========
@JsonSerializable()
class LecturerMiniModel {
  final String id;
  final String fullName;

  const LecturerMiniModel({required this.id, required this.fullName});

  factory LecturerMiniModel.fromJson(Map<String, dynamic> json) =>
      _$LecturerMiniModelFromJson(json);
  Map<String, dynamic> toJson() => _$LecturerMiniModelToJson(this);
}

/// ========== CLASS + STUDENTS ==========
@JsonSerializable()
class ClassWithStudentsModel {
  final String id;
  final String code;
  final String status;
  final String createdAt; // API trả ISO-8601 string
  final LecturerMiniModel lecturer;
  final List<StudentModel> students;

  const ClassWithStudentsModel({
    required this.id,
    required this.code,
    required this.status,
    required this.createdAt,
    required this.lecturer,
    required this.students,
  });

  factory ClassWithStudentsModel.fromJson(Map<String, dynamic> json) =>
      _$ClassWithStudentsModelFromJson(json);
  Map<String, dynamic> toJson() => _$ClassWithStudentsModelToJson(this);
}

/// ========== ENVELOPE: /students (đã có ở nơi khác thì bỏ) ==========
@JsonSerializable()
class ClassStudentsEnvelope {
  final int statusCode;
  final String code;
  final String message;
  final List<ClassWithStudentsModel> data;

  const ClassStudentsEnvelope({
    required this.statusCode,
    required this.code,
    required this.message,
    required this.data,
  });

  factory ClassStudentsEnvelope.fromJson(Map<String, dynamic> json) =>
      _$ClassStudentsEnvelopeFromJson(json);
  Map<String, dynamic> toJson() => _$ClassStudentsEnvelopeToJson(this);
}

/// ========== ENVELOPE: /students/without-group (MỚI) ==========
@JsonSerializable()
class ClassStudentsWithoutGroupEnvelope {
  final int statusCode;
  final String code;
  final String message;
  final List<ClassWithStudentsModel> data;

  const ClassStudentsWithoutGroupEnvelope({
    required this.statusCode,
    required this.code,
    required this.message,
    required this.data,
  });

  factory ClassStudentsWithoutGroupEnvelope.fromJson(
    Map<String, dynamic> json,
  ) => _$ClassStudentsWithoutGroupEnvelopeFromJson(json);
  Map<String, dynamic> toJson() =>
      _$ClassStudentsWithoutGroupEnvelopeToJson(this);
}
