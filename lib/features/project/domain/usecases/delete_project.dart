import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_riverpod_clean_architecture/features/project/domain/repositories/project_repository.dart';

class DeleteProject implements UseCase<void, DeleteProjectParams> {
  final ProjectRepository repository;

  DeleteProject(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteProjectParams params) async {
    return await repository.deleteProject(params.id);
  }
}

class DeleteProjectParams extends Equatable {
  final int id;

  const DeleteProjectParams({required this.id});

  @override
  List<Object> get props => [id];
}
