import 'package:swp_app/core/constants/api.constants.dart';
import 'package:swp_app/data/services/api_client.dart';
import 'package:swp_app/features/auth/data/models/login_credentials.dart';
import '../models/auth_payloads.dart';

class AuthRemoteDataSource {
  final ApiClient _client;
  AuthRemoteDataSource(this._client);

  Future<AuthResponse> register(RegisterRequest body) async {
    final res = await _client.dio.post(
      ApiEndpoints.register,
      data: body.toJson(),
    );
    return AuthResponse.fromApi(res.data as Map<String, dynamic>);
  }

  Future<AuthResponse> login(LoginRequest body) async {
    final res = await _client.postForm(ApiEndpoints.login, {
      'Email': body.email.trim(),
      'Password': body.password,
    });

    // Dùng factory mới đọc được data.token
    return AuthResponse.fromApi(Map<String, dynamic>.from(res.data as Map));
  }

  Future<AuthResponse> loginGoogle(GoogleLoginRequest body) async {
    final res = await _client.dio.post(
      ApiEndpoints.loginGoogle,
      data: body.toJson(),
    );
    return AuthResponse.fromApi(res.data as Map<String, dynamic>);
  }

  Future<MessageResponse> changePassword(ChangePasswordRequest body) async {
    final res = await _client.dio.put(
      ApiEndpoints.changePassword,
      data: body.toJson(),
    );
    return MessageResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<MessageResponse> forgotPassword(ForgotPasswordRequest body) async {
    final res = await _client.dio.post(
      ApiEndpoints.forgotPassword,
      data: body.toJson(),
    );
    return MessageResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<MessageResponse> resetPassword(ResetPasswordRequest body) async {
    final res = await _client.dio.post(
      ApiEndpoints.resetPassword,
      data: body.toJson(),
    );
    return MessageResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<UserModel> getUserById(String userId) async {
    final res = await _client.dio.get(ApiEndpoints.userById(userId));
    return UserModel.fromJson(res.data as Map<String, dynamic>);
  }
}
