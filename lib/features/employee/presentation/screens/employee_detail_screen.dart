import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/domain/entities/employee_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/presentation/providers/employee_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/domain/usecases/get_employee.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/domain/usecases/create_employee.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/domain/usecases/update_employee.dart';

class EmployeeDetailScreen extends ConsumerStatefulWidget {
  final int? employeeId;

  const EmployeeDetailScreen({super.key, this.employeeId});

  @override
  ConsumerState<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends ConsumerState<EmployeeDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _levelIdController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _levelIdController = TextEditingController();

    if (widget.employeeId != null) {
      // Load employee data for editing
      ref.read(getEmployeeUseCaseProvider).call(GetEmployeeParams(id: widget.employeeId!)).then((result) {
        result.fold(
          (failure) {
            // Handle error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error loading employee: ${failure.message}')),
            );
          },
          (employee) {
            if (employee != null) {
              _nameController.text = employee.name;
              _levelIdController.text = employee.levelId.toString();
            }
          },
        );
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _levelIdController.dispose();
    super.dispose();
  }

  void _saveEmployee() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final levelId = int.parse(_levelIdController.text);

      if (widget.employeeId == null) {
        // Create new employee
        final newEmployee = EmployeeEntity(
          id: 0,
          name: name,
          levelId: levelId,
        );
        final result = await ref.read(createEmployeeUseCaseProvider).call(CreateEmployeeParams(employee: newEmployee));
        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error creating employee: ${failure.message}')),
            );
          },
          (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Employee created successfully!')),
            );
            context.pop(); // Go back to employee list
          },
        );
      } else {
        // Update existing employee
        final updatedEmployee = EmployeeEntity(
          id: widget.employeeId!,
          name: name,
          levelId: levelId,
        );
        final result = await ref.read(updateEmployeeUseCaseProvider).call(UpdateEmployeeParams(employee: updatedEmployee));
        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error updating employee: ${failure.message}')),
            );
          },
          (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Employee updated successfully!')),
            );
            context.pop(); // Go back to employee list
          },
        );
      }
      ref.invalidate(employeesListProvider); // Refresh employee list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employeeId == null ? 'Add Employee' : 'Edit Employee'),
        leading: IconButton( // Explicitly add a back button
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop(); // Navigate back using pop
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Employee Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an employee name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _levelIdController,
                decoration: const InputDecoration(labelText: 'Level ID'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a level ID';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _saveEmployee,
                    child: Text(widget.employeeId == null ? 'Add Employee' : 'Update Employee'),
                  ),
                  TextButton(
                    onPressed: () {
                      context.pop();
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
