import 'package:swp_app/features/auth/data/models/login_credentials.dart';
import '../../data/models/auth_payloads.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<String, AuthResponse>> register(RegisterRequest body);
  Future<Either<String, AuthResponse>> login(LoginRequest body);
  Future<Either<String, AuthResponse>> loginGoogle(GoogleLoginRequest body);
  Future<Either<String, String>> changePassword(ChangePasswordRequest body);
  Future<Either<String, String>> forgotPassword(ForgotPasswordRequest body);
  Future<Either<String, String>> resetPassword(ResetPasswordRequest body);
  Future<Either<String, UserModel>> getUserById(String userId);
}
