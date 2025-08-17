import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_riverpod_clean_architecture/features/project/domain/entities/project_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/project/domain/repositories/project_repository.dart';

class CreateProject implements UseCase<ProjectEntity, CreateProjectParams> {
  final ProjectRepository repository;

  CreateProject(this.repository);

  @override
  Future<Either<Failure, ProjectEntity>> call(CreateProjectParams params) async {
    return await repository.createProject(params.project);
  }
}

class CreateProjectParams extends Equatable {
  final ProjectEntity project;

  const CreateProjectParams({required this.project});

  @override
  List<Object> get props => [project];
}
