import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/app_database.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/data/models/level_model.dart';

abstract class LevelLocalDataSource {
  Future<LevelModel> createLevel(LevelModel level);
  Future<LevelModel?> getLevel(int id);
  Future<List<LevelModel>> getAllLevels();
  Future<void> updateLevel(LevelModel level);
  Future<void> deleteLevel(int id);
}

class LevelLocalDataSourceImpl implements LevelLocalDataSource {
  final AppDatabase appDatabase;

  LevelLocalDataSourceImpl({required this.appDatabase});

  @override
  Future<LevelModel> createLevel(LevelModel level) async {
    try {
      print('LevelLocalDataSourceImpl: Creating level: ${level.name}');
      final id = await appDatabase.into(appDatabase.levels).insert(level.toDrift());
      final createdLevel = level.copyWith(id: id) as LevelModel;
      print('LevelLocalDataSourceImpl: Level created with ID: $id');
      return createdLevel;
    } catch (e) {
      print('LevelLocalDataSourceImpl: Error creating level: $e');
      throw CacheException();
    }
  }

  @override
  Future<LevelModel?> getLevel(int id) async {
    try {
      print('LevelLocalDataSourceImpl: Getting level with ID: $id');
      final query = appDatabase.select(appDatabase.levels)..where((tbl) => tbl.id.equals(id));
      final level = await query.getSingleOrNull();
      print('LevelLocalDataSourceImpl: Level found: ${level?.name}');
      return level != null ? LevelModel.fromDrift(level) : null;
    } catch (e) {
      print('LevelLocalDataSourceImpl: Error getting level: $e');
      throw CacheException();
    }
  }

  @override
  Future<List<LevelModel>> getAllLevels() async {
    try {
      print('LevelLocalDataSourceImpl: Getting all levels');
      final levels = await appDatabase.select(appDatabase.levels).get();
      final levelModels = levels.map((level) => LevelModel.fromDrift(level)).toList();
      print('LevelLocalDataSourceImpl: Found ${levelModels.length} levels');
      return levelModels;
    } catch (e) {
      print('LevelLocalDataSourceImpl: Error getting all levels: $e');
      throw CacheException();
    }
  }

  @override
  Future<void> updateLevel(LevelModel level) async {
    try {
      print('LevelLocalDataSourceImpl: Updating level: ${level.name}');
      await appDatabase.update(appDatabase.levels).replace(level.toDrift());
      print('LevelLocalDataSourceImpl: Level updated: ${level.name}');
    } catch (e) {
      print('LevelLocalDataSourceImpl: Error updating level: $e');
      throw CacheException();
    }
  }

  @override
  Future<void> deleteLevel(int id) async {
    try {
      print('LevelLocalDataSourceImpl: Deleting level with ID: $id');
      final query = appDatabase.delete(appDatabase.levels)..where((tbl) => tbl.id.equals(id));
      await query.go();
      print('LevelLocalDataSourceImpl: Level with ID $id deleted');
    } catch (e) {
      print('LevelLocalDataSourceImpl: Error deleting level: $e');
      throw CacheException();
    }
  }
}
