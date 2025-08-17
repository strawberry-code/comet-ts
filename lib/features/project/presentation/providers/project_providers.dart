import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/app_database.dart'; // Keep this for AppDatabase class
import 'package:flutter_riverpod_clean_architecture/core/providers/database_provider.dart'; // New import for appDatabaseProvider
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_riverpod_clean_architecture/features/project/data/datasources/project_local_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/project/data/repositories/project_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/project/domain/entities/project_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/project/domain/repositories/project_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/project/domain/usecases/create_project.dart';
import 'package:flutter_riverpod_clean_architecture/features/project/domain/usecases/delete_project.dart';
import 'package:flutter_riverpod_clean_architecture/features/project/domain/usecases/get_all_projects.dart';
import 'package:flutter_riverpod_clean_architecture/features/project/domain/usecases/get_project.dart';
import 'package:flutter_riverpod_clean_architecture/features/project/domain/usecases/update_project.dart';

// Data Source Provider
final projectLocalDataSourceProvider = Provider<ProjectLocalDataSource>((ref) {
  final appDatabase = ref.watch(appDatabaseProvider);
  return ProjectLocalDataSourceImpl(appDatabase: appDatabase);
});

// Repository Provider
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final localDataSource = ref.watch(projectLocalDataSourceProvider);
  return ProjectRepositoryImpl(localDataSource: localDataSource);
});

// Use Case Providers
final createProjectUseCaseProvider = Provider<CreateProject>((ref) {
  final repository = ref.watch(projectRepositoryProvider);
  return CreateProject(repository);
});

final getProjectUseCaseProvider = Provider<GetProject>((ref) {
  final repository = ref.watch(projectRepositoryProvider);
  return GetProject(repository);
});

final getAllProjectsUseCaseProvider = Provider<GetAllProjects>((ref) {
  final repository = ref.watch(projectRepositoryProvider);
  return GetAllProjects(repository);
});

final updateProjectUseCaseProvider = Provider<UpdateProject>((ref) {
  final repository = ref.watch(projectRepositoryProvider);
  return UpdateProject(repository);
});

final deleteProjectUseCaseProvider = Provider<DeleteProject>((ref) {
  final repository = ref.watch(projectRepositoryProvider);
  return DeleteProject(repository);
});



// Projects List Provider
final projectsListProvider = FutureProvider.autoDispose<List<ProjectEntity>>((ref) async {
  final getAllProjects = ref.watch(getAllProjectsUseCaseProvider);
  return (await getAllProjects(NoParams())).fold(
    (failure) => throw failure,
    (projects) => projects,
  );
});