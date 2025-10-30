import 'package:dartz/dartz.dart';
import '../repositories/class_repository.dart';
import '../errors/class_failure.dart';
import '../entities/class_entity.dart';

class GetLecturerClasses {
  final ClassRepository repo;
  const GetLecturerClasses(this.repo);


  Future<Either<ClassFailure, ClassPage>> call({
    required String lecturerId,
    int page = 1,
    int pageSize = 10,
  }) {
    return repo.getLecturerClasses(
      lecturerId: lecturerId,
      page: page,
      pageSize: pageSize,
    );
  }

  
}
