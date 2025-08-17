import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/domain/entities/level_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/domain/repositories/level_repository.dart';

class UpdateLevel implements UseCase<void, UpdateLevelParams> {
  final LevelRepository repository;

  UpdateLevel(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateLevelParams params) async {
    return await repository.updateLevel(params.level);
  }
}

class UpdateLevelParams extends Equatable {
  final LevelEntity level;

  const UpdateLevelParams({required this.level});

  @override
  List<Object> get props => [level];
}
