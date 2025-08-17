
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/app_database.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/data/datasources/user_local_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/data/repositories/user_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/domain/repositories/user_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/domain/usecases/create_user.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/domain/usecases/get_user.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/domain/usecases/get_user_by_username.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/domain/usecases/delete_all_users.dart';

final userLocalDataSourceProvider = Provider<UserLocalDataSource>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return UserLocalDataSourceImpl(appDatabase: database);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final localDataSource = ref.watch(userLocalDataSourceProvider);
  return UserRepositoryImpl(localDataSource: localDataSource);
});

final createUserProvider = Provider<CreateUser>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return CreateUser(repository);
});

final getUserProvider = Provider<GetUser>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return GetUser(repository);
});

final getUserByUsernameProvider = Provider<GetUserByUsername>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return GetUserByUsername(repository);
});

final deleteAllUsersProvider = Provider<DeleteAllUsers>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return DeleteAllUsers(repository);
});

// This provider is defined here, but it should be moved to a more general location
final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase());
