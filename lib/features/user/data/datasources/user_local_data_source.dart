import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/app_database.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/data/models/user_model.dart';

abstract class UserLocalDataSource {
  Future<UserModel> createUser(UserModel user);
  Future<UserModel?> getUser(int id);
  Future<UserModel?> getUserByUsername(String username);
  Future<void> updateUser(UserModel user);
  Future<void> deleteUser(int id);
  Future<void> deleteAllUsers();
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final AppDatabase appDatabase;

  UserLocalDataSourceImpl({required this.appDatabase});

  @override
  Future<UserModel> createUser(UserModel user) async {
    try {
      final id = await appDatabase.into(appDatabase.users).insert(user.toDrift());
      return user.copyWith(id: id) as UserModel;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<UserModel?> getUser(int id) async {
    try {
      final user = await (appDatabase.select(appDatabase.users)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
      return user != null ? UserModel.fromDrift(user) : null;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<UserModel?> getUserByUsername(String username) async {
    try {
      final user = await (appDatabase.select(appDatabase.users)..where((tbl) => tbl.username.equals(username))).getSingleOrNull();
      return user != null ? UserModel.fromDrift(user) : null;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> updateUser(UserModel user) async {
    try {
      await appDatabase.update(appDatabase.users).replace(user.toDrift());
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> deleteUser(int id) async {
    try {
      await (appDatabase.delete(appDatabase.users)..where((tbl) => tbl.id.equals(id))).go();
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> deleteAllUsers() async {
    try {
      await appDatabase.delete(appDatabase.users).go();
    } catch (e) {
      throw CacheException();
    }
  }
}