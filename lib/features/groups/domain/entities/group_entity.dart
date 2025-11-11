import 'package:equatable/equatable.dart';

class GroupEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String status;
  final DateTime createdAt;
  final GroupClassEntity classInfo;
  final GroupTopicEntity? topic;

  const GroupEntity({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    required this.createdAt,
    required this.classInfo,
    this.topic,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        status,
        createdAt,
        classInfo,
        topic,
      ];
}

class GroupClassEntity extends Equatable {
  final String id;
  final String code;
  final String status;
  final DateTime createdAt;
  final GroupLecturerEntity lecturer;
  final GroupSemesterEntity semester;

  const GroupClassEntity({
    required this.id,
    required this.code,
    required this.status,
    required this.createdAt,
    required this.lecturer,
    required this.semester,
  });

  @override
  List<Object?> get props => [
        id,
        code,
        status,
        createdAt,
        lecturer,
        semester,
      ];
}

class GroupLecturerEntity extends Equatable {
  final String id;
  final String fullName;

  const GroupLecturerEntity({
    required this.id,
    required this.fullName,
  });

  @override
  List<Object?> get props => [id, fullName];
}

class GroupSemesterEntity extends Equatable {
  final String id;
  final String code;
  final String term;
  final int year;
  final DateTime createdAt;

  const GroupSemesterEntity({
    required this.id,
    required this.code,
    required this.term,
    required this.year,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, code, term, year, createdAt];
}

class GroupTopicEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final GroupMasterTopicEntity? masterTopic;

  const GroupTopicEntity({
    required this.id,
    required this.name,
    this.description,
    this.masterTopic,
  });

  @override
  List<Object?> get props => [id, name, description, masterTopic];
}

class GroupMasterTopicEntity extends Equatable {
  final String id;
  final String name;
  final String? description;

  const GroupMasterTopicEntity({
    required this.id,
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, description];
}
