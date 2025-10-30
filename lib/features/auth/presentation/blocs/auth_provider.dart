// lib/features/auth/presentation/providers/auth_providers.dart
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:swp_app/core/constants/api.constants.dart';
import 'package:swp_app/core/services/session_provider.dart';
import 'package:swp_app/core/services/session_service.dart';

import 'package:swp_app/data/services/api_client.dart';
import 'package:swp_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:swp_app/features/auth/data/models/login_credentials.dart';
import 'package:swp_app/features/auth/data/models/auth_payloads.dart';
import 'package:swp_app/features/auth/data/repository/auth_repository_impl.dart';
import 'package:swp_app/features/auth/domain/repositories/auth_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref));

final authRemoteProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSource(ref.watch(apiClientProvider)),
);

final authRepoProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(authRemoteProvider)),
);

class AuthController extends AutoDisposeAsyncNotifier<void> {
  late final AuthRepository _repo;
  late final ApiClient _client;
  late final SessionService session;

  @override
  FutureOr<void> build() {
    _repo = ref.read(authRepoProvider);
    _client = ref.read(apiClientProvider);
    session = ref.read(sessionServiceProvider);
  }

  Future<Either<String, AuthResponse>> login(LoginRequest body) async {
    state = const AsyncLoading();
    final either = await _repo.login(body);
    state = const AsyncData(null);

    return await either.fold((err) async => Left(err), (auth) async {
      await session.saveFromToken(auth.accessToken);
      return Right(auth);
    });
  }

  Future<Either<String, AuthResponse>> register(RegisterRequest body) async {
    state = const AsyncLoading();
    final r = await _repo.register(body);
    state = const AsyncData(null);
    return r;
  }

  Future<Either<String, String>> changePassword(
    String oldPwd,
    String newPwd,
  ) async {
    state = const AsyncLoading();
    final r = await _repo.changePassword(
      ChangePasswordRequest(oldPassword: oldPwd, newPassword: newPwd),
    );
    state = const AsyncData(null);
    return r;
  }

  Future<Either<String, String>> forgotPassword(String email) async {
    state = const AsyncLoading();
    final r = await _repo.forgotPassword(ForgotPasswordRequest(email: email));
    state = const AsyncData(null);
    return r;
  }

  Future<Either<String, String>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    state = const AsyncLoading();
    final r = await _repo.resetPassword(
      ResetPasswordRequest(email: email, otp: otp, newPassword: newPassword),
    );
    state = const AsyncData(null);
    return r;
  }

  Future<Either<String, UserModel>> getUser(String userId) async {
    state = const AsyncLoading();
    final r = await _repo.getUserById(userId);
    state = const AsyncData(null);
    return r;
  }
}

final authControllerProvider =
    AutoDisposeAsyncNotifierProvider<AuthController, void>(AuthController.new);
