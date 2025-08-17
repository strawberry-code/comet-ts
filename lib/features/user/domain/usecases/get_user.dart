
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/domain/repositories/user_repository.dart';

class GetUser implements UseCase<UserEntity?, GetUserParams> {
  final UserRepository repository;

  GetUser(this.repository);

  @override
  Future<Either<Failure, UserEntity?>> call(GetUserParams params) async {
    return await repository.getUser(params.id);
  }
}

class GetUserParams extends Equatable {
  final int id;

  const GetUserParams({required this.id});

  @override
  List<Object> get props => [id];
}
