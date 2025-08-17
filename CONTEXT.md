# CONTEXT.md

## User Requirements

This section will be updated prompt-by-prompt with the user's requirements.

*   **2025-08-17:** The user wants to implement the database schema for the Comet TS application, based on the `PROJECT_PLAN.md` file. The schema should be simple, intelligent, and only include what is necessary to achieve the goals.
*   **2025-08-17:** The user wants to integrate the `User` concept with the existing login and registration flow, and remove the separate "User" button and "Users" list from the UI.

## Implementation History

This section provides a brief history of implementation decisions.

*   **2025-08-17:**
    *   **What:** Implemented the database schema using Drift.
    *   **Why:** The `PROJECT_PLAN.md` file specifies the use of Drift for the local database. The schema was designed to be simple and normalized, covering all the requirements for Milestone 1 (Core workflow).
    *   **How:**
        1.  Defined the schema in `lib/core/storage/app_database.dart` using Drift's Dart API.
        2.  Added the `drift` and `drift_dev` dependencies to `pubspec.yaml`.
        3.  Updated the Dart SDK constraint to `^3.8.0` to resolve a build issue.
        4.  Ran the build runner to generate the necessary database code.

*   **2025-08-17:**
    *   **What:** Implemented tests for the database schema and CRUD operations.
    *   **Why:** To ensure the correctness and integrity of the database layer.
    *   **How:** Created `test/core/storage/app_database_test.dart` with in-memory database tests.

*   **2025-08-17:**
    *   **What:** Integrated the `User` entity with the authentication system.
    *   **Why:** To connect the application's users (managers) to the local database for authentication and data storage, as per the clarified user requirements.
    *   **How:**
        1.  Updated `lib/features/auth/domain/entities/user_entity.dart` to match the database `User` table (using `username`, `passwordHash`, `pinHash`, `biometricsEnabled`).
        2.  Created `lib/core/utils/password_hasher.dart` for password hashing.
        3.  Modified `lib/features/auth/data/repositories/auth_repository_impl.dart` to use `UserRepository` for user operations, hash passwords, and remove remote data source dependencies.
        4.  Modified `lib/features/auth/domain/usecases/login_use_case.dart` and `lib/features/auth/domain/usecases/register_use_case.dart` to use `username` instead of `email`/`name`.
        5.  Modified `lib/features/auth/presentation/screens/login_screen.dart` and `lib/features/auth/presentation/screens/register_screen.dart` to use `username` for input.
        6.  Moved `sharedPreferencesProvider` to `lib/core/providers/shared_preferences_provider.dart` for global access.
        7.  Re-created missing user-related files (`user_repository.dart`, `create_user.dart`, `get_user.dart`, `user_providers.dart`, `user_local_data_source.dart`, `user_model.dart`, `get_user_by_username.dart`) that were accidentally deleted during a previous cleanup.
        8.  Fixed various import and usage errors that arose from these changes.
        9.  Refined error handling in `AuthRepositoryImpl` to provide more specific error messages (e.g., `CacheFailure` instead of generic `ServerFailure`).
        10. Fixed `AuthRepositoryImpl.login` to correctly retrieve user by username.
        11. Added logging to `UserLocalDataSourceImpl.createUser` for debugging.
        12. Added `deleteAllUsers` functionality (method, use case, provider, and debug button) to clear user data.
        13. Added logging to `AuthRepositoryImpl.register` and `AuthRepositoryImpl.login` to trace `passwordHash` values.

## Project State

This section helps to regain the project state.

*   **Current Milestone:** Milestone 1: Core workflow.
*   **Last Action:** All compilation errors related to database integration and authentication refactoring have been resolved. The app builds successfully.
*   **Next Action:** Manual testing of the login and registration flow by the user, with a focus on using the new debug tools and observing logs.
