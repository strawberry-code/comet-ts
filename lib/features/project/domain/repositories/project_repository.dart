import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/project/domain/entities/project_entity.dart';

abstract class ProjectRepository {
  Future<Either<Failure, ProjectEntity>> createProject(ProjectEntity project);
  Future<Either<Failure, ProjectEntity?>> getProject(int id);
  Future<Either<Failure, List<ProjectEntity>>> getAllProjects();
  Future<Either<Failure, void>> updateProject(ProjectEntity project);
  Future<Either<Failure, void>> deleteProject(int id);
}
