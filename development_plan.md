# Nestery Mobile Application: Comprehensive Phased Development Plan

This document outlines the phased development plan for the Nestery mobile application, designed to be directly executable by an AI Coder. It adheres strictly to the Final Consolidated Nestery FRS and incorporates findings from research conducted on May 23, 2025, regarding external APIs and best practices.

## Phase 1: Project Setup & Foundational Configuration

**Goal:** Establish the project structure, core dependencies, version control, and basic configuration for both the Flutter client and the backend server.

**Tasks:**

1.  **Task 1.1: Initialize Version Control (Git)**
    *   **Inputs:** Project Name (Nestery)
    *   **Outputs:** Initialized Git repository with a standard `.gitignore` file for Flutter and the chosen backend framework (e.g., Node.js/NestJS or Python/FastAPI).
    *   **Dependencies:** None
    *   **Security Considerations:** Ensure sensitive files (e.g., `.env`, secrets) are included in `.gitignore`.
    *   **Acceptance Criteria:** Git repository created and accessible; `.gitignore` correctly excludes platform-specific and sensitive files.

2.  **Task 1.2: Setup Backend Project Structure (e.g., NestJS)**
    *   **Inputs:** Chosen backend framework (e.g., NestJS with TypeScript).
    *   **Outputs:** Standard NestJS project structure (`src`, `test`, `node_modules`, `package.json`, `tsconfig.json`, etc.). Defined directory structure for modules (e.g., `auth`, `users`, `properties`, `bookings`, `integrations`, `core`).
    *   **Dependencies:** Node.js, npm/yarn, NestJS CLI.
    *   **Security Considerations:** None specific to this task, but structure should facilitate secure module organization.
    *   **Acceptance Criteria:** Backend project created with the specified framework and directory structure. Basic application boots up locally.

3.  **Task 1.3: Setup Flutter Client Project Structure**
    *   **Inputs:** Flutter SDK.
    *   **Outputs:** Standard Flutter project structure (`lib`, `test`, `android`, `ios`, `pubspec.yaml`, etc.). Defined directory structure within `lib` (e.g., `src/features`, `src/core`, `src/shared`, `src/config`, `src/app`).
    *   **Dependencies:** Flutter SDK, Dart.
    *   **Security Considerations:** None specific to this task.
    *   **Acceptance Criteria:** Flutter project created with the specified directory structure. Basic application runs on an emulator/device.

4.  **Task 1.4: Configure Linters and Formatters**
    *   **Inputs:** Backend framework linters (e.g., ESLint, Prettier for NestJS), Flutter linter (`analysis_options.yaml`).
    *   **Outputs:** Configured linter and formatter files (`.eslintrc.js`, `.prettierrc`, `analysis_options.yaml`) enforcing strict coding standards and best practices.
    *   **Dependencies:** Task 1.2, Task 1.3.
    *   **Security Considerations:** Linters can help identify potential security anti-patterns.
    *   **Acceptance Criteria:** Linters and formatters integrated into both projects. Running lint commands passes without errors on the initial boilerplate code.

5.  **Task 1.5: Setup Environment Configuration**
    *   **Inputs:** List of required environment variables (DB connection strings, API keys placeholders, JWT secrets placeholders, etc.).
    *   **Outputs:** Backend: `.env.example` file listing all variables with descriptions. Configuration module (e.g., using `@nestjs/config`) to load variables. Flutter: Configuration files (e.g., using `flutter_dotenv`) for managing environment-specific settings like API base URLs.
    *   **Dependencies:** Task 1.2, Task 1.3.
    *   **Security Considerations:** `.env` files must be in `.gitignore`. Emphasize secure handling of secrets in production (using secret managers, not env files).
    *   **Acceptance Criteria:** Environment variable loading mechanism implemented and tested in both client and backend. Example `.env` files created.

6.  **Task 1.6: Initial Dependency Installation & Verification**
    *   **Inputs:** List of core dependencies for backend (framework, ORM, config, basic utilities) and Flutter (state management - Riverpod, HTTP client - Dio, routing, basic UI components).
    *   **Outputs:** Updated `package.json` and `pubspec.yaml` with verified **latest stable, secure, and actively maintained** versions of core dependencies. Lock files (`package-lock.json`/`yarn.lock`, `pubspec.lock`).
    *   **Dependencies:** Task 1.2, Task 1.3, Research findings on package versions.
    *   **Security Considerations:** Verify dependencies for known vulnerabilities using tools like `npm audit` or checking vulnerability databases. Justify any non-latest versions if absolutely necessary.
    *   **Acceptance Criteria:** Core dependencies installed in both projects. Dependency versions verified against latest stable/secure releases. No critical vulnerabilities reported by audit tools.

## Phase 2: Authentication & User Management

**Goal:** Implement secure user registration, login, profile management, and role-based access control foundations.

**Tasks:**

1.  **Task 2.1: Implement Database Schema for Users & Auth**
    *   **Inputs:** Consolidated PostgreSQL schema definition (from FRS Section 5.1, incorporating Gemini/Manus elements for `users`, `auth_providers`, potentially `roles`, `permissions`).
    *   **Outputs:** Database migration files (using a tool like TypeORM migrations or Alembic) to create the necessary tables (`users`, `auth_providers`, etc.) with appropriate constraints and indexes.
    *   **Dependencies:** Phase 1 (Project Setup, DB connection configured).
    *   **Security Considerations:** Ensure password hashes are stored securely (e.g., bcrypt), sensitive PII is handled appropriately (encryption at rest if required by compliance).
    *   **Acceptance Criteria:** Migrations run successfully, creating the required tables and columns in the development database.

2.  **Task 2.2: Implement Backend User Registration Endpoint**
    *   **Inputs:** User registration data (email, password, name). Hashing library (bcrypt).
    *   **Outputs:** Backend API endpoint (`POST /v1/auth/register`) that validates input, hashes the password, creates a new user record in the database, and returns a success response or appropriate error.
    *   **Dependencies:** Task 2.1, Backend framework, ORM.
    *   **Security Considerations:** Strong input validation (email format, password complexity), rate limiting, protection against enumeration attacks.
    *   **Performance Targets:** Response time < 500ms under normal load.
    *   **Acceptance Criteria:** Endpoint functions correctly, validates input, creates user, stores hashed password, handles duplicate emails gracefully. Unit and integration tests pass.

3.  **Task 2.3: Implement Backend User Login Endpoint (Email/Password)**
    *   **Inputs:** User login credentials (email, password). Hashing library (bcrypt), JWT library.
    *   **Outputs:** Backend API endpoint (`POST /v1/auth/login`) that validates input, finds the user, compares the provided password with the stored hash, and issues JWT access and refresh tokens upon successful authentication.
    *   **Dependencies:** Task 2.1, Task 2.2, Backend framework, ORM, JWT library.
    *   **Security Considerations:** Input validation, rate limiting, secure JWT signing (strong secret, appropriate algorithm - e.g., HS256/RS256), short-lived access tokens, secure refresh token handling (e.g., stored securely, rotation).
    *   **Performance Targets:** Response time < 300ms under normal load.
    *   **Acceptance Criteria:** Endpoint functions correctly, validates credentials, issues tokens on success, returns appropriate errors on failure. Unit and integration tests pass.

4.  **Task 2.4: Implement Backend JWT Authentication Middleware/Guard**
    *   **Inputs:** JWT library, JWT secret.
    *   **Outputs:** Middleware or Guard (e.g., NestJS Guard) that intercepts incoming requests, validates the JWT access token from the Authorization header, extracts user information, and attaches it to the request object for authorized endpoints.
    *   **Dependencies:** Task 2.3.
    *   **Security Considerations:** Proper validation of token signature and expiration. Handling of invalid/expired tokens.
    *   **Acceptance Criteria:** Middleware/Guard correctly validates JWTs, protects secured endpoints, and allows access with valid tokens. Tests pass.

5.  **Task 2.5: Implement Backend Basic Role-Based Access Control (RBAC)**
    *   **Inputs:** User roles (e.g., 'user', 'admin', 'premium_user'). Database schema with user roles.
    *   **Outputs:** Backend decorators or guards to restrict access to specific endpoints based on user roles stored in the JWT or fetched from the database.
    *   **Dependencies:** Task 2.1, Task 2.4.
    *   **Security Considerations:** Ensure roles are correctly assigned and checked for all sensitive operations.
    *   **Acceptance Criteria:** RBAC mechanism implemented. Access to protected endpoints is correctly granted/denied based on user roles. Tests pass.

6.  **Task 2.6: Implement Flutter Authentication UI Screens**
    *   **Inputs:** UI/UX specifications (from FRS Section 5.3), Figma designs (assumed).
    *   **Outputs:** Flutter widgets/screens for Login and Registration, including input fields, buttons, and basic validation feedback.
    *   **Dependencies:** Phase 1 (Flutter Setup), UI/UX specs.
    *   **Acceptance Criteria:** Screens match the design specifications. Basic form structure implemented.

7.  **Task 2.7: Implement Flutter Authentication State Management (Riverpod)**
    *   **Inputs:** Riverpod state management library.
    *   **Outputs:** Riverpod providers (`StateNotifierProvider`, `FutureProvider`, etc.) to manage authentication state (loading, authenticated user, error), handle form input, and track login/registration progress.
    *   **Dependencies:** Task 2.6, Riverpod.
    *   **Acceptance Criteria:** State management logic implemented for auth screens. UI state updates correctly based on user actions and API responses.

8.  **Task 2.8: Implement Flutter API Client for Auth Endpoints**
    *   **Inputs:** Dio HTTP client library, Nestery Backend API base URL (from env config), Auth endpoint definitions (Task 2.2, 2.3).
    *   **Outputs:** Flutter service/repository class using Dio to make requests to the backend `/auth/register` and `/auth/login` endpoints. Includes basic error handling.
    *   **Dependencies:** Task 2.2, Task 2.3, Dio, Flutter Env Config.
    *   **Acceptance Criteria:** API client can successfully call backend auth endpoints. Responses are correctly parsed or errors handled.

9.  **Task 2.9: Integrate Flutter Auth UI, State, and API Client**
    *   **Inputs:** Components from Task 2.6, 2.7, 2.8.
    *   **Outputs:** Fully functional login and registration flow in the Flutter app. User can register, log in, receive tokens, and the app state reflects authentication status. Tokens are stored securely (e.g., using `flutter_secure_storage`).
    *   **Dependencies:** Task 2.6, 2.7, 2.8.
    *   **Security Considerations:** Secure storage of tokens on the client device.
    *   **Acceptance Criteria:** End-to-end login/registration flow works correctly. Tokens are securely stored and retrieved. App navigates appropriately based on auth state. Integration tests pass.

10. **Task 2.10: Implement Flutter Profile Management UI & Backend Endpoints**
    *   **Inputs:** User profile fields (name, email - potentially read-only, preferences placeholder). UI/UX specs.
    *   **Outputs:** Backend endpoints (`GET /v1/users/me`, `PUT /v1/users/me/profile`) protected by JWT auth. Flutter screen to display and update user profile information, integrated with state management and API client.
    *   **Dependencies:** Task 2.1, Task 2.4, Task 2.9.
    *   **Security Considerations:** Ensure users can only access/modify their own profile data (authorization checks on backend).
    *   **Acceptance Criteria:** User can view and update their profile information. Backend endpoints are secure and functional. Integration tests pass.

*(Plan will continue with subsequent phases: Backend Core Features, Frontend Core Features, External API Integrations, Monetization Features, Viral Growth Features, Advanced UVP Features, Testing, Observability, Deployment Prep, Documentation)*

## Assumptions

*   A specific backend framework (e.g., NestJS with TypeScript) and database (PostgreSQL) are chosen as per FRS suggestions.
*   A specific Flutter state management solution (Riverpod) is chosen as per FRS.
*   Standard development tools (Git, Node.js, Flutter SDK, Docker) are available in the AI Coder's environment.
*   Figma designs or detailed wireframes are available for UI implementation based on FRS Section 5.3.
*   Access to necessary third-party services (Booking.com partner program, Google Maps API keys) will be provisioned, although initial development can proceed with placeholders and mock data where feasible.
*   The AI Coder has the capability to execute shell commands, write/modify code files, run tests, and interact with databases and APIs as instructed.

