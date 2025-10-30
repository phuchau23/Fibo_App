import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:swp_app/features/class/data/models/class_students_models.dart';
import 'package:swp_app/features/class/domain/entities/class_students_entities.dart';

import '../../domain/repositories/class_repository.dart';
import '../../domain/errors/class_failure.dart';
import '../../domain/entities/class_entity.dart';
import '../datasources/class_remote_datasource.dart';
import '../models/class_models.dart';

class ClassRepositoryImpl implements ClassRepository {
  final ClassRemoteDataSource remote;
  ClassRepositoryImpl(this.remote);

  @override
  Future<Either<ClassFailure, ClassPage>> getLecturerClasses({
    required String lecturerId,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final data = await remote.getLecturerClasses(
        lecturerId: lecturerId,
        page: page,
        pageSize: pageSize,
      );
      return Right(data.toEntity());
    } on DioException catch (e) {
      // Map Dio errors -> Failures
      final status = e.response?.statusCode;
      final msg = e.message ?? 'Network error';
      if (status != null && status >= 500) {
        return Left(ServerFailure(statusCode: status, message: msg));
      }
      return Left(NetworkFailure(msg));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<String, ClassWithStudentsEntity>> getClassWithStudents({
    required classId,
  }) async {
    try {
      final list = await remote.getClassWithStudents(classId: classId);
      if (list.isEmpty) {
        return left('Không tìm thấy lớp.');
      }
      // API trả mảng 1 phần tử
      return right(list.first.toEntity());
    } catch (e) {
      return left('Lỗi tải sinh viên: $e');
    }
  }

  @override
  Future<Either<String, List<StudentEntity>>> getStudentsWithoutGroup({
    required String classId,
  }) async {
    try {
      final models = await remote.getStudentsWithoutGroup(classId: classId);
      final ents = models
          .map(
            (m) => StudentEntity(
              id: m.id,
              firstName: _nz(m.firstName),
              lastName: _nz(m.lastName),
              email: m.email,
              studentId: m.studentId,
              roleInClass: m.roleInClass,
              status: m.status,
            ),
          )
          .toList();
      return right(ents);
    } catch (e) {
      return left('Lỗi tải danh sách SV chưa vào nhóm: $e');
    }
  }

  String _nz(String? v) => (v == null || v == 'null') ? '' : v;
}
