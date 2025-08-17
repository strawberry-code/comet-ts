import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/domain/entities/employee_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/domain/repositories/employee_repository.dart';

class CreateEmployee implements UseCase<EmployeeEntity, CreateEmployeeParams> {
  final EmployeeRepository repository;

  CreateEmployee(this.repository);

  @override
  Future<Either<Failure, EmployeeEntity>> call(CreateEmployeeParams params) async {
    return await repository.createEmployee(params.employee);
  }
}

class CreateEmployeeParams extends Equatable {
  final EmployeeEntity employee;

  const CreateEmployeeParams({required this.employee});

  @override
  List<Object> get props => [employee];
}
