import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/domain/repositories/level_repository.dart';

class DeleteLevel implements UseCase<void, DeleteLevelParams> {
  final LevelRepository repository;

  DeleteLevel(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteLevelParams params) async {
    return await repository.deleteLevel(params.id);
  }
}

class DeleteLevelParams extends Equatable {
  final int id;

  const DeleteLevelParams({required this.id});

  @override
  List<Object> get props => [id];
}
