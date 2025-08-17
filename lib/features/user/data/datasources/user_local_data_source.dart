
import 'package:flutter_riverpod_clean_architecture/core/storage/app_database.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/data/models/user_model.dart';

abstract class UserLocalDataSource {
  Future<UserModel> createUser(UserModel user);
  Future<UserModel?> getUser(int id);
  Future<void> updateUser(UserModel user);
  Future<void> deleteUser(int id);
  Future<UserModel?> getUserByUsername(String username);
  Future<void> deleteAllUsers();
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final AppDatabase database;

  UserLocalDataSourceImpl({required this.database});

  @override
  Future<UserModel> createUser(UserModel user) async {
    print('Attempting to create user: ${user.username} with passwordHash: ${user.passwordHash}');
    try {
      final id = await database.into(database.users).insert(user.toDrift());
      print('User created with ID: $id');
      return user.copyWith(id: id);
    } catch (e) {
      print('Error creating user: $e');
      rethrow; // Re-throw the exception to be caught by the repository
    }
  }

  @override
  Future<UserModel?> getUser(int id) async {
    final user = await (database.select(database.users)..where((u) => u.id.equals(id))).getSingleOrNull();
    if (user != null) {
      return UserModel.fromDrift(user);
    }
    return null;
  }

  @override
  Future<void> updateUser(UserModel user) async {
    await (database.update(database.users)..where((u) => u.id.equals(user.id))).write(user.toDrift());
  }

  @override
  Future<void> deleteUser(int id) async {
    await (database.delete(database.users)..where((u) => u.id.equals(id))).go();
  }

  @override
  Future<UserModel?> getUserByUsername(String username) async {
    print('Attempting to get user by username: $username');
    final user = await (database.select(database.users)..where((u) => u.username.equals(username))).getSingleOrNull();
    if (user != null) {
      print('User retrieved: ${user.username} with passwordHash: ${user.passwordHash}');
      return UserModel.fromDrift(user);
    }
    print('User with username $username not found.');
    return null;
  }

  @override
  Future<void> deleteAllUsers() async {
    await database.delete(database.users).go();
  }
}
