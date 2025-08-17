import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/domain/repositories/user_repository.dart';

class DeleteAllUsers implements UseCase<void, NoParams> {
  final UserRepository repository;

  DeleteAllUsers(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.deleteAllUsers();
  }
}