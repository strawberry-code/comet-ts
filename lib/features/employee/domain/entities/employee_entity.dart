import 'package:equatable/equatable.dart';

class EmployeeEntity extends Equatable {
  final int id;
  final String name;
  final int levelId;

  const EmployeeEntity({
    required this.id,
    required this.name,
    required this.levelId,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        levelId,
      ];

  EmployeeEntity copyWith({
    int? id,
    String? name,
    int? levelId,
  }) {
    return EmployeeEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      levelId: levelId ?? this.levelId,
    );
  }
}
