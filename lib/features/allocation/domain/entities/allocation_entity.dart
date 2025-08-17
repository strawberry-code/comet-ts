import 'package:equatable/equatable.dart';

class AllocationEntity extends Equatable {
  final int? id;
  final int projectId;
  final int employeeId;
  final DateTime date;
  final int hours; // stored as minutes for precision

  const AllocationEntity({
    this.id,
    required this.projectId,
    required this.employeeId,
    required this.date,
    required this.hours,
  });

  double get hoursAsDecimal => hours / 60.0;

  AllocationEntity copyWith({
    int? id,
    int? projectId,
    int? employeeId,
    DateTime? date,
    int? hours,
  }) {
    return AllocationEntity(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      hours: hours ?? this.hours,
    );
  }

  @override
  List<Object?> get props => [id, projectId, employeeId, date, hours];
}