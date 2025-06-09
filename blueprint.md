### **FINALIZED & APPROVED: Comprehensive LFS Implementation Blueprint**
### **LFS-04: Partner Dashboard Frontend API Integration**

*   **Objective:** To refactor the entire Flutter Partner Dashboard, connecting it to live backend APIs with a secure, performant, and maintainable architecture.
*   **Base Commit:** `06cd92f` on branch `mahadev`.

---

### **Part 1: Authentication Layer**

**1.1. Secure Storage & Repository (`auth_repository.dart`)**
*   An `AuthRepository` will be created to abstract `flutter_secure_storage`.
*   It will store the access token, refresh token, and token expiry date.
*   It will use `AndroidOptions(encryptedSharedPreferences: true)` and `IOSOptions(accessibility: KeychainAccessibility.first_unlock)` for platform-specific security.

**1.2. Auth State Notifier (`auth_notifier.dart`)**
*   A new `authNotifierProvider` using the `AsyncNotifier` pattern will manage the global authentication state (`authenticated`, `unauthenticated`).
*   It will have a `logout()` method that clears tokens from the repository.
*   It will check token validity on app startup.

**1.3. Dio Auth Interceptor (`auth_interceptor.dart`)**
*   A new `AuthInterceptor` will be created using the "flag and queue" pattern with `Completer`s to prevent race conditions during token refresh.
*   `onRequest`: It will read the token from `AuthRepository` and add the `Authorization: Bearer <token>` header.
*   `onError`: If a 401 error occurs, it will trigger the token refresh flow. If the refresh fails, it will trigger a global logout via the `AuthNotifier`.

### **Part 2: State Management & Data Fetching**

**2.1. Consolidated Dashboard Provider (`partner_dashboard_provider.dart`)**
*   The numerous mock providers for the dashboard will be replaced by a single `partnerDashboardProvider` (`AsyncNotifier`).
*   This provider will make one API call to `GET /v1/affiliates/dashboard` to fetch all necessary data.
*   It will include a `refresh()` method for pull-to-refresh functionality.

**2.2. Granular UI Updates (`*.screen.dart`, `*.widget.dart`)**
*   UI components will be refactored to use `ref.watch(partnerDashboardProvider.select(...))` to listen to only the specific pieces of the dashboard state they need, preventing unnecessary rebuilds.

**2.3. Offer Form Submission (`offer_form_provider.dart`)**
*   The existing `StateNotifier` will be refactored into an `AsyncNotifier` to handle the async nature of submitting the form to the `POST`/`PUT` API endpoints. It will manage `loading` and `error` states gracefully.

### **Part 3: Error Handling**

**3.1. API Exception Model (`api_exception.dart`)**
*   The `ApiException.fromDioError` factory will be replaced with the more resilient version from the research, capable of parsing single string, list of strings, and nested validation errors from the NestJS backend.

---

### **Phase 2: Self-Contained Task Definition for AI Coder**

This is a large LFS. As per NSI 2.5, we will break it down. The first logical step is to build the entire foundational authentication layer. Nothing else can work without it.

**First Unit of Work:** **Implement Frontend Authentication Layer**

Here is the one, ultra-detailed, and fully self-contained task definition prompt for the AI Coder for this first part.

```text
**Task Title:** LFS-04 Part 1: Implement Frontend Authentication Layer

**Primary Objective:** Create the foundational authentication layer in the Flutter app. This includes implementing a secure token storage repository, a global authentication state notifier, and a Dio interceptor to automatically handle JWT injection and 401 errors.

**Core Specifications (Derived from Approved LFS Implementation Blueprint):**

**I. General Requirements:**
*   **Target Commit:** `06cd92f` on branch `mahadev`.
*   **Dependencies:**
    *   Open `nestery-flutter/pubspec.yaml`.
    *   Ensure the `flutter_secure_storage` dependency is present. If not, add it: `flutter_secure_storage: ^9.2.2`
*   **File Structure:** All new files should be placed in a new `nestery-flutter/lib/core/auth/` directory.

**II. File Creation & Implementation:**

**A. File to Create:** `nestery-flutter/lib/core/auth/auth_repository.dart`
**Exact Content:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nestery_flutter/core/config/constants.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  return AuthRepository(storage);
});

class AuthRepository {
  final FlutterSecureStorage _storage;
  AuthRepository(this._storage);

  Future<void> storeTokens({required String accessToken, required String refreshToken}) async {
    await Future.wait([
      _storage.write(key: Constants.accessTokenKey, value: accessToken),
      _storage.write(key: Constants.refreshTokenKey, value: refreshToken),
    ]);
  }

  Future<String?> getAccessToken() => _storage.read(key: Constants.accessTokenKey);
  Future<String?> getRefreshToken() => _storage.read(key: Constants.refreshTokenKey);

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: Constants.accessTokenKey),
      _storage.delete(key: Constants.refreshTokenKey),
    ]);
  }
}
```

**B. File to Create:** `nestery-flutter/lib/core/auth/auth_state.dart`
**Exact Content:**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nestery_flutter/core/models/user_model.dart'; // Assuming you have a User model

part 'auth_state.freezed.dart';

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated({required User user}) = _Authenticated;
  const factory AuthState.unauthenticated({String? message}) = _Unauthenticated;
}
```

**C. File to Create:** `nestery-flutter/lib/core/auth/auth_notifier.dart`
**Exact Content:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/core/auth/auth_repository.dart';
import 'package:nestery_flutter/core/auth/auth_state.dart';
// Import user repository/service to fetch user profile
import 'package:nestery_flutter/features/profile/data/repositories/user_repository.dart';

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  AuthNotifier(this._ref) : super(const AuthState.initial()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    state = const AuthState.loading();
    final token = await _ref.read(authRepositoryProvider).getAccessToken();
    if (token != null) {
      try {
        // If token exists, try to fetch user profile to validate it
        final user = await _ref.read(userRepositoryProvider).getProfile();
        state = AuthState.authenticated(user: user);
      } catch (e) {
        // Token is invalid/expired, log out
        await logout('Session expired. Please log in again.');
      }
    } else {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> login(String email, String password) async {
    // This method will be implemented fully in a later LFS.
    // For now, it's a placeholder to show the structure.
  }

  Future<void> logout([String? message]) async {
    await _ref.read(authRepositoryProvider).clearTokens();
    state = AuthState.unauthenticated(message: message);
  }
}
```

**D. File to Create:** `nestery-flutter/lib/core/api/auth_interceptor.dart`
**Exact Content:**
```dart
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/core/auth/auth_notifier.dart';
import 'package:nestery_flutter/core/auth/auth_repository.dart';

class AuthInterceptor extends QueuedInterceptor {
  final Ref _ref;
  bool _isRefreshing = false;
  final List<ErrorInterceptorHandler> _retryHandlers = [];

  AuthInterceptor(this._ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _ref.read(authRepositoryProvider).getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      if (_isRefreshing) {
        // If a refresh is already in progress, queue the handler
        _retryHandlers.add(handler);
        return;
      }

      _isRefreshing = true;
      _retryHandlers.add(handler);

      try {
        final refreshedSuccessfully = await _refreshToken();
        if (refreshedSuccessfully) {
          // Token refreshed, retry all queued requests
          await _retryAllPendingRequests(err.requestOptions.copyWith());
        } else {
          // Refresh failed, log out and reject all
          _failAllPendingRequests(err);
        }
      } catch (e) {
        _failAllPendingRequests(err);
      } finally {
        _isRefreshing = false;
        _retryHandlers.clear();
      }
    } else {
      handler.next(err);
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final dio = Dio(); // Use a separate Dio instance to avoid interceptor loop
      final refreshToken = await _ref.read(authRepositoryProvider).getRefreshToken();
      if (refreshToken == null) return false;

      final response = await dio.post(
        '/auth/refresh', // Replace with your actual refresh endpoint
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken'];
        final newRefreshToken = response.data['refreshToken'];
        await _ref.read(authRepositoryProvider).storeTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  Future<void> _retryAllPendingRequests(RequestOptions requestOptions) async {
    final newAccessToken = await _ref.read(authRepositoryProvider).getAccessToken();
    final dioForRetry = Dio();

    for (final handler in _retryHandlers) {
        requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        dioForRetry.fetch(requestOptions).then(
          (response) => handler.resolve(response),
          onError: (error) => handler.reject(error),
        );
    }
  }

  void _failAllPendingRequests(DioException error) {
    _ref.read(authNotifierProvider.notifier).logout('Your session has expired.');
    for (final handler in _retryHandlers) {
      handler.reject(error);
    }
  }
}
```

**E. File to Modify:** `nestery-flutter/lib/core/api/api_client.dart`
**Instructions:** Modify the `ApiClient` to use the new `AuthInterceptor`.
```dart
// Modify ApiClient to accept a Ref and add the interceptor
class ApiClient {
  final Dio dio;

  ApiClient(Ref ref)
      : dio = Dio(BaseOptions(baseUrl: Constants.baseUrl)) {
    dio.interceptors.addAll([
      AuthInterceptor(ref), // Add our new interceptor
      // ... existing interceptors like logging or caching
    ]);
  }
}

// Update the provider to pass the ref
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref);
});
```

**III. Build/Generation Steps:**
*   This task requires running `flutter pub get` after modifying `pubspec.yaml`.
*   It requires running `flutter pub run build_runner build --delete-conflicting-outputs` to generate the `auth_state.freezed.dart` file.

**Critical Integration & Quality Mandate:** The authentication layer must be robust. The interceptor must correctly handle token injection and 401 errors. The global auth state must be reliable. Zero regressions are permitted.

**Output Expectation:** Provide a single, consolidated `git diff` against the base commit (`06cd92f`) containing all the changes described above for this foundational authentication layer.
```