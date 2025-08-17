import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/domain/entities/employee_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/domain/repositories/employee_repository.dart';

class GetEmployee implements UseCase<EmployeeEntity?, GetEmployeeParams> {
  final EmployeeRepository repository;

  GetEmployee(this.repository);

  @override
  Future<Either<Failure, EmployeeEntity?>> call(GetEmployeeParams params) async {
    return await repository.getEmployee(params.id);
  }
}

class GetEmployeeParams extends Equatable {
  final int id;

  const GetEmployeeParams({required this.id});

  @override
  List<Object> get props => [id];
}
