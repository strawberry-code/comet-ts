import 'package:flutter/material.dart';
import '../../domain/entities/allocation_entity.dart';

class AllocationSummaryCard extends StatelessWidget {
  final DateTime selectedDate;
  final List<AllocationEntity> allocations;

  const AllocationSummaryCard({
    super.key,
    required this.selectedDate,
    required this.allocations,
  });

  @override
  Widget build(BuildContext context) {
    final totalHours = allocations.fold<int>(0, (sum, allocation) => sum + allocation.hours);
    final totalHoursDecimal = totalHours / 60.0;
    final remainingHours = 8.0 - totalHoursDecimal;
    
    final projects = allocations.map((a) => a.projectId).toSet().length;
    final employees = allocations.map((a) => a.employeeId).toSet().length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    icon: Icons.access_time,
                    label: 'Total Hours',
                    value: '${totalHoursDecimal.toStringAsFixed(1)}h',
                    color: totalHoursDecimal > 8 ? Colors.red : Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    icon: Icons.hourglass_empty,
                    label: 'Remaining',
                    value: '${remainingHours.clamp(0, 8).toStringAsFixed(1)}h',
                    color: remainingHours <= 0 ? Colors.red : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    icon: Icons.work,
                    label: 'Projects',
                    value: projects.toString(),
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    icon: Icons.people,
                    label: 'Employees',
                    value: employees.toString(),
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            if (totalHoursDecimal > 8) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Daily limit exceeded by ${(totalHoursDecimal - 8).toStringAsFixed(1)} hours',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}