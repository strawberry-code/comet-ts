import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/allocation_entity.dart';
import '../repositories/allocation_repository.dart';

class UpdateAllocation implements UseCase<AllocationEntity, UpdateAllocationParams> {
  final AllocationRepository repository;

  UpdateAllocation(this.repository);

  @override
  Future<Either<Failure, AllocationEntity>> call(UpdateAllocationParams params) async {
    // First validate the allocation (excluding the current allocation from validation)
    final validationResult = await repository.validateAllocation(
      projectId: params.allocation.projectId,
      employeeId: params.allocation.employeeId,
      hours: params.allocation.hours,
      date: params.allocation.date,
      excludeAllocationId: params.allocation.id,
    );

    return validationResult.fold(
      (failure) => Left(failure),
      (validation) {
        if (!validation.isValid) {
          return Left(ValidationFailure(message: validation.errorMessage ?? 'Invalid allocation'));
        }
        return repository.updateAllocation(params.allocation);
      },
    );
  }
}

class UpdateAllocationParams {
  final AllocationEntity allocation;

  UpdateAllocationParams({required this.allocation});
}