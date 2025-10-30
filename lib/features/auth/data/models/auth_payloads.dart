import 'package:json_annotation/json_annotation.dart';
import 'package:swp_app/features/auth/data/models/login_credentials.dart';

part 'auth_payloads.g.dart';

/// ==== Requests ====
@JsonSerializable()
class RegisterRequest {
  final String email;
  final String password;
  final String? name;
  final String? phone;
  RegisterRequest({
    required this.email,
    required this.password,
    this.name,
    this.phone,
  });
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;
  LoginRequest({required this.email, required this.password});
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class GoogleLoginRequest {
  final String idToken; // Google ID token
  GoogleLoginRequest({required this.idToken});
  Map<String, dynamic> toJson() => _$GoogleLoginRequestToJson(this);
}

@JsonSerializable()
class ChangePasswordRequest {
  final String oldPassword;
  final String newPassword;
  ChangePasswordRequest({required this.oldPassword, required this.newPassword});
  Map<String, dynamic> toJson() => _$ChangePasswordRequestToJson(this);
}

@JsonSerializable()
class ForgotPasswordRequest {
  final String email;
  ForgotPasswordRequest({required this.email});
  Map<String, dynamic> toJson() => _$ForgotPasswordRequestToJson(this);
}

@JsonSerializable()
class ResetPasswordRequest {
  final String email;
  final String otp; // hoặc resetToken
  final String newPassword;
  ResetPasswordRequest({
    required this.email,
    required this.otp,
    required this.newPassword,
  });
  Map<String, dynamic> toJson() => _$ResetPasswordRequestToJson(this);
}

/// ==== Responses ====
@JsonSerializable()
class AuthResponse {
  final String accessToken; // token đăng nhập
  final String? refreshToken; // optional
  final UserModel? user; // <- cho nullable vì API không trả
  final bool requirePasswordChange; // backend có trả

  AuthResponse({
    required this.accessToken,
    this.refreshToken,
    this.user,
    this.requirePasswordChange = false,
  });

  /// Factory "thông minh" hiểu cả:
  /// - { data: { token, requirePasswordChange } }
  /// - { accessToken, refreshToken, user }
  factory AuthResponse.fromApi(Map<String, dynamic> json) {
    final root = json;
    final data = (root['data'] is Map) ? root['data'] as Map : const {};

    // Lấy token theo nhiều key
    final token =
        data['token'] ??
        root['accessToken'] ??
        root['token'] ??
        root['access_token'];

    if (token is! String || token.isEmpty) {
      throw Exception('Thiếu access token trong response: $json');
    }

    // requirePasswordChange nếu có
    final requirePw = (data['requirePasswordChange'] as bool?) ?? false;

    // user nếu API có trả (không bắt buộc)
    final userJson = root['user'] ?? data['user'];
    final user = (userJson is Map<String, dynamic>)
        ? UserModel.fromJson(userJson)
        : null;

    return AuthResponse(
      accessToken: token,
      refreshToken: root['refreshToken'] as String?,
      user: user,
      requirePasswordChange: requirePw,
    );
  }
}

@JsonSerializable()
class MessageResponse {
  final String message;
  MessageResponse({required this.message});
  factory MessageResponse.fromJson(Map<String, dynamic> json) =>
      _$MessageResponseFromJson(json);
}
