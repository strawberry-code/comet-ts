import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/domain/entities/employee_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/domain/repositories/employee_repository.dart';

class GetAllEmployees implements UseCase<List<EmployeeEntity>, NoParams> {
  final EmployeeRepository repository;

  GetAllEmployees(this.repository);

  @override
  Future<Either<Failure, List<EmployeeEntity>>> call(NoParams params) async {
    return await repository.getAllEmployees();
  }
}
