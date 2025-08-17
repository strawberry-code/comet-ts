import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/domain/entities/employee_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/presentation/providers/employee_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/domain/usecases/get_employee.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/domain/usecases/create_employee.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/domain/usecases/update_employee.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/domain/entities/level_entity.dart'; // New import
import 'package:flutter_riverpod_clean_architecture/features/level/presentation/providers/level_providers.dart'; // New import

class EmployeeDetailScreen extends ConsumerStatefulWidget {
  final int? employeeId;

  const EmployeeDetailScreen({super.key, this.employeeId});

  @override
  ConsumerState<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends ConsumerState<EmployeeDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  LevelEntity? _selectedLevel; // Changed from TextEditingController

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();

    // Fetch all levels first
    ref.read(getAllLevelsUseCaseProvider).call(NoParams()).then((levelsResult) {
      levelsResult.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading levels: ${failure.message}')),
          );
        },
        (levels) {
          if (widget.employeeId != null) {
            // Load employee data for editing
            ref.read(getEmployeeUseCaseProvider).call(GetEmployeeParams(id: widget.employeeId!)).then((employeeResult) {
              employeeResult.fold(
                (failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error loading employee: ${failure.message}')),
                  );
                },
                (employee) {
                  if (employee != null) {
                    _nameController.text = employee.name;
                    _selectedLevel = levels.firstWhere((level) => level.id == employee.levelId);
                    setState(() {}); // Update UI after setting selected level
                  }
                },
              );
            });
          }
        },
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveEmployee() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final levelId = _selectedLevel?.id; // Get levelId from selectedLevel

      if (levelId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an employee level.')),
        );
        return;
      }

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
            context.go('/employees');
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
            context.go('/employees');
          },
        );
      }
      ref.invalidate(employeesListProvider); // Refresh employee list
    }
  }

  @override
  Widget build(BuildContext context) {
    final levelsAsync = ref.watch(levelsListProvider); // Watch levels provider

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employeeId == null ? 'Add Employee' : 'Edit Employee'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/employees');
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
              levelsAsync.when(
                data: (levels) {
                  if (levels.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text('No levels available. Please add levels first.'),
                    );
                  }
                  return DropdownButtonFormField<LevelEntity>(
                    value: _selectedLevel,
                    decoration: const InputDecoration(labelText: 'Level'),
                    items: levels.map((level) {
                      return DropdownMenuItem(value: level,
                        child: Text(level.name),
                      );
                    }).toList(),
                    onChanged: (LevelEntity? newValue) {
                      setState(() {
                        _selectedLevel = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a level';
                      }
                      return null;
                    },
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('Error loading levels: $error'),
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
                      context.go('/employees');
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