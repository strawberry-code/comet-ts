import 'package:equatable/equatable.dart';

class LevelEntity extends Equatable {
  final int id;
  final String name;
  final int costPerHour; // Cost per hour in cents

  const LevelEntity({
    required this.id,
    required this.name,
    required this.costPerHour,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        costPerHour,
      ];

  LevelEntity copyWith({
    int? id,
    String? name,
    int? costPerHour,
  }) {
    return LevelEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      costPerHour: costPerHour ?? this.costPerHour,
    );
  }
}
