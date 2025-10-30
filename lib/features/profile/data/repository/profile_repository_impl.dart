import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:swp_app/core/error/app_failure.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remote;
  ProfileRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, UserProfile>> getProfile() async {
    try {
      final data = await remote.getProfile();
      return Right(data);
    } on DioException catch (e) {
      return Left(
        Failure.server(
          message: e.message ?? 'HTTP error',
          statusCode: e.response?.statusCode,
          cause: e,
        ),
      );
    } catch (e) {
      return Left(Failure.unexpected(e));
    }
  }

  @override
  Future<Either<Failure, bool>> updateProfile({
    required String firstname,
    required String lastname,
    required String? phoneNumber,
    required String? dateOfBirth,
    required String? sex,
    required String? address,
    Uri? avatarFileUri,
  }) async {
    try {
      File? file;
      if (avatarFileUri != null && avatarFileUri.isScheme('file')) {
        file = File.fromUri(avatarFileUri);
      }
      final ok = await remote.updateProfile(
        firstname: firstname,
        lastname: lastname,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        sex: sex,
        address: address,
        avatarFile: file,
      );
      return Right(ok);
    } on DioException catch (e) {
      return Left(
        Failure.server(
          message: e.message ?? 'HTTP error',
          statusCode: e.response?.statusCode,
          cause: e,
        ),
      );
    } catch (e) {
      return Left(Failure.unexpected(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      await remote.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
      );
      return const Right(unit);
    } on DioException catch (e) {
      return Left(
        Failure.server(
          message: e.message ?? 'HTTP error',
          statusCode: e.response?.statusCode,
          cause: e,
        ),
      );
    } catch (e) {
      return Left(Failure.unexpected(e));
    }
  }
}
