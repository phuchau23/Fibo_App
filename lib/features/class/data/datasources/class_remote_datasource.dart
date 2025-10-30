import 'package:dio/dio.dart';
import 'package:swp_app/data/services/api_client.dart';
import 'package:swp_app/features/class/data/models/class_students_models.dart';
import '../models/class_models.dart';

class ClassRemoteDataSource {
  final Dio _dio;
  ClassRemoteDataSource(ApiClient client) : _dio = client.dio;

  Future<ClassResponseData> getLecturerClasses({
    required String lecturerId,
    int page = 1,
    int pageSize = 10,
  }) async {
    final resp = await _dio.get(
      '/auth/api/classes/lecturer/$lecturerId',
      queryParameters: {'page': page, 'pageSize': pageSize},
      options: Options(headers: const {'accept': '*/*'}),
    );

    final envelope = ClassResponseEnvelope.fromJson(
      resp.data as Map<String, dynamic>,
    );
    return envelope.data;
  }

  Future<List<ClassWithStudentsModel>> getClassWithStudents({
    required String classId,
  }) async {
    final resp = await _dio.get(
      '/auth/api/classes/$classId/students',
      options: Options(headers: {'Accept': '*/*'}),
    );

    final envelope = ClassStudentsEnvelope.fromJson(resp.data);
    // API trả về "data": [ { class+students } ], lấy phần tử đầu
    return envelope.data;
  }

  /// MỚI: GET /auth/api/classes/{classId}/students/without-group
  Future<List<StudentModel>> getStudentsWithoutGroup({
    required String classId,
  }) async {
    final resp = await _dio.get(
      '/auth/api/classes/$classId/students/without-group',
      options: Options(headers: const {'accept': '*/*'}),
    );

    final envelope = ClassStudentsEnvelope.fromJson(
      resp.data as Map<String, dynamic>,
    );

    if (envelope.data.isEmpty) return <StudentModel>[];
    // API trả "data": [ { class..., students: [...] } ]
    return envelope.data.first.students;
  }
}
