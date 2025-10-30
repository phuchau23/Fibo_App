import 'package:dartz/dartz.dart';
import 'package:swp_app/features/class/domain/entities/class_students_entities.dart';
import '../errors/class_failure.dart';
import '../entities/class_entity.dart';

abstract class ClassRepository {
  Future<Either<ClassFailure, ClassPage>> getLecturerClasses({
    required String lecturerId,
    int page = 1,
    int pageSize = 10,
  });

  Future<Either<String, ClassWithStudentsEntity>> getClassWithStudents({
    required String classId,
  });

  Future<Either<String, List<StudentEntity>>> getStudentsWithoutGroup({
    required String classId,
  });
}
