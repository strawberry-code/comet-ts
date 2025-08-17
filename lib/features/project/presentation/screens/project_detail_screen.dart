
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/features/project/domain/entities/project_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/project/presentation/providers/project_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_riverpod_clean_architecture/features/project/domain/usecases/get_project.dart';
import 'package:flutter_riverpod_clean_architecture/features/project/domain/usecases/create_project.dart';
import 'package:flutter_riverpod_clean_architecture/features/project/domain/usecases/update_project.dart';
import 'package:intl/intl.dart'; // For date formatting

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final int? projectId;

  const ProjectDetailScreen({super.key, this.projectId});

  @override
  ConsumerState<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _budgetController; // Renamed
  late TextEditingController _startDateController; // New
  late TextEditingController _endDateController; // New

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _budgetController = TextEditingController();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();

    if (widget.projectId != null) {
      // Load project data for editing
      ref.read(getProjectUseCaseProvider).call(GetProjectParams(id: widget.projectId!)).then((result) {
        result.fold(
          (failure) {
            // Handle error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error loading project: ${failure.message}')),
            );
          },
          (project) {
            if (project != null) {
              _nameController.text = project.name;
              _budgetController.text = project.budget.toString(); // Renamed
              _selectedStartDate = DateTime.fromMillisecondsSinceEpoch(project.startDate);
              _startDateController.text = DateFormat('yyyy-MM-dd').format(_selectedStartDate!);
              _selectedEndDate = DateTime.fromMillisecondsSinceEpoch(project.endDate);
              _endDateController.text = DateFormat('yyyy-MM-dd').format(_selectedEndDate!);
            }
          },
        );
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? (_selectedStartDate ?? DateTime.now()) : (_selectedEndDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _selectedStartDate = picked;
        } else {
          _selectedEndDate = picked;
        }
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _saveProject() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final budget = int.parse(_budgetController.text); // Renamed
      final startDate = _selectedStartDate?.millisecondsSinceEpoch; // New
      final endDate = _selectedEndDate?.millisecondsSinceEpoch; // New

      if (startDate == null || endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select both start and end dates.')),
        );
        return;
      }

      if (widget.projectId == null) {
        // Create new project
        final newProject = ProjectEntity(
          id: 0,
          name: name,
          budget: budget,
          startDate: startDate,
          endDate: endDate,
        );
        final result = await ref.read(createProjectUseCaseProvider).call(CreateProjectParams(project: newProject));
        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error creating project: ${failure.message}')),
            );
          },
          (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Project created successfully!')),
            );
            context.pop(); // Go back to project list
          },
        );
      } else {
        // Update existing project
        final updatedProject = ProjectEntity(
          id: widget.projectId!,
          name: name,
          budget: budget,
          startDate: startDate,
          endDate: endDate,
        );
        final result = await ref.read(updateProjectUseCaseProvider).call(UpdateProjectParams(project: updatedProject));
        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error updating project: ${failure.message}')),
            );
          },
          (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Project updated successfully!')),
            );
            context.pop(); // Go back to project list
          },
        );
      }
      ref.invalidate(projectsListProvider); // Refresh project list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectId == null ? 'Add Project' : 'Edit Project'),
        automaticallyImplyLeading: false, // Explicitly set to false
        leading: IconButton( // Explicitly add a back button
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Use context.pop() for the back button
            context.pop();
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
                decoration: const InputDecoration(labelText: 'Project Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a project name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _budgetController, // Renamed
                decoration: const InputDecoration(labelText: 'Budget'), // Renamed label
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter budget';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _startDateController,
                decoration: const InputDecoration(
                  labelText: 'Start Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context, _startDateController, true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a start date';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _endDateController,
                decoration: const InputDecoration(
                  labelText: 'End Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context, _endDateController, false),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an end date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _saveProject,
                    child: Text(widget.projectId == null ? 'Add Project' : 'Update Project'),
                  ),
                  TextButton(
                    onPressed: () {
                      context.pop(); // Changed from context.go('/projects')
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
