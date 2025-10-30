import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_profile.dart';

part 'user_profile_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.firstname,
    required super.lastname,
    required super.email,
    super.phoneNumber,
    super.sex,
    super.address,
    super.dateOfBirth,
    super.avatarUrl,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      _$UserProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileModelToJson(this);

  factory UserProfileModel.fromApi(Map<String, dynamic> json) {
    final core = (json['data'] is Map<String, dynamic>) ? json['data'] : json;
    return UserProfileModel.fromJson(Map<String, dynamic>.from(core));
  }

  UserProfileModel copyWith({
    String? firstname,
    String? lastname,
    String? email,
    String? phoneNumber,
    String? sex,
    String? address,
    String? dateOfBirth,
    String? avatarUrl,
  }) {
    return UserProfileModel(
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      sex: sex ?? this.sex,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
