/// Giữ nguyên tên field theo đúng “form” bạn đang dùng
class AuthUser {
  final String Firstname;
  final String LastName;
  final String Email;
  final String? PhoneNumber;
  final String? StudentID;

  const AuthUser({
    required this.Firstname,
    required this.LastName,
    required this.Email,
    this.PhoneNumber,
    this.StudentID,
  });

  /// Parser "linh hoạt" từ JSON của API:
  /// - hỗ trợ nhiều biến thể key: firstName/firstname/FirstName, v.v.
  /// - PhoneNumber: phone/phoneNumber/PhoneNumber/phone_number
  /// - StudentID: studentId/StudentID/student_id
  factory AuthUser.fromJson(Map<String, dynamic> json) {
    String _s(List<String> keys, {String fallback = ''}) {
      for (final k in keys) {
        final v = json[k];
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
      return fallback;
    }

    String? _sOpt(List<String> keys) {
      for (final k in keys) {
        final v = json[k];
        if (v == null) continue;
        if (v is String && v.trim().isNotEmpty) return v.trim();
        // nếu backend trả số cho StudentID/phone, vẫn chuyển sang string
        if (v is num) return v.toString();
      }
      return null;
    }

    return AuthUser(
      Firstname: _s(['Firstname', 'FirstName', 'firstName', 'firstname']),
      LastName: _s(['LastName', 'lastName', 'lastname', 'surName', 'surname']),
      Email: _s(['Email', 'email', 'mail']),
      PhoneNumber: _sOpt([
        'PhoneNumber',
        'phoneNumber',
        'phone_number',
        'phone',
        'mobile',
      ]),
      StudentID: _sOpt([
        'StudentID',
        'studentId',
        'student_id',
        'uid',
        'userCode',
      ]),
    );
  }

  Map<String, dynamic> toJson() => {
    'Firstname': Firstname,
    'LastName': LastName,
    'Email': Email,
    if (PhoneNumber != null) 'PhoneNumber': PhoneNumber,
    if (StudentID != null) 'StudentID': StudentID,
  };

  AuthUser copyWith({
    String? Firstname,
    String? LastName,
    String? Email,
    String? PhoneNumber,
    String? StudentID,
  }) {
    return AuthUser(
      Firstname: Firstname ?? this.Firstname,
      LastName: LastName ?? this.LastName,
      Email: Email ?? this.Email,
      PhoneNumber: PhoneNumber ?? this.PhoneNumber,
      StudentID: StudentID ?? this.StudentID,
    );
  }
}
