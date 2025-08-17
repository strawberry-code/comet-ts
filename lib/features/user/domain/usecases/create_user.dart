
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/domain/repositories/user_repository.dart';

class CreateUser implements UseCase<UserEntity, CreateUserParams> {
  final UserRepository repository;

  CreateUser(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(CreateUserParams params) async {
    return await repository.createUser(params.user);
  }
}

class CreateUserParams extends Equatable {
  final UserEntity user;

  const CreateUserParams({required this.user});

  @override
  List<Object> get props => [user];
}
