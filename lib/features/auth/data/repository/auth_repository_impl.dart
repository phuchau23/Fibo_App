import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:swp_app/core/constants/api.constants.dart';
import 'package:swp_app/features/auth/data/models/login_credentials.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_payloads.dart';

// Khi khởi tạo Dio (ApiClient)

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  AuthRepositoryImpl(this._remote);

  //logg

  // @override
  // Future<Either<String, AuthResponse>> login(LoginRequest body) async {
  //   try {
  //     final res = await _remote.login(body);
  //     return right(res);
  //   } on DioException catch (e) {
  //     final data = e.response?.data;
  //     if (data is Map && data['message'] is String) {
  //       return left(data['message'] as String);
  //     }
  //     if (data is String && data.isNotEmpty) return left(data);
  //     if (e.response?.statusCode == 415) {
  //       return left('Content-Type không đúng, cần multipart/form-data.');
  //     }
  //     if (e.response?.statusCode == 401) {
  //       return left('Sai email hoặc mật khẩu.');
  //     }
  //     return left(e.message ?? 'Network error');
  //   } catch (e) {
  //     return left(e.toString());
  //   }
  // }

  @override
  Future<Either<String, AuthResponse>> login(LoginRequest body) async {
    try {
      print('🟢 [LOGIN REQUEST]');
      print('Email: ${body.email}');
      print('Password: ${body.password}');

      // Gọi API
      final res = await _remote.login(body);

      // In ra toàn bộ response từ server
      print('🟣 [LOGIN RESPONSE]');
      print('Status: ${res}');
      return right(res);
    } on DioException catch (e) {
      // In chi tiết lỗi và data mà request gửi
      print('🔴 [LOGIN ERROR]');
      print('URL: ${e.requestOptions.uri}');
      print('Headers: ${e.requestOptions.headers}');
      print('Data Sent: ${e.requestOptions.data}');
      print('Status: ${e.response?.statusCode}');
      print('Response: ${e.response?.data}');

      final data = e.response?.data;
      if (data is Map && data['message'] is String) {
        return left(data['message'] as String);
      }
      if (data is String && data.isNotEmpty) return left(data);
      if (e.response?.statusCode == 415) {
        return left('Content-Type không đúng, cần multipart/form-data.');
      }
      if (e.response?.statusCode == 401) {
        return left('Sai email hoặc mật khẩu.');
      }
      return left(e.message ?? 'Network error');
    } catch (e) {
      print('⚠️ [UNEXPECTED ERROR] $e');
      return left(e.toString());
    }
  }

  @override
  Future<Either<String, AuthResponse>> register(RegisterRequest body) async {
    try {
      final r = await _remote.register(body);
      return Right(r);
    } on DioException catch (e) {
      return Left(_message(e));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, AuthResponse>> loginGoogle(
    GoogleLoginRequest body,
  ) async {
    try {
      final r = await _remote.loginGoogle(body);
      return Right(r);
    } on DioException catch (e) {
      return Left(_message(e));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, String>> changePassword(
    ChangePasswordRequest body,
  ) async {
    try {
      final r = await _remote.changePassword(body);
      return Right(r.message);
    } on DioException catch (e) {
      return Left(_message(e));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, String>> forgotPassword(
    ForgotPasswordRequest body,
  ) async {
    try {
      final r = await _remote.forgotPassword(body);
      return Right(r.message);
    } on DioException catch (e) {
      return Left(_message(e));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, String>> resetPassword(
    ResetPasswordRequest body,
  ) async {
    try {
      final r = await _remote.resetPassword(body);
      return Right(r.message);
    } on DioException catch (e) {
      return Left(_message(e));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, UserModel>> getUserById(String userId) async {
    try {
      final r = await _remote.getUserById(userId);
      return Right(r);
    } on DioException catch (e) {
      return Left(_message(e));
    } catch (e) {
      return Left(e.toString());
    }
  }

  String _message(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String)
      return data['message'] as String;
    return e.message ?? 'Network error';
  }
}
