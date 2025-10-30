import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/domain_entity.dart';

part 'domain_model.g.dart';

@JsonSerializable()
class DomainModel {
  final String id;
  final String name;
  final String description;
  final String status;
  final String createdAt;

  DomainModel({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  factory DomainModel.fromJson(Map<String, dynamic> json) =>
      _$DomainModelFromJson(json);

  Map<String, dynamic> toJson() => _$DomainModelToJson(this);

  DomainEntity toEntity() => DomainEntity(
    id: id,
    name: name,
    description: description,
    status: status,
    createdAt: DateTime.parse(createdAt),
  );
}

@JsonSerializable()
class DomainPageModel {
  final List<DomainModel> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  DomainPageModel({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory DomainPageModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final list = (data['items'] as List)
        .map((e) => DomainModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return DomainPageModel(
      items: list,
      totalItems: data['totalItems'] as int,
      currentPage: data['currentPage'] as int,
      totalPages: data['totalPages'] as int,
      pageSize: data['pageSize'] as int,
      hasPreviousPage: data['hasPreviousPage'] as bool,
      hasNextPage: data['hasNextPage'] as bool,
    );
  }

  DomainPage toEntity() => DomainPage(
    items: items.map((e) => e.toEntity()).toList(),
    totalItems: totalItems,
    currentPage: currentPage,
    totalPages: totalPages,
    pageSize: pageSize,
    hasPreviousPage: hasPreviousPage,
    hasNextPage: hasNextPage,
  );
}
