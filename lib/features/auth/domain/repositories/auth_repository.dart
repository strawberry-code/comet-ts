import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  /// Login a user with username and password
  Future<Either<Failure, UserEntity>> login({
    required String username, 
    required String password,
  });
  
  /// Register a new user
  Future<Either<Failure, UserEntity>> register({
    required String username,
    required String password,
  });
  
  /// Logout the current user
  Future<Either<Failure, void>> logout();
}
