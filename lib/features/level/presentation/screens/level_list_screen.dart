import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/domain/entities/level_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/presentation/providers/level_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/domain/usecases/delete_level.dart';
import 'package:intl/intl.dart';

class LevelListScreen extends ConsumerWidget {
  const LevelListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelsAsync = ref.watch(levelsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Levels'),
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
              // Navigate to add level screen
              context.go('/levels/add');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(levelsListProvider);
        },
        child: levelsAsync.when(
          data: (levels) {
            if (levels.isEmpty) {
              return ListView(
                children: const [
                  Center(
                    child: Text('No levels yet. Add one!'),
                  ),
                ],
              );
            }
            return ListView.builder(
              itemCount: levels.length,
              itemBuilder: (context, index) {
                final level = levels[index];
                return ListTile(
                  title: Text(level.name),
                  subtitle: Text('Cost: ${NumberFormat.currency(locale: 'en_US', symbol: '€', decimalDigits: 2).format(level.costPerHour / 100)}/hour'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // Navigate to edit level screen
                      context.go('/levels/${level.id}');
                    },
                  ),
                  onLongPress: () {
                    // Show delete confirmation dialog
                    LevelListScreen._confirmDelete(context, ref, level);
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }

  static void _confirmDelete(BuildContext context, WidgetRef ref, LevelEntity level) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Level'),
        content: Text('Are you sure you want to delete ${level.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(deleteLevelUseCaseProvider).call(DeleteLevelParams(id: level.id));
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
