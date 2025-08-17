import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/domain/entities/level_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/domain/repositories/level_repository.dart';

class GetLevel implements UseCase<LevelEntity?, GetLevelParams> {
  final LevelRepository repository;

  GetLevel(this.repository);

  @override
  Future<Either<Failure, LevelEntity?>> call(GetLevelParams params) async {
    return await repository.getLevel(params.id);
  }
}

class GetLevelParams extends Equatable {
  final int id;

  const GetLevelParams({required this.id});

  @override
  List<Object> get props => [id];
}
