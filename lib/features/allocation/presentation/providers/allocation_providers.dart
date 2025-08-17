import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/allocation_local_data_source.dart';
import '../../data/repositories/allocation_repository_impl.dart';
import '../../domain/repositories/allocation_repository.dart';
import '../../domain/usecases/create_allocation.dart';
import '../../domain/usecases/get_allocations.dart';
import '../../domain/usecases/update_allocation.dart';
import '../../domain/usecases/delete_allocation.dart';
import '../../domain/usecases/validate_allocation.dart';
import '../../../employee/presentation/providers/employee_providers.dart';
import '../../../project/presentation/providers/project_providers.dart';
import '../../../../core/providers/database_provider.dart';
import 'allocation_notifier.dart';

// Data Source Provider
final allocationLocalDataSourceProvider = Provider<AllocationLocalDataSource>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return AllocationLocalDataSourceImpl(database: database);
});

// Repository Provider
final allocationRepositoryProvider = Provider<AllocationRepository>((ref) {
  final localDataSource = ref.watch(allocationLocalDataSourceProvider);
  final employeeDataSource = ref.watch(employeeLocalDataSourceProvider);
  final projectDataSource = ref.watch(projectLocalDataSourceProvider);
  
  return AllocationRepositoryImpl(
    localDataSource: localDataSource,
    employeeDataSource: employeeDataSource,
    projectDataSource: projectDataSource,
  );
});

// Use Cases Providers
final createAllocationProvider = Provider<CreateAllocation>((ref) {
  final repository = ref.watch(allocationRepositoryProvider);
  return CreateAllocation(repository);
});

final getAllocationsProvider = Provider<GetAllocations>((ref) {
  final repository = ref.watch(allocationRepositoryProvider);
  return GetAllocations(repository);
});

final getAllocationsByProjectProvider = Provider<GetAllocationsByProject>((ref) {
  final repository = ref.watch(allocationRepositoryProvider);
  return GetAllocationsByProject(repository);
});

final getAllocationsByEmployeeProvider = Provider<GetAllocationsByEmployee>((ref) {
  final repository = ref.watch(allocationRepositoryProvider);
  return GetAllocationsByEmployee(repository);
});

final getAllocationsByDateRangeProvider = Provider<GetAllocationsByDateRange>((ref) {
  final repository = ref.watch(allocationRepositoryProvider);
  return GetAllocationsByDateRange(repository);
});

final updateAllocationProvider = Provider<UpdateAllocation>((ref) {
  final repository = ref.watch(allocationRepositoryProvider);
  return UpdateAllocation(repository);
});

final deleteAllocationProvider = Provider<DeleteAllocation>((ref) {
  final repository = ref.watch(allocationRepositoryProvider);
  return DeleteAllocation(repository);
});

final validateAllocationProvider = Provider<ValidateAllocation>((ref) {
  final repository = ref.watch(allocationRepositoryProvider);
  return ValidateAllocation(repository);
});

final getProjectRemainingBudgetProvider = Provider<GetProjectRemainingBudget>((ref) {
  final repository = ref.watch(allocationRepositoryProvider);
  return GetProjectRemainingBudget(repository);
});

final getMaxAllocatableHoursProvider = Provider<GetMaxAllocatableHours>((ref) {
  final repository = ref.watch(allocationRepositoryProvider);
  return GetMaxAllocatableHours(repository);
});

// Notifier Provider
final allocationProvider = StateNotifierProvider<AllocationNotifier, AllocationState>((ref) {
  final createAllocation = ref.watch(createAllocationProvider);
  final getAllocations = ref.watch(getAllocationsProvider);
  final getAllocationsByProject = ref.watch(getAllocationsByProjectProvider);
  final getAllocationsByEmployee = ref.watch(getAllocationsByEmployeeProvider);
  final getAllocationsByDateRange = ref.watch(getAllocationsByDateRangeProvider);
  final updateAllocation = ref.watch(updateAllocationProvider);
  final deleteAllocation = ref.watch(deleteAllocationProvider);
  final validateAllocation = ref.watch(validateAllocationProvider);
  final getProjectRemainingBudget = ref.watch(getProjectRemainingBudgetProvider);
  final getMaxAllocatableHours = ref.watch(getMaxAllocatableHoursProvider);

  return AllocationNotifier(
    createAllocation: createAllocation,
    getAllocations: getAllocations,
    getAllocationsByProject: getAllocationsByProject,
    getAllocationsByEmployee: getAllocationsByEmployee,
    getAllocationsByDateRange: getAllocationsByDateRange,
    updateAllocation: updateAllocation,
    deleteAllocation: deleteAllocation,
    validateAllocation: validateAllocation,
    getProjectRemainingBudget: getProjectRemainingBudget,
    getMaxAllocatableHours: getMaxAllocatableHours,
  );
});

// Specific providers for UI
final todayAllocationsProvider = FutureProvider((ref) async {
  final notifier = ref.watch(allocationProvider.notifier);
  final today = DateTime.now();
  final startOfDay = DateTime(today.year, today.month, today.day);
  final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
  
  await notifier.loadAllocationsByDateRange(startOfDay, endOfDay);
  return ref.watch(allocationProvider).allocations;
});

final weekAllocationsProvider = FutureProvider((ref) async {
  final notifier = ref.watch(allocationProvider.notifier);
  final today = DateTime.now();
  final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
  final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
  
  await notifier.loadAllocationsByDateRange(startOfWeek, endOfWeek);
  return ref.watch(allocationProvider).allocations;
});

final projectBudgetProvider = FutureProvider.family<int?, int>((ref, projectId) async {
  final notifier = ref.watch(allocationProvider.notifier);
  return await notifier.getProjectBudgetRemaining(projectId);
});

final maxAllocatableHoursProvider = FutureProvider.family<int?, Map<String, int>>((ref, params) async {
  final notifier = ref.watch(allocationProvider.notifier);
  return await notifier.getMaxAllocableHours(params['projectId']!, params['employeeId']!);
});