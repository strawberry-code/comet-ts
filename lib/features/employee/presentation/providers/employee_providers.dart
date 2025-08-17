import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/app_database.dart';
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/data/datasources/employee_local_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/data/repositories/employee_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/domain/entities/employee_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/domain/repositories/employee_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/domain/usecases/create_employee.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/domain/usecases/delete_employee.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/domain/usecases/get_all_employees.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/domain/usecases/get_employee.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/domain/usecases/update_employee.dart';

// Data Source Provider
final employeeLocalDataSourceProvider = Provider<EmployeeLocalDataSource>((ref) {
  final appDatabase = ref.watch(appDatabaseProvider);
  return EmployeeLocalDataSourceImpl(appDatabase: appDatabase);
});

// Repository Provider
final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  final localDataSource = ref.watch(employeeLocalDataSourceProvider);
  return EmployeeRepositoryImpl(localDataSource: localDataSource);
});

// Use Case Providers
final createEmployeeUseCaseProvider = Provider<CreateEmployee>((ref) {
  final repository = ref.watch(employeeRepositoryProvider);
  return CreateEmployee(repository);
});

final getEmployeeUseCaseProvider = Provider<GetEmployee>((ref) {
  final repository = ref.watch(employeeRepositoryProvider);
  return GetEmployee(repository);
});

final getAllEmployeesUseCaseProvider = Provider<GetAllEmployees>((ref) {
  final repository = ref.watch(employeeRepositoryProvider);
  return GetAllEmployees(repository);
});

final updateEmployeeUseCaseProvider = Provider<UpdateEmployee>((ref) {
  final repository = ref.watch(employeeRepositoryProvider);
  return UpdateEmployee(repository);
});

final deleteEmployeeUseCaseProvider = Provider<DeleteEmployee>((ref) {
  final repository = ref.watch(employeeRepositoryProvider);
  return DeleteEmployee(repository);
});

// Employees List Provider
final employeesListProvider = FutureProvider.autoDispose<List<EmployeeEntity>>((ref) async {
  final getAllEmployees = ref.watch(getAllEmployeesUseCaseProvider);
  return (await getAllEmployees(NoParams())).fold(
    (failure) => throw failure,
    (employees) => employees,
  );
});
