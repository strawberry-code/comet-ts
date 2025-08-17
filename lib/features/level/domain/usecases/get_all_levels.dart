import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/domain/entities/level_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/domain/repositories/level_repository.dart';

class GetAllLevels implements UseCase<List<LevelEntity>, NoParams> {
  final LevelRepository repository;

  GetAllLevels(this.repository);

  @override
  Future<Either<Failure, List<LevelEntity>>> call(NoParams params) async {
    return await repository.getAllLevels();
  }
}
