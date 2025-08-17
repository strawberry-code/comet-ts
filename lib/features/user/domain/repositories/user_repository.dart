
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<Either<Failure, UserEntity>> createUser(UserEntity user);
  Future<Either<Failure, UserEntity?>> getUser(int id);
  Future<Either<Failure, void>> updateUser(UserEntity user);
  Future<Either<Failure, void>> deleteUser(int id);
  Future<Either<Failure, UserEntity?>> getUserByUsername(String username);
  Future<Either<Failure, void>> deleteAllUsers();
}
