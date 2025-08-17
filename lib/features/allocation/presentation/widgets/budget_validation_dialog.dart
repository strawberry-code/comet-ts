import 'package:flutter/material.dart';
import '../../domain/entities/allocation_validation_result.dart';

class BudgetValidationDialog extends StatelessWidget {
  final AllocationValidationResult validation;
  final double requestedHours;
  final Function(double) onUseMaxHours;

  const BudgetValidationDialog({
    super.key,
    required this.validation,
    required this.requestedHours,
    required this.onUseMaxHours,
  });

  @override
  Widget build(BuildContext context) {
    final maxHours = validation.maxAvailableHoursAsDecimal ?? 0;
    final requiredBudget = validation.requiredBudgetAsEuros ?? 0;
    final availableBudget = validation.availableBudgetAsEuros ?? 0;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange[700]),
          const SizedBox(width: 8),
          const Text('Budget Limit Exceeded'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The requested allocation exceeds the available project budget.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),
          
          // Budget breakdown
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBudgetRow('Requested Hours:', '${requestedHours.toStringAsFixed(1)}h'),
                _buildBudgetRow('Required Budget:', '€${requiredBudget.toStringAsFixed(2)}'),
                _buildBudgetRow('Available Budget:', '€${availableBudget.toStringAsFixed(2)}'),
                const Divider(),
                _buildBudgetRow(
                  'Maximum Hours:', 
                  '${maxHours.toStringAsFixed(1)}h',
                  isHighlight: true,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'What would you like to do?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel Allocation'),
        ),
        if (maxHours > 0) ...[
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onUseMaxHours(maxHours);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: Text('Use ${maxHours.toStringAsFixed(1)}h'),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'No budget available',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBudgetRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? Colors.orange[700] : Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isHighlight ? Colors.orange[700] : Colors.red[700],
            ),
          ),
        ],
      ),
    );
  }
}