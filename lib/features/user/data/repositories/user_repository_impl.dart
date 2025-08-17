
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/data/datasources/user_local_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/entities/user_entity.dart'; // Using auth user entity
import 'package:flutter_riverpod_clean_architecture/features/user/domain/repositories/user_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/data/models/user_model.dart';


class UserRepositoryImpl implements UserRepository {
  final UserLocalDataSource localDataSource;

  UserRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, UserEntity>> createUser(UserEntity user) async {
    try {
      final userModel = UserModel(
        id: 0, // id is ignored on creation
        username: user.username,
        passwordHash: user.passwordHash,
        pinHash: user.pinHash,
        biometricsEnabled: user.biometricsEnabled,
      );
      final createdUser = await localDataSource.createUser(userModel);
      return Right(createdUser);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getUser(int id) async {
    try {
      final user = await localDataSource.getUser(id);
      return Right(user);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateUser(UserEntity user) async {
    try {
      final userModel = UserModel(id: user.id, username: user.username);
      await localDataSource.updateUser(userModel);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(int id) async {
    try {
      await localDataSource.deleteUser(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getUserByUsername(String username) async {
    try {
      final user = await localDataSource.getUserByUsername(username);
      return Right(user);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteAllUsers() async {
    try {
      await localDataSource.deleteAllUsers();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}
