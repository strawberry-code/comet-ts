import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/allocation_entity.dart';
import '../../domain/entities/allocation_validation_result.dart';
import '../../domain/usecases/create_allocation.dart';
import '../../domain/usecases/get_allocations.dart';
import '../../domain/usecases/update_allocation.dart';
import '../../domain/usecases/delete_allocation.dart';
import '../../domain/usecases/validate_allocation.dart';

class AllocationState {
  final List<AllocationEntity> allocations;
  final bool isLoading;
  final String? errorMessage;
  final AllocationValidationResult? lastValidation;

  AllocationState({
    this.allocations = const [],
    this.isLoading = false,
    this.errorMessage,
    this.lastValidation,
  });

  AllocationState copyWith({
    List<AllocationEntity>? allocations,
    bool? isLoading,
    String? errorMessage,
    AllocationValidationResult? lastValidation,
  }) {
    return AllocationState(
      allocations: allocations ?? this.allocations,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      lastValidation: lastValidation ?? this.lastValidation,
    );
  }
}

class AllocationNotifier extends StateNotifier<AllocationState> {
  final CreateAllocation createAllocation;
  final GetAllocations getAllocations;
  final GetAllocationsByProject getAllocationsByProject;
  final GetAllocationsByEmployee getAllocationsByEmployee;
  final GetAllocationsByDateRange getAllocationsByDateRange;
  final UpdateAllocation updateAllocation;
  final DeleteAllocation deleteAllocation;
  final ValidateAllocation validateAllocation;
  final GetProjectRemainingBudget getProjectRemainingBudget;
  final GetMaxAllocatableHours getMaxAllocatableHours;

  AllocationNotifier({
    required this.createAllocation,
    required this.getAllocations,
    required this.getAllocationsByProject,
    required this.getAllocationsByEmployee,
    required this.getAllocationsByDateRange,
    required this.updateAllocation,
    required this.deleteAllocation,
    required this.validateAllocation,
    required this.getProjectRemainingBudget,
    required this.getMaxAllocatableHours,
  }) : super(AllocationState());

  Future<void> loadAllAllocations() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await getAllocations(NoParams());

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (allocations) => state = state.copyWith(
        isLoading: false,
        allocations: allocations,
        errorMessage: null,
      ),
    );
  }

  Future<void> loadAllocationsByProject(int projectId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await getAllocationsByProject(GetAllocationsByProjectParams(projectId: projectId));

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (allocations) => state = state.copyWith(
        isLoading: false,
        allocations: allocations,
        errorMessage: null,
      ),
    );
  }

  Future<void> loadAllocationsByEmployee(int employeeId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await getAllocationsByEmployee(GetAllocationsByEmployeeParams(employeeId: employeeId));

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (allocations) => state = state.copyWith(
        isLoading: false,
        allocations: allocations,
        errorMessage: null,
      ),
    );
  }

  Future<void> loadAllocationsByDateRange(DateTime startDate, DateTime endDate) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await getAllocationsByDateRange(GetAllocationsByDateRangeParams(
      startDate: startDate,
      endDate: endDate,
    ));

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (allocations) => state = state.copyWith(
        isLoading: false,
        allocations: allocations,
        errorMessage: null,
      ),
    );
  }

  Future<bool> createNewAllocation(AllocationEntity allocation) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await createAllocation(CreateAllocationParams(allocation: allocation));

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (createdAllocation) {
        final updatedAllocations = [...state.allocations, createdAllocation];
        state = state.copyWith(
          isLoading: false,
          allocations: updatedAllocations,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  Future<bool> updateExistingAllocation(AllocationEntity allocation) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await updateAllocation(UpdateAllocationParams(allocation: allocation));

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (updatedAllocation) {
        final updatedAllocations = state.allocations.map((a) {
          return a.id == updatedAllocation.id ? updatedAllocation : a;
        }).toList();
        state = state.copyWith(
          isLoading: false,
          allocations: updatedAllocations,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  Future<bool> deleteExistingAllocation(int id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await deleteAllocation(DeleteAllocationParams(id: id));

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        final updatedAllocations = state.allocations.where((a) => a.id != id).toList();
        state = state.copyWith(
          isLoading: false,
          allocations: updatedAllocations,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  Future<AllocationValidationResult?> validateAllocationData({
    required int projectId,
    required int employeeId,
    required int hours,
    required DateTime date,
    int? excludeAllocationId,
  }) async {
    final result = await validateAllocation(ValidateAllocationParams(
      projectId: projectId,
      employeeId: employeeId,
      hours: hours,
      date: date,
      excludeAllocationId: excludeAllocationId,
    ));

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return null;
      },
      (validation) {
        state = state.copyWith(lastValidation: validation);
        return validation;
      },
    );
  }

  Future<int?> getProjectBudgetRemaining(int projectId) async {
    final result = await getProjectRemainingBudget(GetProjectRemainingBudgetParams(projectId: projectId));

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return null;
      },
      (budget) => budget,
    );
  }

  Future<int?> getMaxAllocableHours(int projectId, int employeeId) async {
    final result = await getMaxAllocatableHours(GetMaxAllocatableHoursParams(
      projectId: projectId,
      employeeId: employeeId,
    ));

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return null;
      },
      (hours) => hours,
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}