import 'package:dartz/dartz.dart';
import '../../../../core/error/app_failure.dart';
import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getProfile();

  Future<Either<Failure, bool>> updateProfile({
    required String firstname,
    required String lastname,
    required String? phoneNumber,
    required String? dateOfBirth,
    required String? sex,
    required String? address,
    Uri? avatarFileUri,
  });

  Future<Either<Failure, Unit>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
  });
}
