import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/allocation_validation_result.dart';
import '../repositories/allocation_repository.dart';

class ValidateAllocation implements UseCase<AllocationValidationResult, ValidateAllocationParams> {
  final AllocationRepository repository;

  ValidateAllocation(this.repository);

  @override
  Future<Either<Failure, AllocationValidationResult>> call(ValidateAllocationParams params) {
    return repository.validateAllocation(
      projectId: params.projectId,
      employeeId: params.employeeId,
      hours: params.hours,
      date: params.date,
      excludeAllocationId: params.excludeAllocationId,
    );
  }
}

class GetProjectRemainingBudget implements UseCase<int, GetProjectRemainingBudgetParams> {
  final AllocationRepository repository;

  GetProjectRemainingBudget(this.repository);

  @override
  Future<Either<Failure, int>> call(GetProjectRemainingBudgetParams params) {
    return repository.getProjectRemainingBudget(params.projectId);
  }
}

class GetMaxAllocatableHours implements UseCase<int, GetMaxAllocatableHoursParams> {
  final AllocationRepository repository;

  GetMaxAllocatableHours(this.repository);

  @override
  Future<Either<Failure, int>> call(GetMaxAllocatableHoursParams params) {
    return repository.getMaxAllocatableHours(params.projectId, params.employeeId);
  }
}

class ValidateAllocationParams {
  final int projectId;
  final int employeeId;
  final int hours; // in minutes
  final DateTime date;
  final int? excludeAllocationId;

  ValidateAllocationParams({
    required this.projectId,
    required this.employeeId,
    required this.hours,
    required this.date,
    this.excludeAllocationId,
  });
}

class GetProjectRemainingBudgetParams {
  final int projectId;
  GetProjectRemainingBudgetParams({required this.projectId});
}

class GetMaxAllocatableHoursParams {
  final int projectId;
  final int employeeId;
  GetMaxAllocatableHoursParams({required this.projectId, required this.employeeId});
}