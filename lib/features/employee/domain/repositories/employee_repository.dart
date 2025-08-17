import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/domain/entities/employee_entity.dart';

abstract class EmployeeRepository {
  Future<Either<Failure, EmployeeEntity>> createEmployee(EmployeeEntity employee);
  Future<Either<Failure, EmployeeEntity?>> getEmployee(int id);
  Future<Either<Failure, List<EmployeeEntity>>> getAllEmployees();
  Future<Either<Failure, void>> updateEmployee(EmployeeEntity employee);
  Future<Either<Failure, void>> deleteEmployee(int id);
}
