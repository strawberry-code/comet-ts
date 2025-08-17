import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/domain/entities/employee_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/presentation/providers/employee_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/domain/usecases/delete_employee.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/presentation/providers/level_providers.dart';

class EmployeeListScreen extends ConsumerWidget {
  const EmployeeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsync = ref.watch(employeesListProvider);
    final levelsAsync = ref.watch(levelsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        leading: IconButton( // Explicitly add a back button
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/'); // Navigate back to the home screen
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to add employee screen
              context.go('/employees/add');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(employeesListProvider);
          ref.invalidate(levelsListProvider);
        },
        child: employeesAsync.when(
          data: (employees) => levelsAsync.when(
            data: (levels) {
              if (employees.isEmpty) {
                return ListView(
                  children: const [
                    Center(
                      child: Text('No employees yet. Add one!'),
                    ),
                  ],
                );
              }
              return ListView.builder(
                itemCount: employees.length,
                itemBuilder: (context, index) {
                  final employee = employees[index];
                  final level = levels.firstWhere(
                    (l) => l.id == employee.levelId,
                    orElse: () => throw Exception('Level not found'),
                  );
                  return ListTile(
                    title: Text(employee.name),
                    subtitle: Text(level.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Navigate to edit employee screen
                        context.go('/employees/${employee.id}');
                      },
                    ),
                    onLongPress: () {
                      // Show delete confirmation dialog
                      EmployeeListScreen._confirmDelete(context, ref, employee);
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error loading levels: $error')),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error loading employees: $error')),
        ),
      ),
    );
  }

  static void _confirmDelete(BuildContext context, WidgetRef ref, EmployeeEntity employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${employee.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(deleteEmployeeUseCaseProvider).call(DeleteEmployeeParams(id: employee.id));
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
