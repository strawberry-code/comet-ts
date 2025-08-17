import 'package:flutter/material.dart';
import '../../domain/entities/allocation_entity.dart';
import '../../../project/domain/entities/project_entity.dart';
import '../../../employee/domain/entities/employee_entity.dart';

class AllocationListItem extends StatelessWidget {
  final AllocationEntity allocation;
  final List<ProjectEntity> projects;
  final List<EmployeeEntity> employees;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const AllocationListItem({
    super.key,
    required this.allocation,
    required this.projects,
    required this.employees,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final project = projects.firstWhere(
      (p) => p.id == allocation.projectId,
      orElse: () => const ProjectEntity(id: -1, name: 'Unknown Project', budget: 0, startDate: 0, endDate: 0),
    );
    
    final employee = employees.firstWhere(
      (e) => e.id == allocation.employeeId,
      orElse: () => const EmployeeEntity(id: -1, name: 'Unknown Employee', levelId: 0),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getHoursColor(allocation.hoursAsDecimal),
          child: Text(
            '${allocation.hoursAsDecimal.toStringAsFixed(1)}h',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        title: Text(
          project.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(employee.name),
            Text(
              '${allocation.hoursAsDecimal.toStringAsFixed(1)} hours allocated',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onTap();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Color _getHoursColor(double hours) {
    if (hours >= 8) return Colors.red;
    if (hours >= 6) return Colors.orange;
    if (hours >= 4) return Colors.blue;
    return Colors.green;
  }
}