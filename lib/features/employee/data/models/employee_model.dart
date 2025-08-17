import 'package:drift/drift.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/app_database.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/domain/entities/employee_entity.dart';

class EmployeeModel extends EmployeeEntity {
  const EmployeeModel({
    required int id,
    required String name,
    required int levelId,
  }) : super(
          id: id,
          name: name,
          levelId: levelId,
        );

  // Factory constructor for creating new employees without an ID
  factory EmployeeModel.create({
    required String name,
    required int levelId,
  }) {
    return EmployeeModel(
      id: 0, // Temporary ID, will be replaced by DB auto-increment
      name: name,
      levelId: levelId,
    );
  }

  factory EmployeeModel.fromDrift(Employee employee) {
    return EmployeeModel(
      id: employee.id,
      name: employee.name,
      levelId: employee.levelId,
    );
  }

  EmployeesCompanion toDrift() {
    return EmployeesCompanion(
      id: id == 0 ? const Value.absent() : Value(id),
      name: Value(name),
      levelId: Value(levelId),
    );
  }

  // For JSON serialization (if needed for API calls)
  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] as int,
      name: json['name'] as String,
      levelId: json['levelId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'levelId': levelId,
    };
  }

  @override
  EmployeeModel copyWith({
    int? id,
    String? name,
    int? levelId,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      levelId: levelId ?? this.levelId,
    );
  }
}
