import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_riverpod_clean_architecture/features/project/domain/entities/project_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/project/domain/repositories/project_repository.dart';

class UpdateProject implements UseCase<void, UpdateProjectParams> {
  final ProjectRepository repository;

  UpdateProject(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateProjectParams params) async {
    return await repository.updateProject(params.project);
  }
}

class UpdateProjectParams extends Equatable {
  final ProjectEntity project;

  const UpdateProjectParams({required this.project});

  @override
  List<Object> get props => [project];
}
