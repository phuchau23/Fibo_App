import 'package:json_annotation/json_annotation.dart';
import 'package:swp_app/features/class/domain/entities/class_entity.dart';
import 'package:swp_app/features/class/domain/entities/class_students_entities.dart';

part 'class_students_models.g.dart';

@JsonSerializable()
class ClassStudentsEnvelope {
  final int statusCode;
  final String code;
  final String message;
  final List<ClassWithStudentsModel> data;

  ClassStudentsEnvelope({
    required this.statusCode,
    required this.code,
    required this.message,
    required this.data,
  });

  factory ClassStudentsEnvelope.fromJson(Map<String, dynamic> json) =>
      _$ClassStudentsEnvelopeFromJson(json);
  Map<String, dynamic> toJson() => _$ClassStudentsEnvelopeToJson(this);
}

@JsonSerializable()
class ClassWithStudentsModel {
  final String id;
  final String code;
  final String status;
  final DateTime createdAt;
  final LecturerModel lecturer;
  final List<StudentModel> students;

  ClassWithStudentsModel({
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

@JsonSerializable()
class LecturerModel {
  final String id;
  final String fullName;

  LecturerModel({required this.id, required this.fullName});

  factory LecturerModel.fromJson(Map<String, dynamic> json) =>
      _$LecturerModelFromJson(json);
  Map<String, dynamic> toJson() => _$LecturerModelToJson(this);
}

@JsonSerializable()
class StudentModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String studentId;
  final String roleInClass;
  final String status;

  StudentModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.studentId,
    required this.roleInClass,
    required this.status,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) =>
      _$StudentModelFromJson(json);
  Map<String, dynamic> toJson() => _$StudentModelToJson(this);
}

// Mapper: LecturerModel -> LecturerEntity
extension LecturerModelX on LecturerModel {
  LecturerEntity toEntity() {
    return LecturerEntity(id: id, fullName: fullName);
  }
}

// Mapper: StudentModel -> StudentEntity
extension StudentModelX on StudentModel {
  StudentEntity toEntity() {
    return StudentEntity(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      studentId: studentId,
      roleInClass: roleInClass,
      status: status,
    );
  }
}

// Mapper: ClassWithStudentsModel -> ClassWithStudentsEntity
extension ClassWithStudentsModelX on ClassWithStudentsModel {
  ClassWithStudentsEntity toEntity() {
    return ClassWithStudentsEntity(
      id: id,
      code: code,
      status: status,
      createdAt: createdAt, // đã là DateTime do @JsonSerializable()
      lecturer: lecturer.toEntity(),
      students: students.map((s) => s.toEntity()).toList(),
    );
  }

  
}
