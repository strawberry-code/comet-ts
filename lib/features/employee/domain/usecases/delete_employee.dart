import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/domain/repositories/employee_repository.dart';

class DeleteEmployee implements UseCase<void, DeleteEmployeeParams> {
  final EmployeeRepository repository;

  DeleteEmployee(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteEmployeeParams params) async {
    return await repository.deleteEmployee(params.id);
  }
}

class DeleteEmployeeParams extends Equatable {
  final int id;

  const DeleteEmployeeParams({required this.id});

  @override
  List<Object> get props => [id];
}
