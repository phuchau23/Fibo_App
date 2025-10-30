import 'package:dio/dio.dart';
import 'package:swp_app/data/services/api_client.dart';
import '../models/master_topic_model.dart';

class MasterTopicsRemoteDataSource {
  final ApiClient _client;
  MasterTopicsRemoteDataSource(this._client);

  Future<PageModel<MasterTopicModel>> getAll({
    int page = 1,
    int pageSize = 10,
  }) async {
    final res = await _client.get(
      '/course/api/master-topics',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    final data = res.data['data'] as Map<String, dynamic>;
    return PageModel.fromJson(
      data,
      (o) => MasterTopicModel.fromJson(o as Map<String, dynamic>),
    );
  }

  Future<MasterTopicModel> getById(String id) async {
    final res = await _client.get('/course/api/master-topics/$id');
    final data = res.data['data'] as Map<String, dynamic>;
    return MasterTopicModel.fromJson(data);
  }

  /// API yêu cầu multipart/form-data:
  ///  - DomainId: String (uuid)      [bắt buộc]
  ///  - SemesterId: String (uuid)    [tùy chọn]
  ///  - LecturerIds: array<string>   [bắt buộc – có thể rỗng]
  ///  - Name: String                 [bắt buộc]
  ///  - Description: String          [tùy chọn]
  Future<MasterTopicModel> create({
    required String domainId,
    String? semesterId,
    required List<String> lecturerIds,
    required String name,
    String? description,
  }) async {
    final form = FormData();
    form.fields.add(MapEntry('DomainId', domainId));
    if (semesterId != null && semesterId.isNotEmpty) {
      form.fields.add(MapEntry('SemesterId', semesterId));
    }
    // Đúng format array: gửi nhiều cặp key=LecturerIds
    for (final id in lecturerIds) {
      form.fields.add(MapEntry('LecturerIds', id));
    }
    form.fields
      ..add(MapEntry('Name', name))
      ..add(MapEntry('Description', description ?? ''));

    final res = await _client.post('/course/api/master-topics', data: form);
    final data = res.data['data'] as Map<String, dynamic>;
    return MasterTopicModel.fromJson(data);
  }

  Future<MasterTopicModel> update({
    required String id,
    required String domainId,
    String? semesterId,
    required List<String> lecturerIds,
    required String name,
    String? description,
  }) async {
    final form = FormData();
    form.fields.add(MapEntry('DomainId', domainId));
    if (semesterId != null && semesterId.isNotEmpty) {
      form.fields.add(MapEntry('SemesterId', semesterId));
    }
    for (final lid in lecturerIds) {
      form.fields.add(MapEntry('LecturerIds', lid));
    }
    form.fields
      ..add(MapEntry('Name', name))
      ..add(MapEntry('Description', description ?? ''));

    final res = await _client.put('/course/api/master-topics/$id', data: form);
    final data = res.data['data'] as Map<String, dynamic>;
    return MasterTopicModel.fromJson(data);
  }

  Future<MasterTopicModel> delete({required String id}) async {
    final res = await _client.delete('/course/api/master-topics/$id');
    final data = res.data['data'] as Map<String, dynamic>;
    return MasterTopicModel.fromJson(data);
  }
}
