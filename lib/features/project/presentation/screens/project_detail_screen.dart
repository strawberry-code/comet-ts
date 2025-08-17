
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/features/project/domain/entities/project_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/project/presentation/providers/project_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final int? projectId;

  const ProjectDetailScreen({super.key, this.projectId});

  @override
  ConsumerState<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _budgetHoursController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _budgetHoursController = TextEditingController();

    if (widget.projectId != null) {
      // Load project data for editing
      ref.read(getProjectUseCaseProvider).call(GetProjectParams(id: widget.projectId!)).then((result) {
        result.fold(
          (failure) {
            // Handle error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error loading project: \$failure')),
            );
          },
          (project) {
            if (project != null) {
              _nameController.text = project.name;
              _budgetHoursController.text = project.budgetHours.toString();
            }
          },
        );
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetHoursController.dispose();
    super.dispose();
  }

  void _saveProject() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final budgetHours = int.parse(_budgetHoursController.text);

      if (widget.projectId == null) {
        // Create new project
        final newProject = ProjectEntity(id: 0, name: name, budgetHours: budgetHours);
        final result = await ref.read(createProjectUseCaseProvider).call(CreateProjectParams(project: newProject));
        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error creating project: \$failure')),
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
        final updatedProject = ProjectEntity(id: widget.projectId!, name: name, budgetHours: budgetHours);
        final result = await ref.read(updateProjectUseCaseProvider).call(UpdateProjectParams(project: updatedProject));
        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error updating project: \$failure')),
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
                controller: _budgetHoursController,
                decoration: const InputDecoration(labelText: 'Budget Hours'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter budget hours';
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
                    onPressed: _saveProject,
                    child: Text(widget.projectId == null ? 'Add Project' : 'Update Project'),
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
