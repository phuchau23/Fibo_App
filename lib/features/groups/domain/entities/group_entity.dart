class GroupEntity {
  final String id;
  final String classId;
  final String name;
  final String? description;
  final DateTime createdAt;

  const GroupEntity({
    required this.id,
    required this.classId,
    required this.name,
    required this.description,
    required this.createdAt,
  });
}
