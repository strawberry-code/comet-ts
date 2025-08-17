import 'package:drift/drift.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/app_database.dart';
import 'package:flutter_riverpod_clean_architecture/features/project/domain/entities/project_entity.dart';

class ProjectModel extends ProjectEntity {
  const ProjectModel({
    required int id,
    required String name,
    required int budget,
    required int startDate,
    required int endDate,
  }) : super(
          id: id,
          name: name,
          budget: budget,
          startDate: startDate,
          endDate: endDate,
        );

  // Factory constructor for creating new projects without an ID
  factory ProjectModel.create({
    required String name,
    required int budget,
    required int startDate,
    required int endDate,
  }) {
    return ProjectModel(
      id: 0, // Temporary ID, will be replaced by DB auto-increment
      name: name,
      budget: budget,
      startDate: startDate,
      endDate: endDate,
    );
  }

  factory ProjectModel.fromDrift(Project project) {
    return ProjectModel(
      id: project.id,
      name: project.name,
      budget: project.budget,
      startDate: project.startDate,
      endDate: project.endDate,
    );
  }

  ProjectsCompanion toDrift() {
    return ProjectsCompanion(
      id: Value(id),
      name: Value(name),
      budget: Value(budget), // Renamed
      startDate: Value(startDate), // New
      endDate: Value(endDate), // New
    );
  }

  // For JSON serialization (if needed for API calls)
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as int,
      name: json['name'] as String,
      budget: json['budget'] as int, // Renamed
      startDate: json['startDate'] as int, // New
      endDate: json['endDate'] as int, // New
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'budget': budget, // Renamed
      'startDate': startDate, // New
      'endDate': endDate, // New
    };
  }

  @override
  ProjectModel copyWith({
    int? id,
    String? name,
    int? budget,
    int? startDate,
    int? endDate,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      budget: budget ?? this.budget,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
