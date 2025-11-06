// Following project rules:
class TopicDetailEntity {
  final String id;
  final String name;
  final String? description;
  final String status;
  final DateTime createdAt;
  final MasterTopicEntity? masterTopic;

  const TopicDetailEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.createdAt,
    this.masterTopic,
  });
}

class MasterTopicEntity {
  final String id;
  final String name;
  final String? description;
  final String status;
  final DateTime createdAt;
  final DomainEntity? domain;
  final SemesterEntity? semester;

  const MasterTopicEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.createdAt,
    this.domain,
    this.semester,
  });
}

class DomainEntity {
  final String id;
  final String name;
  final String? description;
  final String status;
  final DateTime createdAt;

  const DomainEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.createdAt,
  });
}

class SemesterEntity {
  final String id;
  final String code;
  final String term;
  final int? year;
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;

  const SemesterEntity({
    required this.id,
    required this.code,
    required this.term,
    this.year,
    this.status,
    this.startDate,
    this.endDate,
    this.createdAt,
  });
}
