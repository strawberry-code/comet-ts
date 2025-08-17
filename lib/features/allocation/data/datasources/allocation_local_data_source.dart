import 'package:drift/drift.dart';
import '../../../../core/storage/app_database.dart';
import '../models/allocation_model.dart';

abstract class AllocationLocalDataSource {
  Future<List<AllocationModel>> getAllocations();
  Future<List<AllocationModel>> getAllocationsByProject(int projectId);
  Future<List<AllocationModel>> getAllocationsByEmployee(int employeeId);
  Future<List<AllocationModel>> getAllocationsByDateRange(DateTime startDate, DateTime endDate);
  Future<AllocationModel> getAllocation(int id);
  Future<AllocationModel> createAllocation(AllocationModel allocation);
  Future<AllocationModel> updateAllocation(AllocationModel allocation);
  Future<void> deleteAllocation(int id);
  Future<int> getProjectRemainingBudget(int projectId);
  Future<int> getEmployeeDailyAllocatedHours(int employeeId, DateTime date);
  Future<List<Map<String, dynamic>>> getProjectAllocationsWithEmployeeLevels(int projectId);
}

class AllocationLocalDataSourceImpl implements AllocationLocalDataSource {
  final AppDatabase database;

  AllocationLocalDataSourceImpl({required this.database});

  @override
  Future<List<AllocationModel>> getAllocations() async {
    final allocations = await database.select(database.allocations).get();
    return allocations.map((allocation) => AllocationModel.fromDrift(allocation)).toList();
  }

  @override
  Future<List<AllocationModel>> getAllocationsByProject(int projectId) async {
    final allocations = await (database.select(database.allocations)
          ..where((allocation) => allocation.projectId.equals(projectId)))
        .get();
    return allocations.map((allocation) => AllocationModel.fromDrift(allocation)).toList();
  }

  @override
  Future<List<AllocationModel>> getAllocationsByEmployee(int employeeId) async {
    final allocations = await (database.select(database.allocations)
          ..where((allocation) => allocation.employeeId.equals(employeeId)))
        .get();
    return allocations.map((allocation) => AllocationModel.fromDrift(allocation)).toList();
  }

  @override
  Future<List<AllocationModel>> getAllocationsByDateRange(DateTime startDate, DateTime endDate) async {
    final startOfDay = DateTime(startDate.year, startDate.month, startDate.day);
    final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
    
    final allocations = await (database.select(database.allocations)
          ..where((allocation) => 
              allocation.date.isBetweenValues(startOfDay, endOfDay)))
        .get();
    return allocations.map((allocation) => AllocationModel.fromDrift(allocation)).toList();
  }

  @override
  Future<AllocationModel> getAllocation(int id) async {
    final allocation = await (database.select(database.allocations)
          ..where((allocation) => allocation.id.equals(id)))
        .getSingle();
    return AllocationModel.fromDrift(allocation);
  }

  @override
  Future<AllocationModel> createAllocation(AllocationModel allocation) async {
    final id = await database.into(database.allocations).insert(allocation.toDrift());
    return allocation.copyWith(id: id);
  }

  @override
  Future<AllocationModel> updateAllocation(AllocationModel allocation) async {
    await database.update(database.allocations).replace(allocation.toDrift());
    return allocation;
  }

  @override
  Future<void> deleteAllocation(int id) async {
    await (database.delete(database.allocations)
          ..where((allocation) => allocation.id.equals(id)))
        .go();
  }

  @override
  Future<int> getProjectRemainingBudget(int projectId) async {
    // Get project budget
    final project = await (database.select(database.projects)
          ..where((p) => p.id.equals(projectId)))
        .getSingle();

    // Get total spent on allocations for this project
    final allocationsWithLevels = await getProjectAllocationsWithEmployeeLevels(projectId);
    
    int totalSpent = 0;
    for (final allocation in allocationsWithLevels) {
      final hours = allocation['hours'] as int;
      final costPerHour = allocation['costPerHour'] as int;
      totalSpent += (hours * costPerHour) ~/ 60; // Convert from minutes to hours
    }

    return project.budget - totalSpent;
  }

  @override
  Future<int> getEmployeeDailyAllocatedHours(int employeeId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final result = await (database.selectOnly(database.allocations)
          ..addColumns([database.allocations.hours.sum()])
          ..where(database.allocations.employeeId.equals(employeeId) &
              database.allocations.date.isBetweenValues(startOfDay, endOfDay)))
        .getSingle();

    return result.read(database.allocations.hours.sum()) ?? 0;
  }

  @override
  Future<List<Map<String, dynamic>>> getProjectAllocationsWithEmployeeLevels(int projectId) async {
    final query = database.select(database.allocations).join([
      innerJoin(database.employees, database.employees.id.equalsExp(database.allocations.employeeId)),
      innerJoin(database.levels, database.levels.id.equalsExp(database.employees.levelId)),
    ])
      ..where(database.allocations.projectId.equals(projectId));

    final results = await query.get();
    
    return results.map((row) {
      final allocation = row.readTable(database.allocations);
      final level = row.readTable(database.levels);
      
      return {
        'id': allocation.id,
        'hours': allocation.hours,
        'costPerHour': level.costPerHour,
        'date': allocation.date,
      };
    }).toList();
  }
}