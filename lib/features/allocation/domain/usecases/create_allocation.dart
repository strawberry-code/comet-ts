import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/allocation_entity.dart';
import '../repositories/allocation_repository.dart';

class CreateAllocation implements UseCase<AllocationEntity, CreateAllocationParams> {
  final AllocationRepository repository;

  CreateAllocation(this.repository);

  @override
  Future<Either<Failure, AllocationEntity>> call(CreateAllocationParams params) async {
    // First validate the allocation
    final validationResult = await repository.validateAllocation(
      projectId: params.allocation.projectId,
      employeeId: params.allocation.employeeId,
      hours: params.allocation.hours,
      date: params.allocation.date,
    );

    return validationResult.fold(
      (failure) => Left(failure),
      (validation) {
        if (!validation.isValid) {
          return Left(ValidationFailure(message: validation.errorMessage ?? 'Invalid allocation'));
        }
        return repository.createAllocation(params.allocation);
      },
    );
  }
}

class CreateAllocationParams {
  final AllocationEntity allocation;

  CreateAllocationParams({required this.allocation});
}