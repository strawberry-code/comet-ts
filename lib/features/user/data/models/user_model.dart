
import 'package:drift/drift.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/app_database.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/entities/user_entity.dart'; // Using auth user entity

class UserModel extends UserEntity {
  const UserModel({
    required int id,
    required String username,
    String? passwordHash,
    String? pinHash,
    bool biometricsEnabled = false,
  }) : super(
          id: id,
          username: username,
          passwordHash: passwordHash,
          pinHash: pinHash,
          biometricsEnabled: biometricsEnabled,
        );

  factory UserModel.fromDrift(User user) {
    return UserModel(
      id: user.id,
      username: user.username,
      passwordHash: user.passwordHash,
      pinHash: user.pinHash,
      biometricsEnabled: user.biometricsEnabled,
    );
  }

  UsersCompanion toDrift() {
    return UsersCompanion(
      id: Value(id),
      username: Value(username),
      passwordHash: Value(passwordHash),
      pinHash: Value(pinHash),
      biometricsEnabled: Value(biometricsEnabled),
    );
  }

  UserModel copyWith({
    int? id,
    String? username,
    String? passwordHash,
    String? pinHash,
    bool? biometricsEnabled,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      pinHash: pinHash ?? this.pinHash,
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
    );
  }
}
