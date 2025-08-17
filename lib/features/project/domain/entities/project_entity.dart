import 'package:equatable/equatable.dart';

class ProjectEntity extends Equatable {
  final int id;
  final String name;
  final int budget; // Renamed from budgetHours
  final int startDate; // New field for Unix timestamp
  final int endDate; // New field for Unix timestamp

  const ProjectEntity({
    required this.id,
    required this.name,
    required this.budget,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        budget,
        startDate,
        endDate,
      ];

  ProjectEntity copyWith({
    int? id,
    String? name,
    int? budget,
    int? startDate,
    int? endDate,
  }) {
    return ProjectEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      budget: budget ?? this.budget,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
