import 'package:swp_app/data/data.dart'; // ApiClient
import '../models/semester_model.dart';

class SemestersRemoteDataSource {
  final ApiClient _client;
  SemestersRemoteDataSource(this._client);

  Future<List<SemesterModel>> getAll({int page = 1, int pageSize = 50}) async {
    final res = await _client.get(
      '/auth/api/semesters',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    final data = res.data['data'] as Map<String, dynamic>;
    final items = (data['items'] as List)
        .map((e) => SemesterModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return items;
  }
}
