import 'package:flutter_riverpod_clean_architecture/features/project/presentation/screens/project_list_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/project/presentation/screens/project_detail_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/presentation/screens/employee_list_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/employee/presentation/screens/employee_detail_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/presentation/screens/level_list_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/presentation/screens/level_detail_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/allocation/presentation/screens/allocation_list_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/allocation/presentation/screens/allocation_detail_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/allocation/presentation/screens/employee_allocation_list_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/allocation/presentation/screens/project_allocation_list_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/allocation/presentation/screens/employee_selector_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/allocation/presentation/screens/project_selector_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/allocation/presentation/screens/employee_calendar_view.dart';
import 'package:flutter_riverpod_clean_architecture/features/allocation/presentation/screens/project_calendar_view.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/presentation/screens/user_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/localization_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/router/locale_aware_router.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/screens/register_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/presentation/screens/language_settings_screen.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  // Watch for locale changes - this rebuilds the router when locale changes
  ref.watch(persistentLocaleProvider);

  // Create a router with locale awareness
  return GoRouter(
    initialLocation: AppConstants.initialRoute,
    debugLogDiagnostics: true,
    // Add the observer for locale awareness
    observers: [ref.read(localizationRouterObserverProvider)],
    redirect: (context, state) {
      // Get the authentication status
      final isLoggedIn = authState.isAuthenticated;

      // Check if the user is going to the login page
      final isGoingToLogin = state.matchedLocation == AppConstants.loginRoute;

      // Check if the user is going to the register page
      final isGoingToRegister =
          state.matchedLocation == AppConstants.registerRoute;

      // If not logged in and not going to login or register, redirect to login
      if (!isLoggedIn && !isGoingToLogin && !isGoingToRegister) {
        return AppConstants.loginRoute;
      }

      // If logged in and going to login, redirect to home
      if (isLoggedIn && (isGoingToLogin || isGoingToRegister)) {
        return AppConstants.homeRoute;
      }

      // No redirect needed
      return null;
    },
    routes: [
      // Home route
      GoRoute(
        path: AppConstants.homeRoute,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // Project List route
      GoRoute(
        path: '/projects',
        name: 'projects',
        builder: (context, state) => const ProjectListScreen(),
      ),

      // Project Detail route (Add/Edit)
      GoRoute(
        path: '/projects/:id',
        name: 'project_detail',
        builder: (context, state) => ProjectDetailScreen(projectId: state.pathParameters['id'] == 'add' ? null : int.parse(state.pathParameters['id']!)),
      ),

      // Employee List route
      GoRoute(
        path: '/employees',
        name: 'employees',
        builder: (context, state) => const EmployeeListScreen(),
      ),

      // Employee Detail route (Add/Edit)
      GoRoute(
        path: '/employees/:id',
        name: 'employee_detail',
        builder: (context, state) => EmployeeDetailScreen(employeeId: state.pathParameters['id'] == 'add' ? null : int.parse(state.pathParameters['id']!)),
      ),

      // Level List route
      GoRoute(
        path: '/levels',
        name: 'levels',
        builder: (context, state) => const LevelListScreen(),
      ),

      // Level Detail route (Add/Edit)
      GoRoute(
        path: '/levels/:id',
        name: 'level_detail',
        builder: (context, state) => LevelDetailScreen(levelId: state.pathParameters['id'] == 'add' ? null : int.parse(state.pathParameters['id']!)),
      ),

      // Allocation List route
      GoRoute(
        path: '/allocations',
        name: 'allocations',
        builder: (context, state) => const AllocationListScreen(),
      ),

      // Allocation Detail route (Add/Edit)
      GoRoute(
        path: '/allocations/:id',
        name: 'allocation_detail',
        builder: (context, state) {
          // Handle query parameters for pre-filling employee or project
          final employeeId = state.uri.queryParameters['employeeId'];
          final projectId = state.uri.queryParameters['projectId'];
          
          return AllocationDetailScreen(
            allocationId: state.pathParameters['id'] == 'add' ? null : int.parse(state.pathParameters['id']!),
            preselectedEmployeeId: employeeId != null ? int.parse(employeeId) : null,
            preselectedProjectId: projectId != null ? int.parse(projectId) : null,
          );
        },
      ),

      // Employee Allocation List route
      GoRoute(
        path: '/allocations/employee/:employeeId',
        name: 'employee_allocations',
        builder: (context, state) => EmployeeAllocationListScreen(
          employeeId: int.parse(state.pathParameters['employeeId']!),
        ),
      ),

      // Project Allocation List route
      GoRoute(
        path: '/allocations/project/:projectId',
        name: 'project_allocations',
        builder: (context, state) => ProjectAllocationListScreen(
          projectId: int.parse(state.pathParameters['projectId']!),
        ),
      ),

      // Employee Selector for Calendar View
      GoRoute(
        path: '/calendar/employees',
        name: 'employee_selector',
        builder: (context, state) => const EmployeeSelectorScreen(),
      ),

      // Project Selector for Calendar View
      GoRoute(
        path: '/calendar/projects',
        name: 'project_selector',
        builder: (context, state) => const ProjectSelectorScreen(),
      ),

      // Employee Calendar View
      GoRoute(
        path: '/calendar/employee/:employeeId',
        name: 'employee_calendar',
        builder: (context, state) => EmployeeCalendarView(
          employeeId: int.parse(state.pathParameters['employeeId']!),
        ),
      ),

      // Project Calendar View
      GoRoute(
        path: '/calendar/project/:projectId',
        name: 'project_calendar',
        builder: (context, state) => ProjectCalendarView(
          projectId: int.parse(state.pathParameters['projectId']!),
        ),
      ),

      // Login route
      GoRoute(
        path: AppConstants.loginRoute,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Register route
      GoRoute(
        path: AppConstants.registerRoute,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Settings route
      GoRoute(
        path: AppConstants.settingsRoute,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // Language settings route
      GoRoute(
        path: AppConstants.languageSettingsRoute,
        name: 'language_settings',
        builder: (context, state) => const LanguageSettingsScreen(),
      ),

      // User Detail route (Edit User)
      GoRoute(
        path: '/user_detail',
        name: 'user_detail',
        builder: (context, state) => const UserDetailScreen(),
      ),

      // Initial route - redirects based on auth state
      GoRoute(
        path: AppConstants.initialRoute,
        name: 'initial',
        redirect:
            (_, __) =>
                authState.isAuthenticated
                    ? AppConstants.homeRoute
                    : AppConstants.loginRoute,
      ),
    ],
    errorBuilder:
        (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Page Not Found')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '404',
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Page ${state.uri.path} not found'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go(AppConstants.homeRoute),
                  child: const Text('Go Home'),
                ),
              ],
            ),
          ),
        ),
  );
});