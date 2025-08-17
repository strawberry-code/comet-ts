import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String username;
  final String? passwordHash;
  final String? pinHash;
  final bool biometricsEnabled;

  const UserEntity({
    required this.id,
    required this.username,
    this.passwordHash,
    this.pinHash,
    this.biometricsEnabled = false,
  });

  @override
  List<Object?> get props => [
        id,
        username,
        passwordHash,
        pinHash,
        biometricsEnabled,
      ];

  // Factory constructor to create an empty user
  factory UserEntity.empty() {
    return const UserEntity(
      id: 0,
      username: '',
      passwordHash: null,
      pinHash: null,
      biometricsEnabled: false,
    );
  }

  // CopyWith method for creating a new instance with some updated properties
  UserEntity copyWith({
    int? id,
    String? username,
    String? passwordHash,
    String? pinHash,
    bool? biometricsEnabled,
  }) {
    return UserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      pinHash: pinHash ?? this.pinHash,
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
    );
  }

  // Method to check if user is empty
  bool get isEmpty => id == 0 && username.isEmpty;
  bool get isNotEmpty => !isEmpty;
}
