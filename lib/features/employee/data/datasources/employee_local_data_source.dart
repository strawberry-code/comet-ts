import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/app_database.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/data/models/employee_model.dart';

abstract class EmployeeLocalDataSource {
  Future<EmployeeModel> createEmployee(EmployeeModel employee);
  Future<EmployeeModel?> getEmployee(int id);
  Future<List<EmployeeModel>> getAllEmployees();
  Future<void> updateEmployee(EmployeeModel employee);
  Future<void> deleteEmployee(int id);
}

class EmployeeLocalDataSourceImpl implements EmployeeLocalDataSource {
  final AppDatabase appDatabase;

  EmployeeLocalDataSourceImpl({required this.appDatabase});

  @override
  Future<EmployeeModel> createEmployee(EmployeeModel employee) async {
    try {
      print('EmployeeLocalDataSourceImpl: Creating employee: ${employee.name}');
      final id = await appDatabase.into(appDatabase.employees).insert(employee.toDrift());
      final createdEmployee = employee.copyWith(id: id) as EmployeeModel;
      print('EmployeeLocalDataSourceImpl: Employee created with ID: $id');
      return createdEmployee;
    } catch (e) {
      print('EmployeeLocalDataSourceImpl: Error creating employee: $e');
      throw CacheException();
    }
  }

  @override
  Future<EmployeeModel?> getEmployee(int id) async {
    try {
      print('EmployeeLocalDataSourceImpl: Getting employee with ID: $id');
      final query = appDatabase.select(appDatabase.employees)..where((tbl) => tbl.id.equals(id));
      final employee = await query.getSingleOrNull();
      print('EmployeeLocalDataSourceImpl: Employee found: ${employee?.name}');
      return employee != null ? EmployeeModel.fromDrift(employee) : null;
    } catch (e) {
      print('EmployeeLocalDataSourceImpl: Error getting employee: $e');
      throw CacheException();
    }
  }

  @override
  Future<List<EmployeeModel>> getAllEmployees() async {
    try {
      print('EmployeeLocalDataSourceImpl: Getting all employees');
      final employees = await appDatabase.select(appDatabase.employees).get();
      final employeeModels = employees.map((employee) => EmployeeModel.fromDrift(employee)).toList();
      print('EmployeeLocalDataSourceImpl: Found ${employeeModels.length} employees');
      return employeeModels;
    } catch (e) {
      print('EmployeeLocalDataSourceImpl: Error getting all employees: $e');
      throw CacheException();
    }
  }

  @override
  Future<void> updateEmployee(EmployeeModel employee) async {
    try {
      print('EmployeeLocalDataSourceImpl: Updating employee: ${employee.name}');
      await appDatabase.update(appDatabase.employees).replace(employee.toDrift());
      print('EmployeeLocalDataSourceImpl: Employee updated: ${employee.name}');
    } catch (e) {
      print('EmployeeLocalDataSourceImpl: Error updating employee: $e');
      throw CacheException();
    }
  }

  @override
  Future<void> deleteEmployee(int id) async {
    try {
      print('EmployeeLocalDataSourceImpl: Deleting employee with ID: $id');
      final query = appDatabase.delete(appDatabase.employees)..where((tbl) => tbl.id.equals(id));
      await query.go();
      print('EmployeeLocalDataSourceImpl: Employee with ID $id deleted');
    } catch (e) {
      print('EmployeeLocalDataSourceImpl: Error deleting employee: $e');
      throw CacheException();
    }
  }
}
