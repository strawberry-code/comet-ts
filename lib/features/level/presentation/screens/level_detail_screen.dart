import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for FilteringTextInputFormatter
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/domain/entities/level_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/presentation/providers/level_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/domain/usecases/get_level.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/domain/usecases/create_level.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/domain/usecases/update_level.dart';

class LevelDetailScreen extends ConsumerStatefulWidget {
  final int? levelId;

  const LevelDetailScreen({super.key, this.levelId});

  @override
  ConsumerState<LevelDetailScreen> createState() => _LevelDetailScreenState();
}

class _LevelDetailScreenState extends ConsumerState<LevelDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _costPerHourController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _costPerHourController = TextEditingController();

    if (widget.levelId != null) {
      // Load level data for editing
      ref.read(getLevelUseCaseProvider).call(GetLevelParams(id: widget.levelId!)).then((result) {
        result.fold(
          (failure) {
            // Handle error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error loading level: ${failure.message}')),
            );
          },
          (level) {
            if (level != null) {
              _nameController.text = level.name;
              _costPerHourController.text = (level.costPerHour / 100).toStringAsFixed(2);
            }
          },
        );
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costPerHourController.dispose();
    super.dispose();
  }

  void _saveLevel() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final costPerHourDouble = double.tryParse(_costPerHourController.text);
      final costPerHour = (costPerHourDouble! * 100).toInt();

      if (widget.levelId == null) {
        // Create new level
        final newLevel = LevelEntity(
          id: 0,
          name: name,
          costPerHour: costPerHour,
        );
        final result = await ref.read(createLevelUseCaseProvider).call(CreateLevelParams(level: newLevel));
        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error creating level: ${failure.message}')),
            );
          },
          (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Level created successfully!')),
            );
            context.go('/levels'); // Go back to level list
          },
        );
      } else {
        // Update existing level
        final updatedLevel = LevelEntity(
          id: widget.levelId!,
          name: name,
          costPerHour: costPerHour,
        );
        final result = await ref.read(updateLevelUseCaseProvider).call(UpdateLevelParams(level: updatedLevel));
        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error updating level: ${failure.message}')),
            );
          },
          (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Level updated successfully!')),
            );
            context.go('/levels'); // Go back to level list
          },
        );
      }
      ref.invalidate(levelsListProvider); // Refresh level list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.levelId == null ? 'Add Level' : 'Edit Level'),
        automaticallyImplyLeading: false, // Explicitly set to false
        leading: IconButton( // Explicitly add a back button
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/levels'); // Navigate back using go
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
                decoration: const InputDecoration(labelText: 'Level Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a level name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _costPerHourController,
                decoration: const InputDecoration(labelText: 'Cost Per Hour (€)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter cost per hour';
                  }
                  final costValue = double.tryParse(value);
                  if (costValue == null || costValue <= 0) {
                    return 'Please enter a valid positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _saveLevel,
                    child: Text(widget.levelId == null ? 'Add Level' : 'Update Level'),
                  ),
                  TextButton(
                    onPressed: () {
                      context.go('/levels');
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
