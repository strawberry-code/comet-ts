
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/domain/repositories/user_repository.dart';

class GetUserByUsername implements UseCase<UserEntity?, GetUserByUsernameParams> {
  final UserRepository repository;

  GetUserByUsername(this.repository);

  @override
  Future<Either<Failure, UserEntity?>> call(GetUserByUsernameParams params) async {
    return await repository.getUserByUsername(params.username);
  }
}

class GetUserByUsernameParams extends Equatable {
  final String username;

  const GetUserByUsernameParams({required this.username});

  @override
  List<Object> get props => [username];
}
