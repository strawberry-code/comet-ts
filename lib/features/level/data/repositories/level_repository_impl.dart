import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/data/datasources/level_local_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/data/models/level_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/domain/entities/level_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/domain/repositories/level_repository.dart';

class LevelRepositoryImpl implements LevelRepository {
  final LevelLocalDataSource localDataSource;

  LevelRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, LevelEntity>> createLevel(LevelEntity level) async {
    try {
      print('LevelRepositoryImpl: Creating level: ${level.name}');
      final levelModel = LevelModel.create(
        name: level.name,
        costPerHour: level.costPerHour,
      );
      final createdLevel = await localDataSource.createLevel(levelModel);
      print('LevelRepositoryImpl: Level created successfully: ${createdLevel.name}');
      return Right(createdLevel);
    } on CacheException catch (e) {
      print('LevelRepositoryImpl: CacheException during createLevel: $e');
      return Left(CacheFailure());
    } catch (e) {
      print('LevelRepositoryImpl: Unknown error during createLevel: $e');
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, LevelEntity?>> getLevel(int id) async {
    try {
      print('LevelRepositoryImpl: Getting level with ID: $id');
      final level = await localDataSource.getLevel(id);
      print('LevelRepositoryImpl: Level found: ${level?.name}');
      return Right(level);
    } on CacheException catch (e) {
      print('LevelRepositoryImpl: CacheException during getLevel: $e');
      return Left(CacheFailure());
    } catch (e) {
      print('LevelRepositoryImpl: Unknown error during getLevel: $e');
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<LevelEntity>>> getAllLevels() async {
    try {
      print('LevelRepositoryImpl: Getting all levels');
      final levels = await localDataSource.getAllLevels();
      print('LevelRepositoryImpl: Found ${levels.length} levels');
      return Right(levels);
    } on CacheException catch (e) {
      print('LevelRepositoryImpl: CacheException during getAllLevels: $e');
      return Left(CacheFailure());
    } catch (e) {
      print('LevelRepositoryImpl: Unknown error during getAllLevels: $e');
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateLevel(LevelEntity level) async {
    try {
      print('LevelRepositoryImpl: Updating level: ${level.name}');
      final levelModel = LevelModel(
        id: level.id,
        name: level.name,
        costPerHour: level.costPerHour,
      );
      await localDataSource.updateLevel(levelModel);
      print('LevelRepositoryImpl: Level updated successfully: ${level.name}');
      return const Right(null);
    } on CacheException catch (e) {
      print('LevelRepositoryImpl: CacheException during updateLevel: $e');
      return Left(CacheFailure());
    } catch (e) {
      print('LevelRepositoryImpl: Unknown error during updateLevel: $e');
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteLevel(int id) async {
    try {
      print('LevelRepositoryImpl: Deleting level with ID: $id');
      await localDataSource.deleteLevel(id);
      print('LevelRepositoryImpl: Level with ID $id deleted successfully');
      return const Right(null);
    } on CacheException catch (e) {
      print('LevelRepositoryImpl: CacheException during deleteLevel: $e');
      return Left(CacheFailure());
    } catch (e) {
      print('LevelRepositoryImpl: Unknown error during deleteLevel: $e');
      return Left(ServerFailure());
    }
  }
}
