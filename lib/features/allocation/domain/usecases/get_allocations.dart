import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/allocation_entity.dart';
import '../repositories/allocation_repository.dart';

class GetAllocations implements UseCase<List<AllocationEntity>, NoParams> {
  final AllocationRepository repository;

  GetAllocations(this.repository);

  @override
  Future<Either<Failure, List<AllocationEntity>>> call(NoParams params) {
    return repository.getAllocations();
  }
}

class GetAllocationsByProject implements UseCase<List<AllocationEntity>, GetAllocationsByProjectParams> {
  final AllocationRepository repository;

  GetAllocationsByProject(this.repository);

  @override
  Future<Either<Failure, List<AllocationEntity>>> call(GetAllocationsByProjectParams params) {
    return repository.getAllocationsByProject(params.projectId);
  }
}

class GetAllocationsByEmployee implements UseCase<List<AllocationEntity>, GetAllocationsByEmployeeParams> {
  final AllocationRepository repository;

  GetAllocationsByEmployee(this.repository);

  @override
  Future<Either<Failure, List<AllocationEntity>>> call(GetAllocationsByEmployeeParams params) {
    return repository.getAllocationsByEmployee(params.employeeId);
  }
}

class GetAllocationsByDateRange implements UseCase<List<AllocationEntity>, GetAllocationsByDateRangeParams> {
  final AllocationRepository repository;

  GetAllocationsByDateRange(this.repository);

  @override
  Future<Either<Failure, List<AllocationEntity>>> call(GetAllocationsByDateRangeParams params) {
    return repository.getAllocationsByDateRange(params.startDate, params.endDate);
  }
}

class GetAllocationsByProjectParams {
  final int projectId;
  GetAllocationsByProjectParams({required this.projectId});
}

class GetAllocationsByEmployeeParams {
  final int employeeId;
  GetAllocationsByEmployeeParams({required this.employeeId});
}

class GetAllocationsByDateRangeParams {
  final DateTime startDate;
  final DateTime endDate;
  GetAllocationsByDateRangeParams({required this.startDate, required this.endDate});
}