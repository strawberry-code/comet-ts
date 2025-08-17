import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/database_provider.dart';
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/data/datasources/user_local_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/data/repositories/user_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/domain/repositories/user_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/domain/usecases/update_user.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/domain/usecases/delete_all_users.dart';

// Data Source Provider
final userLocalDataSourceProvider = Provider<UserLocalDataSource>((ref) {
  final appDatabase = ref.watch(appDatabaseProvider);
  return UserLocalDataSourceImpl(appDatabase: appDatabase);
});

// Repository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final localDataSource = ref.watch(userLocalDataSourceProvider);
  return UserRepositoryImpl(localDataSource: localDataSource);
});

// Use Case Providers
final updateUserUseCaseProvider = Provider<UpdateUser>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UpdateUser(repository);
});

final deleteAllUsersUseCaseProvider = Provider<DeleteAllUsers>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return DeleteAllUsers(repository);
});
