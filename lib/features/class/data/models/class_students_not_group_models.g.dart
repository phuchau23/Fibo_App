// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_students_not_group_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentModel _$StudentModelFromJson(Map<String, dynamic> json) => StudentModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String,
      studentId: json['studentId'] as String,
      roleInClass: json['roleInClass'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$StudentModelToJson(StudentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'studentId': instance.studentId,
      'roleInClass': instance.roleInClass,
      'status': instance.status,
    };

LecturerMiniModel _$LecturerMiniModelFromJson(Map<String, dynamic> json) =>
    LecturerMiniModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
    );

Map<String, dynamic> _$LecturerMiniModelToJson(LecturerMiniModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
    };

ClassWithStudentsModel _$ClassWithStudentsModelFromJson(
        Map<String, dynamic> json) =>
    ClassWithStudentsModel(
      id: json['id'] as String,
      code: json['code'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      lecturer:
          LecturerMiniModel.fromJson(json['lecturer'] as Map<String, dynamic>),
      students: (json['students'] as List<dynamic>)
          .map((e) => StudentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ClassWithStudentsModelToJson(
        ClassWithStudentsModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'status': instance.status,
      'createdAt': instance.createdAt,
      'lecturer': instance.lecturer,
      'students': instance.students,
    };

ClassStudentsEnvelope _$ClassStudentsEnvelopeFromJson(
        Map<String, dynamic> json) =>
    ClassStudentsEnvelope(
      statusCode: (json['statusCode'] as num).toInt(),
      code: json['code'] as String,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map(
              (e) => ClassWithStudentsModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ClassStudentsEnvelopeToJson(
        ClassStudentsEnvelope instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
    };

ClassStudentsWithoutGroupEnvelope _$ClassStudentsWithoutGroupEnvelopeFromJson(
        Map<String, dynamic> json) =>
    ClassStudentsWithoutGroupEnvelope(
      statusCode: (json['statusCode'] as num).toInt(),
      code: json['code'] as String,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map(
              (e) => ClassWithStudentsModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ClassStudentsWithoutGroupEnvelopeToJson(
        ClassStudentsWithoutGroupEnvelope instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
    };
