import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/data/datasources/employee_local_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/data/models/employee_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/domain/entities/employee_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/domain/repositories/employee_repository.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeLocalDataSource localDataSource;

  EmployeeRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, EmployeeEntity>> createEmployee(EmployeeEntity employee) async {
    try {
      print('EmployeeRepositoryImpl: Creating employee: ${employee.name}');
      final employeeModel = EmployeeModel.create(
        name: employee.name,
        levelId: employee.levelId,
      );
      final createdEmployee = await localDataSource.createEmployee(employeeModel);
      print('EmployeeRepositoryImpl: Employee created successfully: ${createdEmployee.name}');
      return Right(createdEmployee);
    } on CacheException catch (e) {
      print('EmployeeRepositoryImpl: CacheException during createEmployee: $e');
      return Left(CacheFailure());
    } catch (e) {
      print('EmployeeRepositoryImpl: Unknown error during createEmployee: $e');
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, EmployeeEntity?>> getEmployee(int id) async {
    try {
      print('EmployeeRepositoryImpl: Getting employee with ID: $id');
      final employee = await localDataSource.getEmployee(id);
      print('EmployeeRepositoryImpl: Employee found: ${employee?.name}');
      return Right(employee);
    } on CacheException catch (e) {
      print('EmployeeRepositoryImpl: CacheException during getEmployee: $e');
      return Left(CacheFailure());
    } catch (e) {
      print('EmployeeRepositoryImpl: Unknown error during getEmployee: $e');
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<EmployeeEntity>>> getAllEmployees() async {
    try {
      print('EmployeeRepositoryImpl: Getting all employees');
      final employees = await localDataSource.getAllEmployees();
      print('EmployeeRepositoryImpl: Found ${employees.length} employees');
      return Right(employees);
    } on CacheException catch (e) {
      print('EmployeeRepositoryImpl: CacheException during getAllEmployees: $e');
      return Left(CacheFailure());
    } catch (e) {
      print('EmployeeRepositoryImpl: Unknown error during getAllEmployees: $e');
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateEmployee(EmployeeEntity employee) async {
    try {
      print('EmployeeRepositoryImpl: Updating employee: ${employee.name}');
      final employeeModel = EmployeeModel(
        id: employee.id,
        name: employee.name,
        levelId: employee.levelId,
      );
      await localDataSource.updateEmployee(employeeModel);
      print('EmployeeRepositoryImpl: Employee updated successfully: ${employee.name}');
      return const Right(null);
    } on CacheException catch (e) {
      print('EmployeeRepositoryImpl: CacheException during updateEmployee: $e');
      return Left(CacheFailure());
    } catch (e) {
      print('EmployeeRepositoryImpl: Unknown error during updateEmployee: $e');
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteEmployee(int id) async {
    try {
      print('EmployeeRepositoryImpl: Deleting employee with ID: $id');
      await localDataSource.deleteEmployee(id);
      print('EmployeeRepositoryImpl: Employee with ID $id deleted successfully');
      return const Right(null);
    } on CacheException catch (e) {
      print('EmployeeRepositoryImpl: CacheException during deleteEmployee: $e');
      return Left(CacheFailure());
    } catch (e) {
      print('EmployeeRepositoryImpl: Unknown error during deleteEmployee: $e');
      return Left(ServerFailure());
    }
  }
}
