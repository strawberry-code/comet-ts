# CONTEXT.md

## User Requirements

This section will be updated prompt-by-prompt with the user's requirements.

*   **2025-08-17:** The user wants to implement the database schema for the Comet TS application, based on the `PROJECT_PLAN.md` file. The schema should be simple, intelligent, and only include what is necessary to meet the requirements.

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

## Project State

This section helps to regain the project state.

*   **Current Milestone:** Milestone 1: Core workflow.
*   **Last Action:** The database schema has been successfully implemented using Drift.
*   **Next Action:** Implement the local user storage and authentication feature.
