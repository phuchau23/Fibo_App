import 'package:equatable/equatable.dart';

class SemesterEntity extends Equatable {
  final String id;
  final String code;
  final String term;
  final int year;

  const SemesterEntity({
    required this.id,
    required this.code,
    required this.term,
    required this.year,
  });

  String get displayLabel => '$code • $term $year';

  @override
  List<Object?> get props => [id, code, term, year];
}
