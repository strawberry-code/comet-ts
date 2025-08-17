import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/allocation_repository.dart';

class DeleteAllocation implements UseCase<void, DeleteAllocationParams> {
  final AllocationRepository repository;

  DeleteAllocation(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteAllocationParams params) {
    return repository.deleteAllocation(params.id);
  }
}

class DeleteAllocationParams {
  final int id;

  DeleteAllocationParams({required this.id});
}