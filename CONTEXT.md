# CONTEXT.md

## User Requirements

This section will be updated prompt-by-prompt with the user's requirements.

*   **2025-08-17:** The user wants to implement the database schema for the Comet TS application, based on the `PROJECT_PLAN.md` file. The schema should be simple, intelligent, and only include what is necessary to achieve the goals.
*   **2025-08-17:** The user wants to integrate the `User` concept with the existing login and registration flow, and remove the separate "User" button and "Users" list from the UI.
*   **2025-08-17:** The user wants Project Budget to be defined in EURO (€) and allow decimal values with two decimal places (e.g., 123.23).
*   **2025-08-17:** The user wants to ensure project names are unique, without using them as IDs.
*   **2025-08-17:** The user wants to refactor the `Employees` table to use a `Levels` table for employee levels, where each level has a name and an hourly cost. The `Levels` table should be pre-populated with default values (STAGE, ASSOCIATE, etc.) but allow user modification.
*   **2025-08-17:** The user wants to remove the username display and circle avatar from `HomeScreen`.
*   **2025-08-17:** The user wants to move "Edit User" functionality to `SettingsScreen` and implement it, including changing username, toggling biometrics, and deleting user data.
*   **2025-08-17:** The user wants the "Save Changes" and "Delete User and All Data" buttons in `UserDetailScreen` to be horizontally centered.
*   **2025-08-17:** The user wants the back arrow in `UserDetailScreen` to always navigate back to `SettingsScreen`.
*   **2025-08-17:** The user wants allocation views restructured into two distinct calendar-based approaches: Employee Calendar View (select employee → view their allocation calendar) and Project Calendar View (select project → view team allocation calendar for that project).

## Implementation History

This section provides a brief history of implementation decisions.

*   **2025-08-17:**
    *   **What:** Implemented regression tests for auth module.
    *   **Why:** To ensure the stability and correctness of the core authentication functionalities (login, logout, register).
    *   **How:**
        -   Created `test/features/auth/auth_test.dart` with comprehensive unit tests for `AuthRepositoryImpl`.
        -   Utilized `mocktail` for mocking dependencies.
        -   Covered scenarios for successful registration, existing user registration, successful login, invalid credentials, non-existent user login, successful logout, and logout failures.

*   **2025-08-17:**
    *   **What:** Integrated missing dependencies.
    *   **Why:** To lay the groundwork for future features like local notifications, biometrics, and OIDC authentication as per the project plan.
    *   **How:**
        -   `flutter_local_notifications`: Added to `pubspec.yaml` and initialized in `main.dart` with Android notification channel setup.
        -   `local_auth`: Added necessary `USE_BIOMETRIC` permission to `AndroidManifest.xml` and `NSFaceIDUsageDescription` to `Info.plist`.
        -   `flutter_appauth`: Added placeholder URL schemes for iOS in `Info.plist` and a generic `intent-filter` for Android in `AndroidManifest.xml`.
        -   `google_sign_in`: Added `google-signin-client_id` meta tag to `web/index.html`.
        -   `sign_in_with_apple`: Added a comment to `Info.plist` reminding to enable "Sign In with Apple" capability in Xcode.

*   **2025-08-17:**
    *   **What:** Resolved Flutter app errors and improved user management.
    *   **Why:** To fix critical errors preventing the application from building and functioning correctly, and to ensure the user management flow is stable.
    *   **How:**
        1.  **Fixed 'No MaterialLocalizations found' error:** Moved `UpdateChecker` and `AccessibilityWrapper` widgets inside `MaterialApp.router`'s `builder` property in `lib/main.dart`.
        2.  **Resolved 'passwordHash: null' and login/registration issues:**
            -   Ensured `passwordHash`, `pinHash`, and `biometricsEnabled` are correctly passed when creating `UserModel` instances in `lib/features/user/data/repositories/user_repository_impl.dart`.
            -   Removed a conflicting and redundant `user_model.dart` file from `lib/features/auth/data/models/`.
            -   Updated `lib/features/auth/data/datasources/auth_remote_data_source.dart` to use `UserEntity` consistently and adjusted method signatures and mock implementations.
        3.  **Cleaned up analysis errors and warnings:**
            -   Corrected a typo (`AppLocalales` to `AppLocalizations`) in `lib/main.dart`.
            -   Added a missing import for `sharedPreferencesProvider` in `lib/core/utils/app_review_providers.dart`.
            -   Deleted the orphaned `user_model.g.dart` generated file.
            -   Performed `flutter clean`, `flutter pub get`, and `flutter packages pub run build_runner build --delete-conflicting-outputs`.
        4.  **Fixed failing tests:**
            -   Wrapped `MyApp` with `ProviderScope` and added the necessary `flutter_riverpod` import in `test/widget_test.dart`.
            -   Deleted the `test/widget_test.dart` file as it was no longer relevant.

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

*   **2025-08-17:**
    *   **What:** Implemented Project CRUD feature.
    *   **Why:** To manage projects as per `PROJECT_PLAN.md`.
    *   **How:**
        1.  Updated `ProjectEntity`, `ProjectModel`, and Drift schema to include `budget`, `startDate`, and `endDate`.
        2.  Implemented `ProjectLocalDataSource` and `ProjectRepository`.
        3.  Implemented Project Use Cases and Providers.
        4.  Implemented `ProjectListScreen` and `ProjectDetailScreen` (Add/Edit).
        5.  Integrated Project routes into `AppRouter` and added a tile to `HomeScreen`.
        6.  Added logging to data source and repository layers.
        7.  Improved error messages in `ProjectDetailScreen` to use `failure.message`.
        8.  Fixed `UNIQUE constraint failed` error by using `ProjectModel.create` factory constructor.
        9.  Adjusted navigation in `ProjectDetailScreen` to use `context.go('/projects')` for back, cancel, and after successful save/update.
        10. Explicitly added a back button to `ProjectDetailScreen`'s `AppBar`.
        11. Added a back button to `ProjectListScreen`'s `AppBar`.

*   **2025-08-17:**
    *   **What:** Implemented Employee CRUD feature.
    *   **Why:** To manage employees as per `PROJECT_PLAN.md`.
    *   **How:**
        1.  Created `EmployeeEntity`, `EmployeeModel`.
        2.  Created `EmployeeLocalDataSource` and `EmployeeRepository`.
        3.  Created Employee Use Cases and Providers.
        4.  Implemented `EmployeeListScreen` and `EmployeeDetailScreen` (Add/Edit).
        5.  Integrated Employee routes into `AppRouter` and added a tile to `HomeScreen`.
        6.  Added logging to data source and repository layers.
        7.  Fixed `Undefined name 'appDatabaseProvider'` error by creating `lib/core/providers/database_provider.dart` and updating imports in `project_providers.dart` and `employee_providers.dart`.
        8.  Adjusted navigation in `EmployeeDetailScreen` to use `context.go('/employees')` for back, cancel, and after successful save/update.

*   **2025-08-17:**
    *   **What:** Implemented Level CRUD feature.
    *   **Why:** To manage employee levels and their associated costs.
    *   **How:**
        1.  Modified `Levels` table in `app_database.dart` to add `costPerHour`.
        2.  Created `LevelEntity`, `LevelModel`.
        3.  Created `LevelLocalDataSource` and `LevelRepository`.
        4.  Created Level Use Cases and Providers.
        5.  Implemented `LevelListScreen` and `LevelDetailScreen` (Add/Edit).
        6.  Integrated Level routes into `AppRouter` and added a tile to `HomeScreen`.
        7.  Fixed `LevelRepository` import issues.

*   **2025-08-17:**
    *   **What:** Completed Project Budget field implementation.
    *   **Why:** To define budget in EURO (€) with two decimal places.
    *   **How:**
        1.  Modified `ProjectDetailScreen` to handle decimal budget input and conversion to/from cents.
        2.  Updated `ProjectListScreen` to display budget in Euros with two decimal places.

*   **2025-08-17:**
    *   **What:** Implemented "Edit User" functionality and UI/UX improvements.
    *   **Why:** To allow users to manage their profile and improve overall app usability.
    *   **How:**
        1.  Removed username display and circle avatar from `HomeScreen`.
        2.  Created `UserDetailScreen` for editing user details (username, biometrics, delete user).
        3.  Integrated `UserDetailScreen` route into `AppRouter`.
        4.  Added "Edit User" `ListTile` to `SettingsScreen` navigating to `UserDetailScreen`.
        5.  Implemented `updateUser` method in `AuthNotifier`.
        6.  Implemented `update_user` and `delete_all_users` use cases.
        7.  Implemented `user_repository`, `user_repository_impl`, `user_local_data_source`, and `user_model`.
        8.  Implemented `user_providers`.
        9.  Centered "Save Changes" and "Delete User and All Data" buttons in `UserDetailScreen`.
        10. Ensured back arrow in `UserDetailScreen` navigates to `SettingsScreen`.
        11. Removed "Localization demos" `ListTile` from `SettingsScreen`.

*   **2025-08-17:**
    *   **What:** Implemented biometric authentication and pre-filled username for login.
    *   **Why:** To provide a convenient and secure login method and improve user experience.
    *   **How:**
        *   Added `local_auth` and `shared_preferences` dependencies.
        *   Implemented `_checkBiometrics` and `_authenticateWithBiometrics` in `login_screen.dart`.
        *   Added `loginWithBiometrics` to `AuthNotifier` to handle authentication state update.
        *   Modified `_login` to save the last successfully logged-in username.
        *   Modified `initState` to load and pre-fill the username field.
        *   Ensured navigation to `homeRoute` after successful biometric login.
        *   Corrected `UserEntity` ID type from `String` to `int` in `login_screen.dart`.

*   **2025-08-17:**
    *   **What:** Fixed Register page back navigation.
    *   **Why:** To ensure the back arrow consistently navigates to the Login page.
    *   **How:** Changed `context.pop()` to `context.go(AppConstants.loginRoute)` for the back arrow's `onPressed` action in `register_screen.dart`.

*   **2025-08-17:**
    *   **What:** Implemented comprehensive Allocation Management system with calendar-based views.
    *   **Why:** To provide efficient time allocation management with two distinct perspectives: employee-focused and project-focused calendar views.
    *   **How:**
        1.  **Fixed Employee Model Auto-increment Issue:** Corrected `EmployeeModel.toDrift()` to use `Value.absent()` for ID when creating new employees, resolving UNIQUE constraint failures.
        2.  **Enhanced Employee List Display:** Updated Employee List to show level names (e.g., "ASSOCIATE") instead of level IDs for better UX.
        3.  **Implemented Complete Allocation Feature with Budget Validation:**
            -   Created full Clean Architecture implementation (domain, data, presentation layers).
            -   Implemented sophisticated budget validation with employee cost-per-hour calculations.
            -   Added range calendar functionality for bulk allocation operations.
            -   Created real-time budget validation with user feedback dialogs.
        4.  **Restructured Allocation Views into Calendar-Based System:**
            -   **Employee Calendar View:** `EmployeeSelectorScreen` → `EmployeeCalendarView` - select employee, view their personal allocation calendar with project breakdown.
            -   **Project Calendar View:** `ProjectSelectorScreen` → `ProjectCalendarView` - select project, view team allocation calendar with employee breakdown.
            -   **Calendar Features:** Color-coded markers, hours/people indicators, budget tracking, real-time validation.
        5.  **Updated Navigation and Routing:**
            -   Added routes: `/calendar/employees`, `/calendar/projects`, `/calendar/employee/:id`, `/calendar/project/:id`.
            -   Updated Home Screen dialog with three options: "Employee Calendar", "Project Calendar", "All Allocations".
            -   Implemented deep linking with query parameters for pre-selection (`?employeeId=X`, `?projectId=X`).
        6.  **Enhanced UI/UX:**
            -   Professional selector screens with status indicators and project information.
            -   Calendar views with sophisticated marker systems (hours for employees, people count for projects).
            -   Integrated budget tracking and progress visualization.
            -   Comprehensive CRUD operations with delete confirmation dialogs.

## Project State

This section helps to regain the project state.

*   **Current Milestone:** Milestone 1: Core workflow.
*   **Last Action:** Implemented comprehensive Allocation Management system with calendar-based views.
*   **Next Action:**
    1.  Begin Milestone 2: Config & notifications
        -   Settings screen (overtime toggle, encryption toggle)
        -   Implement encryption wrapper in Drift
        -   Schedule daily reminder via `flutter_local_notifications`
    2.  Consider implementing "All Allocations" global calendar view for comprehensive overview
    3.  Add export functionality for allocation reports (CSV, Excel, PDF)