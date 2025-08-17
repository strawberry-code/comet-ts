import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/domain/entities/employee_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/domain/repositories/employee_repository.dart';

class UpdateEmployee implements UseCase<void, UpdateEmployeeParams> {
  final EmployeeRepository repository;

  UpdateEmployee(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateEmployeeParams params) async {
    return await repository.updateEmployee(params.employee);
  }
}

class UpdateEmployeeParams extends Equatable {
  final EmployeeEntity employee;

  const UpdateEmployeeParams({required this.employee});

  @override
  List<Object> get props => [employee];
}
