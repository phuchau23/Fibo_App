class UserProfile {
  final String firstname;
  final String lastname;
  final String email;
  final String? phoneNumber;
  final String? sex;
  final String? address;
  final String? dateOfBirth; // ISO yyyy-MM-dd
  final String? avatarUrl;

  const UserProfile({
    required this.firstname,
    required this.lastname,
    required this.email,
    this.phoneNumber,
    this.sex,
    this.address,
    this.dateOfBirth,
    this.avatarUrl,
  });

  String get fullName => ('$firstname $lastname').trim();
}
