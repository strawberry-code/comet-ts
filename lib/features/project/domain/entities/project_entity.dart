import 'package:equatable/equatable.dart';

class ProjectEntity extends Equatable {
  final int id;
  final String name;
  final int budgetHours;

  const ProjectEntity({
    required this.id,
    required this.name,
    required this.budgetHours,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        budgetHours,
      ];

  ProjectEntity copyWith({
    int? id,
    String? name,
    int? budgetHours,
  }) {
    return ProjectEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      budgetHours: budgetHours ?? this.budgetHours,
    );
  }
}
