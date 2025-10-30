// Following project rules:
import 'package:json_annotation/json_annotation.dart';
import 'topic_model.dart';

part 'paged_topics_response.g.dart';

@JsonSerializable()
class PagedTopicsResponse {
  final int statusCode;
  final String code;
  final String message;
  final _PagedData data;

  PagedTopicsResponse({
    required this.statusCode,
    required this.code,
    required this.message,
    required this.data,
  });

  factory PagedTopicsResponse.fromJson(Map<String, dynamic> json) =>
      _$PagedTopicsResponseFromJson(json);
}

@JsonSerializable()
class _PagedData {
  final List<TopicModel> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  _PagedData({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory _PagedData.fromJson(Map<String, dynamic> json) =>
      _$PagedDataFromJson(json);
}
