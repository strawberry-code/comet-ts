import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/allocation_entity.dart';
import '../../domain/entities/allocation_validation_result.dart';
import '../../domain/repositories/allocation_repository.dart';
import '../datasources/allocation_local_data_source.dart';
import '../models/allocation_model.dart';
import '../../../employee/data/datasources/employee_local_data_source.dart';
import '../../../project/data/datasources/project_local_data_source.dart';

class AllocationRepositoryImpl implements AllocationRepository {
  final AllocationLocalDataSource localDataSource;
  final EmployeeLocalDataSource employeeDataSource;
  final ProjectLocalDataSource projectDataSource;

  AllocationRepositoryImpl({
    required this.localDataSource,
    required this.employeeDataSource,
    required this.projectDataSource,
  });

  @override
  Future<Either<Failure, List<AllocationEntity>>> getAllocations() async {
    try {
      final allocations = await localDataSource.getAllocations();
      return Right(allocations);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get allocations: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<AllocationEntity>>> getAllocationsByProject(int projectId) async {
    try {
      final allocations = await localDataSource.getAllocationsByProject(projectId);
      return Right(allocations);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get allocations by project: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<AllocationEntity>>> getAllocationsByEmployee(int employeeId) async {
    try {
      final allocations = await localDataSource.getAllocationsByEmployee(employeeId);
      return Right(allocations);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get allocations by employee: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<AllocationEntity>>> getAllocationsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final allocations = await localDataSource.getAllocationsByDateRange(startDate, endDate);
      return Right(allocations);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get allocations by date range: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AllocationEntity>> getAllocation(int id) async {
    try {
      final allocation = await localDataSource.getAllocation(id);
      return Right(allocation);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get allocation: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AllocationEntity>> createAllocation(AllocationEntity allocation) async {
    try {
      final allocationModel = AllocationModel.fromEntity(allocation);
      final createdAllocation = await localDataSource.createAllocation(allocationModel);
      return Right(createdAllocation);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to create allocation: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AllocationEntity>> updateAllocation(AllocationEntity allocation) async {
    try {
      final allocationModel = AllocationModel.fromEntity(allocation);
      final updatedAllocation = await localDataSource.updateAllocation(allocationModel);
      return Right(updatedAllocation);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to update allocation: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAllocation(int id) async {
    try {
      await localDataSource.deleteAllocation(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to delete allocation: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AllocationValidationResult>> validateAllocation({
    required int projectId,
    required int employeeId,
    required int hours,
    required DateTime date,
    int? excludeAllocationId,
  }) async {
    try {
      // Check if project exists
      try {
        await projectDataSource.getProject(projectId);
      } catch (e) {
        return const Right(AllocationValidationResult.invalid(
          errorMessage: 'Project not found',
          failureType: ValidationFailureType.projectNotFound,
        ));
      }

      // Check if employee exists and get their level
      late final employee;
      try {
        employee = await employeeDataSource.getEmployee(employeeId);
      } catch (e) {
        return const Right(AllocationValidationResult.invalid(
          errorMessage: 'Employee not found',
          failureType: ValidationFailureType.employeeNotFound,
        ));
      }

      // Validate input
      if (hours <= 0) {
        return const Right(AllocationValidationResult.invalid(
          errorMessage: 'Hours must be greater than 0',
          failureType: ValidationFailureType.invalidInput,
        ));
      }

      // Check daily limit (8 hours = 480 minutes)
      final currentDailyHours = await localDataSource.getEmployeeDailyAllocatedHours(employeeId, date);
      final totalDailyHours = currentDailyHours + hours;
      
      if (excludeAllocationId != null) {
        // If updating, subtract the existing allocation hours
        try {
          final existingAllocation = await localDataSource.getAllocation(excludeAllocationId);
          final existingDate = DateTime(existingAllocation.date.year, existingAllocation.date.month, existingAllocation.date.day);
          final targetDate = DateTime(date.year, date.month, date.day);
          
          if (existingDate.isAtSameMomentAs(targetDate)) {
            final adjustedDailyHours = totalDailyHours - existingAllocation.hours;
            if (adjustedDailyHours > 480) { // 8 hours in minutes
              return Right(AllocationValidationResult.invalid(
                errorMessage: 'Daily allocation limit exceeded (8 hours maximum)',
                maxAvailableHours: 480 - (currentDailyHours - existingAllocation.hours),
                failureType: ValidationFailureType.dailyLimit,
              ));
            }
          }
        } catch (e) {
          // If we can't find the existing allocation, proceed with normal validation
        }
      } else {
        if (totalDailyHours > 480) { // 8 hours in minutes
          return Right(AllocationValidationResult.invalid(
            errorMessage: 'Daily allocation limit exceeded (8 hours maximum)',
            maxAvailableHours: 480 - currentDailyHours,
            failureType: ValidationFailureType.dailyLimit,
          ));
        }
      }

      // Check budget constraint
      final remainingBudget = await localDataSource.getProjectRemainingBudget(projectId);
      final employeeWithLevel = await employeeDataSource.getEmployeeWithLevel(employeeId);
      final requiredBudget = (hours * employeeWithLevel['costPerHour']) ~/ 60; // Convert from minutes to hours

      if (excludeAllocationId != null) {
        // If updating, add back the existing allocation cost
        try {
          final existingAllocation = await localDataSource.getAllocation(excludeAllocationId);
          final existingEmployee = await employeeDataSource.getEmployeeWithLevel(existingAllocation.employeeId);
          final existingCost = (existingAllocation.hours * existingEmployee['costPerHour']) ~/ 60;
          final adjustedBudget = remainingBudget + existingCost;
          
          if (requiredBudget > adjustedBudget) {
            final maxHours = (adjustedBudget * 60) ~/ employeeWithLevel['costPerHour']; // Convert back to minutes
            return Right(AllocationValidationResult.invalid(
              errorMessage: 'Insufficient budget for this allocation',
              maxAvailableHours: maxHours,
              requiredBudget: requiredBudget,
              availableBudget: adjustedBudget,
              failureType: ValidationFailureType.budgetExceeded,
            ));
          }
        } catch (e) {
          // If we can't find the existing allocation, proceed with normal validation
        }
      } else {
        if (requiredBudget > remainingBudget) {
          final maxHours = (remainingBudget * 60) ~/ employeeWithLevel['costPerHour']; // Convert back to minutes
          return Right(AllocationValidationResult.invalid(
            errorMessage: 'Insufficient budget for this allocation',
            maxAvailableHours: maxHours,
            requiredBudget: requiredBudget,
            availableBudget: remainingBudget,
            failureType: ValidationFailureType.budgetExceeded,
          ));
        }
      }

      return const Right(AllocationValidationResult.valid());
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to validate allocation: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getProjectRemainingBudget(int projectId) async {
    try {
      final remainingBudget = await localDataSource.getProjectRemainingBudget(projectId);
      return Right(remainingBudget);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get project remaining budget: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getMaxAllocatableHours(int projectId, int employeeId) async {
    try {
      final remainingBudget = await localDataSource.getProjectRemainingBudget(projectId);
      final employeeWithLevel = await employeeDataSource.getEmployeeWithLevel(employeeId);
      final costPerHour = employeeWithLevel['costPerHour'] as int;
      
      if (costPerHour == 0) {
        return const Right(480); // 8 hours in minutes if cost is 0
      }
      
      final maxHours = (remainingBudget * 60) ~/ costPerHour; // Convert back to minutes
      return Right(maxHours.clamp(0, 480)); // Max 8 hours per day
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get max allocatable hours: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getEmployeeDailyAllocatedHours(int employeeId, DateTime date) async {
    try {
      final hours = await localDataSource.getEmployeeDailyAllocatedHours(employeeId, date);
      return Right(hours);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get employee daily allocated hours: ${e.toString()}'));
    }
  }
}