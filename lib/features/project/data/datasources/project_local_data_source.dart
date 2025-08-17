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
      final id = await appDatabase.into(appDatabase.projects).insert(project.toDrift());
      return project.copyWith(id: id) as ProjectModel;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<ProjectModel?> getProject(int id) async {
    try {
      final project = await appDatabase.select(appDatabase.projects)
          .where((tbl) => tbl.id.equals(id))
          .getSingleOrNull();
      return project != null ? ProjectModel.fromDrift(project) : null;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<ProjectModel>> getAllProjects() async {
    try {
      final projects = await appDatabase.select(appDatabase.projects).get();
      return projects.map((project) => ProjectModel.fromDrift(project)).toList();
    } catch (e) {
      throw CacheException();
    }
  }

      @override
  Future<void> updateProject(ProjectModel project) async {
    try {
      await appDatabase.update(appDatabase.projects).replace(project.toDrift());
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> deleteProject(int id) async {
    try {
      await appDatabase.delete(appDatabase.projects).where((tbl) => tbl.id.equals(id)).go();
    } catch (e) {
      throw CacheException();
    }
  }
}
