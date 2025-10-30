// lib/core/services/session_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';

class SessionService {
  const SessionService(this._storage);
  final FlutterSecureStorage _storage;

  static const _kAccessToken = 'access_token';
  static const _kUserId = 'user_id';

  Future<void> saveFromToken(String token) async {
    final payload = Jwt.parseJwt(token);
    final userId = (payload['nameid'] ?? payload['sub'])?.toString();
    if (userId == null || userId.isEmpty) {
      throw Exception('Không tìm thấy claim nameid/sub trong JWT');
    }
    await _storage.write(key: _kAccessToken, value: token);
    await _storage.write(key: _kUserId, value: userId);
  }

  Future<String?> get token async => _storage.read(key: _kAccessToken);
  Future<String?> get userId async => _storage.read(key: _kUserId);

  Future<void> clear() async {
    await _storage.delete(key: _kAccessToken);
    await _storage.delete(key: _kUserId);
  }
}
