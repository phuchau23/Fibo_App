import 'package:dio/dio.dart';
import 'package:swp_app/data/services/api_client.dart';
import '../models/domain_model.dart';

class DomainRemoteDataSource {
  final ApiClient _client;
  DomainRemoteDataSource(this._client);

  Future<DomainPageModel> getDomains({
    required int page,
    required int pageSize,
  }) async {
    final resp = await _client.get(
      '/course/api/domains',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return DomainPageModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<DomainModel> createDomain({
    required String name,
    required String description,
  }) async {
    final form = FormData.fromMap({'Name': name, 'Description': description});

    final resp = await _client.post(
      '/course/api/domains',
      data: form,
      options: Options(contentType: Headers.multipartFormDataContentType),
    );

    final data =
        (resp.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return DomainModel.fromJson(data);
  }

  Future<DomainModel> updateDomain({
    required String id,
    required String name,
    required String description,
  }) async {
    final form = FormData.fromMap({'Name': name, 'Description': description});

    final resp = await _client.put(
      '/course/api/domains/$id',
      data: form,
      options: Options(contentType: Headers.multipartFormDataContentType),
    );

    final data =
        (resp.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return DomainModel.fromJson(data);
  }

  Future<DomainModel> deleteDomain({required String id}) async {
    final resp = await _client.delete('/course/api/domains/$id');
    final data =
        (resp.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return DomainModel.fromJson(data);
  }
}
