import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_riverpod_clean_architecture/features/project/domain/entities/project_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/project/domain/repositories/project_repository.dart';

class GetProject implements UseCase<ProjectEntity?, GetProjectParams> {
  final ProjectRepository repository;

  GetProject(this.repository);

  @override
  Future<Either<Failure, ProjectEntity?>> call(GetProjectParams params) async {
    return await repository.getProject(params.id);
  }
}

class GetProjectParams extends Equatable {
  final int id;

  const GetProjectParams({required this.id});

  @override
  List<Object> get props => [id];
}
