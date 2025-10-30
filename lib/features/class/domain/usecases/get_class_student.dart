import 'package:dartz/dartz.dart';
import 'package:swp_app/features/class/domain/entities/class_students_entities.dart';
import 'package:swp_app/features/class/domain/repositories/class_repository.dart';

class GetClassStudentsUseCase {
  final ClassRepository repo;
  GetClassStudentsUseCase(this.repo);

  Future<Either<String, ClassWithStudentsEntity>> call(String classId) {
    return repo.getClassWithStudents(classId: classId);
  }
}
