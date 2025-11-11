import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:swp_app/core/error/app_failure.dart';
import 'package:swp_app/data/services/api_client.dart';
import 'package:swp_app/features/profile/data/repository/profile_repository_impl.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

// ========== DATA WIRING ==========
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref));

final remoteDsProvider = Provider<ProfileRemoteDataSource>(
  (ref) => ProfileRemoteDataSource(ref.read(apiClientProvider)),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(ref.read(remoteDsProvider)),
);

// ========== STATES / NOTIFIERS ==========
class ProfileNotifier extends AsyncNotifier<UserProfile> {
  @override
  Future<UserProfile> build() async {
    final repo = ref.read(profileRepositoryProvider);
    final Either<Failure, UserProfile> r = await repo.getProfile();
    return r.fold((Failure l) => throw l, (data) => data);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => await build());
  }
}

final profileNotifierProvider =
    AsyncNotifierProvider<ProfileNotifier, UserProfile>(ProfileNotifier.new);

class UpdateProfileController extends AutoDisposeAsyncNotifier<bool> {
  @override
  Future<bool> build() async => false;

  Future<bool> submit({
    required String firstname,
    required String lastname,
    String? phoneNumber,
    String? dateOfBirth, // yyyy-MM-dd
    String? sex,
    String? address,
  }) async {
    try {
      state = const AsyncLoading();
      final repo = ref.read(profileRepositoryProvider);

      final result = await repo.updateProfile(
        firstname: firstname,
        lastname: lastname,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        sex: sex,
        address: address,
      );

      return result.fold(
        (failure) {
          state = AsyncError(failure, StackTrace.current);
          return false;
        },
        (success) async {
          // Refresh profile data after successful update
          await ref.read(profileNotifierProvider.notifier).refresh();
          state = const AsyncData(true);
          return true;
        },
      );
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      return false;
    }
  }
}

final updateProfileControllerProvider =
    AutoDisposeAsyncNotifierProvider<UpdateProfileController, bool>(
      UpdateProfileController.new,
    );

class ChangePasswordController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> submit({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    final repo = ref.read(profileRepositoryProvider);
    state = const AsyncLoading();

    final Either<Failure, Unit> r = await repo.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword,
    );

    r.fold(
      (Failure l) => state = AsyncError(l, StackTrace.current),
      (_) => state = const AsyncData(null),
    );
  }
}

final changePasswordControllerProvider =
    AutoDisposeAsyncNotifierProvider<ChangePasswordController, void>(
      ChangePasswordController.new,
    );
