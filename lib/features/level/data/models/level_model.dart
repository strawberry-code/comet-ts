import 'package:drift/drift.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/app_database.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/domain/entities/level_entity.dart';

class LevelModel extends LevelEntity {
  const LevelModel({
    required int id,
    required String name,
    required int costPerHour,
  }) : super(
          id: id,
          name: name,
          costPerHour: costPerHour,
        );

  // Factory constructor for creating new levels without an ID
  factory LevelModel.create({
    required String name,
    required int costPerHour,
  }) {
    return LevelModel(
      id: 0, // Temporary ID, will be replaced by DB auto-increment
      name: name,
      costPerHour: costPerHour,
    );
  }

  factory LevelModel.fromDrift(Level level) {
    return LevelModel(
      id: level.id,
      name: level.name,
      costPerHour: level.costPerHour,
    );
  }

  LevelsCompanion toDrift() {
    return LevelsCompanion(
      id: Value(id),
      name: Value(name),
      costPerHour: Value(costPerHour),
    );
  }

  // For JSON serialization (if needed for API calls)
  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      id: json['id'] as int,
      name: json['name'] as String,
      costPerHour: json['costPerHour'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'costPerHour': costPerHour,
    };
  }

  @override
  LevelModel copyWith({
    int? id,
    String? name,
    int? costPerHour,
  }) {
    return LevelModel(
      id: id ?? this.id,
      name: name ?? this.name,
      costPerHour: costPerHour ?? this.costPerHour,
    );
  }
}
