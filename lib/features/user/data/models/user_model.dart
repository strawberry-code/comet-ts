import 'package:drift/drift.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/app_database.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/entities/user_entity.dart';

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

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      username: entity.username,
      passwordHash: entity.passwordHash,
      pinHash: entity.pinHash,
      biometricsEnabled: entity.biometricsEnabled,
    );
  }

  // For JSON serialization (if needed for API calls)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      passwordHash: json['passwordHash'] as String?,
      pinHash: json['pinHash'] as String?,
      biometricsEnabled: json['biometricsEnabled'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'passwordHash': passwordHash,
      'pinHash': pinHash,
      'biometricsEnabled': biometricsEnabled,
    };
  }

  @override
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