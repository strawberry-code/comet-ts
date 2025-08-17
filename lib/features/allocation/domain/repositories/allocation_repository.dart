import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/allocation_entity.dart';
import '../entities/allocation_validation_result.dart';

abstract class AllocationRepository {
  Future<Either<Failure, List<AllocationEntity>>> getAllocations();
  Future<Either<Failure, List<AllocationEntity>>> getAllocationsByProject(int projectId);
  Future<Either<Failure, List<AllocationEntity>>> getAllocationsByEmployee(int employeeId);
  Future<Either<Failure, List<AllocationEntity>>> getAllocationsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<Either<Failure, AllocationEntity>> getAllocation(int id);
  Future<Either<Failure, AllocationEntity>> createAllocation(AllocationEntity allocation);
  Future<Either<Failure, AllocationEntity>> updateAllocation(AllocationEntity allocation);
  Future<Either<Failure, void>> deleteAllocation(int id);
  
  // Budget validation methods
  Future<Either<Failure, AllocationValidationResult>> validateAllocation({
    required int projectId,
    required int employeeId,
    required int hours, // in minutes
    required DateTime date,
    int? excludeAllocationId, // for updates
  });
  
  Future<Either<Failure, int>> getProjectRemainingBudget(int projectId);
  Future<Either<Failure, int>> getMaxAllocatableHours(int projectId, int employeeId);
  Future<Either<Failure, int>> getEmployeeDailyAllocatedHours(int employeeId, DateTime date);
}