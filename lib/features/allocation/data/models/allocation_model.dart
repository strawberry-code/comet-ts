import 'package:drift/drift.dart';
import '../../../../core/storage/app_database.dart';
import '../../domain/entities/allocation_entity.dart';

class AllocationModel extends AllocationEntity {
  const AllocationModel({
    super.id,
    required super.projectId,
    required super.employeeId,
    required super.date,
    required super.hours,
  });

  factory AllocationModel.fromEntity(AllocationEntity entity) {
    return AllocationModel(
      id: entity.id,
      projectId: entity.projectId,
      employeeId: entity.employeeId,
      date: entity.date,
      hours: entity.hours,
    );
  }

  factory AllocationModel.fromDrift(Allocation allocation) {
    return AllocationModel(
      id: allocation.id,
      projectId: allocation.projectId,
      employeeId: allocation.employeeId,
      date: allocation.date,
      hours: allocation.hours,
    );
  }

  AllocationsCompanion toDrift() {
    return AllocationsCompanion(
      id: id != null ? Value(id!) : const Value.absent(),
      projectId: Value(projectId),
      employeeId: Value(employeeId),
      date: Value(date),
      hours: Value(hours),
    );
  }

  factory AllocationModel.create({
    required int projectId,
    required int employeeId,
    required DateTime date,
    required double hoursDecimal,
  }) {
    return AllocationModel(
      projectId: projectId,
      employeeId: employeeId,
      date: date,
      hours: (hoursDecimal * 60).round(), // Convert to minutes
    );
  }

  AllocationModel copyWith({
    int? id,
    int? projectId,
    int? employeeId,
    DateTime? date,
    int? hours,
  }) {
    return AllocationModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      hours: hours ?? this.hours,
    );
  }
}