import 'package:drift/drift.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/app_database.dart';
import 'package:flutter_riverpod_clean_architecture/features/project/domain/entities/project_entity.dart';

class ProjectModel extends ProjectEntity {
  const ProjectModel({
    required int id,
    required String name,
    required int budgetHours,
  }) : super(
          id: id,
          name: name,
          budgetHours: budgetHours,
        );

  factory ProjectModel.fromDrift(Project project) {
    return ProjectModel(
      id: project.id,
      name: project.name,
      budgetHours: project.budgetHours,
    );
  }

  ProjectsCompanion toDrift() {
    return ProjectsCompanion(
      id: Value(id),
      name: Value(name),
      budgetHours: Value(budgetHours),
    );
  }

  // For JSON serialization (if needed for API calls)
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as int,
      name: json['name'] as String,
      budgetHours: json['budgetHours'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'budgetHours': budgetHours,
    };
  }
}
