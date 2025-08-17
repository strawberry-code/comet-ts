# Comet TS – Project Plan

---

## 1 · Product Vision

A **mobile‑only, fully offline timesheet manager** designed primarily as a **portfolio showcase** for job interviews, yet usable by small‑to‑medium businesses. It lets HR managers allocate hours to employees and generate simple reports. The codebase is architected **offline‑first, cloud‑ready**, so that future versions can sync with enterprise HR suites (e.g. SAP, Replicon).

---

## 2 · High‑Level Requirements (HLR)

| ID     | Requirement                                          | Notes                                                                                   |
| ------ | ---------------------------------------------------- | --------------------------------------------------------------------------------------- |
| HLR‑01 | **Offline storage** (SQLite with optional SQLCipher) | Encryption off by default; user can enable biometric‑gated encryption                   |
| HLR‑02 | **Roles & auth**: manager (MVP), HR/admin (future)   | Local PIN/biometrics + optional local password; codebase OIDC‑ready (Apple, Google)     |
| HLR‑03 | **Hour allocation workflow**                         | Manager assigns project hours to employees; employees use another system to log actuals |
| HLR‑04 | **Configurable overtime rules**                      | Settings panel allows/forbids overtime per company policy                               |
| HLR‑05 | **Reports & export**                                 | In‑app views + export in CSV, Excel, PDF, and via email                                 |
| HLR‑06 | **Minimalist UI** black‑&‑white                      | No shadows or gradients                                                                 |
| HLR‑07 | **Local notifications** reminders                    | Optional; e.g., “You haven’t allocated hours today”                                     |
| HLR‑08 | **Future cloud integration hooks**                   | Clear data layer abstraction to plug into cloud/backends later                          |
| HLR‑09 | **Security & backup**                                | Compatible with device backup; encryption toggle                                        |
| HLR‑10 | **Extensible DB schema**                             | Designed for migration to Realm/remote DB                                               |
| HLR‑11 | **OIDC integration readiness**                       | Abstraction layer enables future Apple/Google sign‑in without breaking local flow       |

---

## 3 · Epics & User Stories

| Epic              | User Story                                                                                                                                    | MoSCoW | Status       |
| ----------------- | --------------------------------------------------------------------------------------------------------------------------------------------- | ------ | ------------ |
| Authentication    | As a **manager**, I unlock the app via Face ID, or optional username/password; future Apple/Google sign‑in ready                              | Must   | Done         |
| Hour Allocation   | As a **manager**, I assign project hours to employees                                                                                         | Must   | To Do        |
| Overtime Settings | As a **manager**, I configure whether overtime is allowed                                                                                     | Should | To Do        |
| Reporting         | As a **manager**, I export monthly hours as CSV/PDF/Excel                                                                                     | Must   | To Do        |
| User Storage      | As a **manager**, I can set a username and optional password; app auto‑opens if no password set; settings let me toggle password or wipe data | Must   | Done         |
| Notifications     | As a **manager**, I receive a local reminder if I haven’t allocated hours by 17:00                                                            | Could  | To Do        |
| Encryption Toggle | As a **manager**, I enable biometric encryption of local data                                                                                 | Could  | To Do        |
| Cloud‑Ready Layer | As a **developer**, I can swap the local DB with a remote API without rewriting UI                                                            | Should | To Do        |

---

## 4 · Milestones

| Sprint                     | Goal                                                 | Deliverable       |
| :------------------------- | :--------------------------------------------------- | :---------------- |
| 0 – Setup                  | Repo, skeleton, data layer abstraction               | Running build     |
| 1 – Core workflow          | Auth, hour allocation, list                          | Alpha             |
| 2 – Config & notifications | Overtime settings, local reminders                   | Beta              |
| 3 – Reporting & polish     | CSV/PDF/Excel export, UI polish, optional encryption | Release candidate |

---

## 5 · Technical Work Breakdown

### 5.1 Stack Choices

| Layer                | Technology                                         | Notes                                    |
| -------------------- | -------------------------------------------------- | ---------------------------------------- |
| **Mobile framework** | **Flutter 3.22 (Dart 3)**                          | Cross‑platform; portfolio learning goal  |
| **State management** | Riverpod 3                                         | Lightweight, testable DI                 |
| **Local DB**         | Drift (SQLite) + SQLCipher (opt)                   | Strongly typed DAOs; migration‑friendly  |
| **Reporting**        | `dart_pdf`, `excel`, `csv`                         | BSD/MIT; ≤ €20 plugins if needed         |
| **i18n**             | `flutter_localizations`, `intl`                    | IT + EN from MVP                         |
| **Biometrics**       | `local_auth`                                       | Face ID / BiometricPrompt                |
| **OIDC ready**       | `app_auth`, `google_sign_in`, `sign_in_with_apple` | Wrapped in AuthRepository; enabled later |
| **Notifications**    | `flutter_local_notifications`                      | Local scheduled alerts                   |
| **Testing**          | `flutter_test`, `mocktail`                         | Unit + widget tests                      |
| **CI/CD**            | GitHub Actions, `fastlane`                         | Free macOS runners                       |

### 5.2 Task Breakdown by Sprint Task Breakdown by Sprint

| Sprint                         | Key Tasks                                                                                                                                                                                                                                          |
| :----------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **0 – Setup**                  | ‑ **Fork ssoad/flutter\_riverpod\_clean\_architecture** to `comet-ts` · Rename bundle id & app name · Strip demo features · Switch theme to B\&W · Add Drift + SQLCipher deps (demo uses them already) · Configure GitHub Actions & fastlane stubs |
| **1 – Core workflow**          | ‑ **Implement auth (PIN/Biometrics + optional password) [DONE]** (Includes biometric authentication flow, pre-filling username, and robust navigation between Login and Register screens.) · **Local user storage CRUD [DONE]** · Define DB schema (projects, employees, levels, allocations) [DONE] · Write tests for DB schema [DONE] · CRUD screens for projects & employees [DONE] · Allocation screen with validation (≤8 h, budget)           |
| **2 – Config & notifications** | ‑ Settings screen (overtime toggle, encryption toggle) · Implement encryption wrapper in Drift · Schedule daily reminder via `flutter_local_notifications`                                                                                         |
| **3 – Reporting & polish**     | ‑ Export services (CSV, Excel, PDF) · Coverage dashboard (calendar + table) · UI final polish (B\&W theme) · Store localization IT/EN · Optional App Icon / Splash                                                                                 |

### 5.3 Future‑Proofing Hooks

* **Repository pattern** around DAOs allows swapping Drift with a GraphQL client (e.g., ferry) later.
* Platform‑agnostic **Data Transfer Objects** ready for REST/GraphQL.
* **Feature flags** via `riverpod` Providers to enable cloud sync modules when available.

## 6 · Decisions Log

| Date       | Decision                                                   | Rationale                                                |
| ---------- | ---------------------------------------------------------- | -------------------------------------------------------- |
| 2025‑07‑26 | Use SQLite w/ SQLCipher optional                           | Simplicity & future migration                            |
| 2025‑07‑26 | Portfolio‑first scope                                      | Demonstrate skills; remain usable for SMEs               |
| 2025‑07‑26 | **Framework: Flutter 3.22 + Riverpod + Drift**             | Learn Flutter; strong OSS ecosystem; easy cross‑platform |
| 2025‑07‑26 | **Template: ssoad/flutter\_riverpod\_clean\_architecture** | Latest, includes Riverpod & Drift, already Face ID ready |

## 7 · Next Actions

1. Integrate remaining missing dependencies (e.g., `local_auth`, `flutter_local_notifications`, OIDC libs if not already done).
2. Implement CRUD screens for projects & employees (from Sprint 1).
3. Implement Allocation screen with validation (from Sprint 1).
4. Begin Sprint 2 tasks: Settings screen (overtime toggle, encryption toggle) and local notifications.
