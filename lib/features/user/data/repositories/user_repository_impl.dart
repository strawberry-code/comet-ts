import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/data/datasources/user_local_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/data/models/user_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserLocalDataSource localDataSource;

  UserRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, UserEntity>> createUser(UserEntity user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      final createdUser = await localDataSource.createUser(userModel);
      return Right(createdUser);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getUser(int id) async {
    try {
      final user = await localDataSource.getUser(id);
      return Right(user);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getUserByUsername(String username) async {
    try {
      final user = await localDataSource.getUserByUsername(username);
      return Right(user);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateUser(UserEntity user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      await localDataSource.updateUser(userModel);
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(int id) async {
    try {
      await localDataSource.deleteUser(id);
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteAllUsers() async {
    try {
      await localDataSource.deleteAllUsers();
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}