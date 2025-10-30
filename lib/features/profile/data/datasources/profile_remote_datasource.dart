import 'dart:io';
import 'package:dio/dio.dart';
import 'package:swp_app/data/services/api_client.dart';
import 'package:swp_app/features/profile/data/models/user_profile_model.dart';

class ProfileRemoteDataSource {
  final ApiClient _client;
  ProfileRemoteDataSource(this._client);

  Future<UserProfileModel> getProfile() async {
    final res = await _client.get('/auth/api/users/get-user-profile');
    return UserProfileModel.fromApi(res.data);
  }

  Future<bool> updateProfile({
    required String firstname,
    required String lastname,
    required String? phoneNumber,
    required String? dateOfBirth,
    required String? sex,
    required String? address,
    File? avatarFile,
  }) async {
    final form = FormData.fromMap({
      'Firstname': firstname,
      'Lastname': lastname,
      'PhoneNumber': phoneNumber,
      'DateOfBirth': dateOfBirth,
      'Sex': sex,
      'Address': address,
      if (avatarFile != null)
        'avatarFile': await MultipartFile.fromFile(avatarFile.path),
    });

    final res = await _client.put(
      '/auth/api/users/update-profile',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    return (res.data is Map && res.data['data']?['success'] == true);
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    final form = FormData.fromMap({
      'OldPassword': oldPassword,
      'NewPassword': newPassword,
      'ConfirmNewPassword': confirmNewPassword,
    });

    await _client.put(
      '/auth/api/users/change-password',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
  }
}
