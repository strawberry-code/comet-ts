import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/app_database.dart';
import 'package:flutter_riverpod_clean_architecture/features/project/data/models/project_model.dart';

abstract class ProjectLocalDataSource {
  Future<ProjectModel> createProject(ProjectModel project);
  Future<ProjectModel?> getProject(int id);
  Future<List<ProjectModel>> getAllProjects();
  Future<void> updateProject(ProjectModel project);
  Future<void> deleteProject(int id);
}

class ProjectLocalDataSourceImpl implements ProjectLocalDataSource {
  final AppDatabase appDatabase;

  ProjectLocalDataSourceImpl({required this.appDatabase});

  @override
  Future<ProjectModel> createProject(ProjectModel project) async {
    try {
      print('ProjectLocalDataSourceImpl: Creating project: ${project.name}');
      final id = await appDatabase.into(appDatabase.projects).insert(project.toDrift());
      final createdProject = project.copyWith(id: id) as ProjectModel;
      print('ProjectLocalDataSourceImpl: Project created with ID: $id');
      return createdProject;
    } catch (e) {
      print('ProjectLocalDataSourceImpl: Error creating project: $e');
      throw CacheException();
    }
  }

  @override
  Future<ProjectModel?> getProject(int id) async {
    try {
      print('ProjectLocalDataSourceImpl: Getting project with ID: $id');
      final query = appDatabase.select(appDatabase.projects)..where((tbl) => tbl.id.equals(id));
      final project = await query.getSingleOrNull();
      print('ProjectLocalDataSourceImpl: Project found: ${project?.name}');
      return project != null ? ProjectModel.fromDrift(project) : null;
    } catch (e) {
      print('ProjectLocalDataSourceImpl: Error getting project: $e');
      throw CacheException();
    }
  }

  @override
  Future<List<ProjectModel>> getAllProjects() async {
    try {
      print('ProjectLocalDataSourceImpl: Getting all projects');
      final projects = await appDatabase.select(appDatabase.projects).get();
      final projectModels = projects.map((project) => ProjectModel.fromDrift(project)).toList();
      print('ProjectLocalDataSourceImpl: Found ${projectModels.length} projects');
      return projectModels;
    } catch (e) {
      print('ProjectLocalDataSourceImpl: Error getting all projects: $e');
      throw CacheException();
    }
  }

  @override
  Future<void> updateProject(ProjectModel project) async {
    try {
      print('ProjectLocalDataSourceImpl: Updating project: ${project.name}');
      await appDatabase.update(appDatabase.projects).replace(project.toDrift());
      print('ProjectLocalDataSourceImpl: Project updated: ${project.name}');
    } catch (e) {
      print('ProjectLocalDataSourceImpl: Error updating project: $e');
      throw CacheException();
    }
  }

  @override
  Future<void> deleteProject(int id) async {
    try {
      print('ProjectLocalDataSourceImpl: Deleting project with ID: $id');
      final query = appDatabase.delete(appDatabase.projects)..where((tbl) => tbl.id.equals(id));
      await query.go();
      print('ProjectLocalDataSourceImpl: Project with ID $id deleted');
    } catch (e) {
      print('ProjectLocalDataSourceImpl: Error deleting project: $e');
      throw CacheException();
    }
  }
}
