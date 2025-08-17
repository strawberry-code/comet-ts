import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/app_utils.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/domain/usecases/update_user.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/domain/usecases/delete_all_users.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/entities/user_entity.dart';

import '../../../../core/constants/app_constants.dart'; // New import
import '../../../../core/usecases/usecase.dart';
import '../providers/user_providers.dart';

class UserDetailScreen extends ConsumerStatefulWidget {
  const UserDetailScreen({super.key});

  @override
  ConsumerState<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends ConsumerState<UserDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  bool _biometricsEnabled = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _usernameController = TextEditingController(text: user?.username ?? '');
    _biometricsEnabled = user?.biometricsEnabled ?? false;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _saveUser() async {
    if (_formKey.currentState!.validate()) {
      final newUsername = _usernameController.text;
      final currentUser = ref.read(authProvider).user;

      if (currentUser == null) {
        AppUtils.showSnackBar(context, message: 'User not found.', backgroundColor: Theme.of(context).colorScheme.error);
        return;
      }

      final updatedUser = currentUser.copyWith(
        username: newUsername,
        biometricsEnabled: _biometricsEnabled,
      );

      final result = await ref.read(updateUserUseCaseProvider).call(UpdateUserParams(user: updatedUser));

      result.fold(
        (failure) {
          AppUtils.showSnackBar(context, message: 'Error updating user: ${failure.message}', backgroundColor: Theme.of(context).colorScheme.error);
        },
        (_) {
          AppUtils.showSnackBar(context, message: 'User updated successfully!');
          ref.read(authProvider.notifier).updateUser(updatedUser); // Update auth provider state
          context.pop(); // Go back to settings
        },
      );
    }
  }

  void _deleteUser() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User and All Data'),
        content: const Text('Are you sure you want to delete your user and ALL application data? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      final result = await ref.read(deleteAllUsersUseCaseProvider).call(NoParams());
      result.fold(
        (failure) {
          AppUtils.showSnackBar(context, message: 'Error deleting user and data: ${failure.message}', backgroundColor: Theme.of(context).colorScheme.error);
        },
        (_) {
          AppUtils.showSnackBar(context, message: 'User and all data deleted successfully!');
          ref.read(authProvider.notifier).logout(); // Logout after deleting user
          context.go('/'); // Go to login/home after logout
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go(AppConstants.settingsRoute); // Navigate back to settings
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text('Enable Biometrics', style: Theme.of(context).textTheme.titleMedium),
                  ),
                  Switch(
                    value: _biometricsEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _biometricsEnabled = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center( // Wrap in Center widget
                child: ElevatedButton(
                  onPressed: _saveUser,
                  child: const Text('Save Changes'),
                ),
              ),
              const SizedBox(height: 20),
              Center( // Wrap in Center widget
                child: ElevatedButton(
                  onPressed: _deleteUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Colors.white, // Set text color to white
                  ),
                  child: const Text('Delete User and All Data'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
