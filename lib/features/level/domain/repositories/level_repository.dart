import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/domain/entities/level_entity.dart';

abstract class LevelRepository {
  Future<Either<Failure, LevelEntity>> createLevel(LevelEntity level);
  Future<Either<Failure, LevelEntity?>> getLevel(int id);
  Future<Either<Failure, List<LevelEntity>>> getAllLevels();
  Future<Either<Failure, void>> updateLevel(LevelEntity level);
  Future<Either<Failure, void>> deleteLevel(int id);
}
