import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/project/data/datasources/project_local_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/project/data/models/project_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/project/domain/entities/project_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/project/domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectLocalDataSource localDataSource;

  ProjectRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, ProjectEntity>> createProject(ProjectEntity project) async {
    try {
      print('ProjectRepositoryImpl: Creating project: ${project.name}');
      final projectModel = ProjectModel.create(
        name: project.name,
        budget: project.budget,
        startDate: project.startDate,
        endDate: project.endDate,
      );
      final createdProject = await localDataSource.createProject(projectModel);
      print('ProjectRepositoryImpl: Project created successfully: ${createdProject.name}');
      return Right(createdProject);
    } on CacheException catch (e) {
      print('ProjectRepositoryImpl: CacheException during createProject: $e');
      return Left(CacheFailure());
    } catch (e) {
      print('ProjectRepositoryImpl: Unknown error during createProject: $e');
      return Left(ServerFailure()); // Or a more specific failure
    }
  }

  @override
  Future<Either<Failure, ProjectEntity?>> getProject(int id) async {
    try {
      print('ProjectRepositoryImpl: Getting project with ID: $id');
      final project = await localDataSource.getProject(id);
      print('ProjectRepositoryImpl: Project found: ${project?.name}');
      return Right(project);
    } on CacheException catch (e) {
      print('ProjectRepositoryImpl: CacheException during getProject: $e');
      return Left(CacheFailure());
    } catch (e) {
      print('ProjectRepositoryImpl: Unknown error during getProject: $e');
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<ProjectEntity>>> getAllProjects() async {
    try {
      print('ProjectRepositoryImpl: Getting all projects');
      final projects = await localDataSource.getAllProjects();
      print('ProjectRepositoryImpl: Found ${projects.length} projects');
      return Right(projects);
    } on CacheException catch (e) {
      print('ProjectRepositoryImpl: CacheException during getAllProjects: $e');
      return Left(CacheFailure());
    } catch (e) {
      print('ProjectRepositoryImpl: Unknown error during getAllProjects: $e');
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateProject(ProjectEntity project) async {
    try {
      print('ProjectRepositoryImpl: Updating project: ${project.name}');
      final projectModel = ProjectModel(
        id: project.id,
        name: project.name,
        budget: project.budget, // Updated
        startDate: project.startDate, // New
        endDate: project.endDate, // New
      );
      await localDataSource.updateProject(projectModel);
      print('ProjectRepositoryImpl: Project updated successfully: ${project.name}');
      return const Right(null);
    } on CacheException catch (e) {
      print('ProjectRepositoryImpl: CacheException during updateProject: $e');
      return Left(CacheFailure());
    } catch (e) {
      print('ProjectRepositoryImpl: Unknown error during updateProject: $e');
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteProject(int id) async {
    try {
      print('ProjectRepositoryImpl: Deleting project with ID: $id');
      await localDataSource.deleteProject(id);
      print('ProjectRepositoryImpl: Project with ID $id deleted successfully');
      return const Right(null);
    } on CacheException catch (e) {
      print('ProjectRepositoryImpl: CacheException during deleteProject: $e');
      return Left(CacheFailure());
    } catch (e) {
      print('ProjectRepositoryImpl: Unknown error during deleteProject: $e');
      return Left(ServerFailure());
    }
  }
}
