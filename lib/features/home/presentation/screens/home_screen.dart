import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/router/locale_aware_router.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/app_utils.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch auth state to get current user
    final authState = ref.watch(authProvider);
    final user = authState.user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Show confirmation dialog
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
              
              // Logout if user confirmed
              if (shouldLogout == true) {
                await ref.read(authProvider.notifier).logout();
                
                if (ref.read(authProvider).errorMessage != null) {
                  if (context.mounted) {
                    AppUtils.showSnackBar(
                      context,
                      message: ref.read(authProvider).errorMessage!,
                      backgroundColor: Theme.of(context).colorScheme.error,
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                // Add refresh logic here if needed
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Features section
                  const Text(
                    'Features',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Feature tiles
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.2,
                    children: [
                      // Add Project feature tile
                      _buildFeatureTile(
                        context,
                        icon: Icons.assignment, // Or a more suitable icon
                        title: 'Projects',
                        color: Colors.teal, // Choose a suitable color
                        onTap: () {
                          GoRouter.of(context).go('/projects'); // Navigate to the projects list screen
                        },
                      ),
                      // Add Employee feature tile
                      _buildFeatureTile(
                        context,
                        icon: Icons.person, // Or a more suitable icon
                        title: 'Employees',
                        color: Colors.indigo, // Choose a suitable color
                        onTap: () {
                          GoRouter.of(context).go('/employees'); // Navigate to the employees list screen
                        },
                      ),
                      // Add Levels feature tile
                      _buildFeatureTile(
                        context,
                        icon: Icons.leaderboard, // Or a more suitable icon
                        title: 'Levels',
                        color: Colors.brown, // Choose a suitable color
                        onTap: () {
                          GoRouter.of(context).go('/levels'); // Navigate to the levels list screen
                        },
                      ),
                      // Add Allocations feature tile
                      _buildFeatureTile(
                        context,
                        icon: Icons.schedule, // Or a more suitable icon
                        title: 'Allocations',
                        color: Colors.deepPurple, // Choose a suitable color
                        onTap: () {
                          _showAllocationOptions(context);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Information section
                  const Text(
                    'About this app',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Flutter Riverpod Clean Architecture',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '''Comet TS is a mobile-only, fully offline timesheet manager. It allows HR managers to allocate hours to employees and generate simple reports. It's built with Flutter, Riverpod, and GoRouter, following Clean Architecture principles, and is designed to be cloud-ready for future integrations.''',
                          ),
                          
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],

        onTap: (index) {
          switch (index) {
            case 0:
              context.goWithLocale(AppConstants.homeRoute);
              break;
            case 1:
              AppUtils.showSnackBar(
                context,
                message: 'This feature is not implemented yet',
              );
              //context.goWithLocale(AppConstants.exploreRoute);
              break;
            case 2:
              AppUtils.showSnackBar(
                context,
                message: 'This feature is not implemented yet',
              );
              //context.goWithLocale(AppConstants.notificationsRoute);
              break;
            case 3:
              context.goWithLocale(AppConstants.settingsRoute);
              break;
            default:
              AppUtils.showSnackBar(
                context,
                message: 'This feature is not implemented yet',
              );
              break;
          }
        },
      ),
    );
  }

  Widget _buildFeatureTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    // Explicitly import GoRouter here as a workaround
    // This is NOT ideal, but for debugging this persistent issue
    // ignore: unused_import
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAllocationOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Allocation Calendar Views'),
        content: const Text('Choose the type of allocation calendar you want to view:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              GoRouter.of(context).go('/calendar/employees'); // Employee selector
            },
            child: const Text('Employee Calendar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              GoRouter.of(context).go('/calendar/projects'); // Project selector
            },
            child: const Text('Project Calendar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              GoRouter.of(context).go('/allocations'); // Keep the general view for now
            },
            child: const Text('All Allocations'),
          ),
        ],
      ),
    );
  }
}
