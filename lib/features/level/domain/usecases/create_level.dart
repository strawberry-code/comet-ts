import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/domain/entities/level_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/domain/repositories/level_repository.dart';

class CreateLevel implements UseCase<LevelEntity, CreateLevelParams> {
  final LevelRepository repository;

  CreateLevel(this.repository);

  @override
  Future<Either<Failure, LevelEntity>> call(CreateLevelParams params) async {
    return await repository.createLevel(params.level);
  }
}

class CreateLevelParams extends Equatable {
  final LevelEntity level;

  const CreateLevelParams({required this.level});

  @override
  List<Object> get props => [level];
}
