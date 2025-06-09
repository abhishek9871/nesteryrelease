Hello Augment Coder,

We are applying the foundational frontend authentication layer for LFS-04. This is a complex refactoring task involving precise file creation, modification, and deletion. Follow these steps sequentially and do not proceed to the next step until the current one is verified. Your goal is to make the project's state identical to the changes described in the provided `@diff.md` file.

Branch `mahadev`.

### Step 1: Update Dependencies ###
1.1. Open the file `nestery-flutter/pubspec.yaml`.
1.2. Locate the `flutter_secure_storage` dependency.
1.3. Ensure its version is exactly `^9.2.2`. If it is different, update it. If it is missing, add it.
1.4. VERIFY & REPORT: Confirm that the line `flutter_secure_storage: ^9.2.2` exists in `pubspec.yaml`.

### Step 2: Create New Directory Structure ###
2.1. Navigate to the `nestery-flutter/lib/core/` directory.
2.2. Create a new subdirectory named `auth`.
2.3. VERIFY & REPORT: Confirm that the directory `nestery-flutter/lib/core/auth/` now exists.

### Step 3: Create New Files ###
3.1. Create a new file at `nestery-flutter/lib/core/auth/auth_repository.dart`.
3.2. Paste the following exact content into the file:
     ```dart
     import 'package:flutter_riverpod/flutter_riverpod.dart';
     import 'package:flutter_secure_storage/flutter_secure_storage.dart';
     import 'package:nestery_flutter/utils/constants.dart';

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
3.3. Create a new file at `nestery-flutter/lib/core/auth/auth_state.dart`.
3.4. Paste the following exact content into the file:
     ```dart
     import 'package:freezed_annotation/freezed_annotation.dart';
     import 'package:nestery_flutter/models/user.dart'; 

     part 'auth_state.freezed.dart';

     @freezed
     sealed class AuthState with _$AuthState {
       const factory AuthState.initial() = _Initial;
       const factory AuthState.loading() = _Loading;
       const factory AuthState.authenticated({required User user}) = _Authenticated;
       const factory AuthState.unauthenticated({String? message}) = _Unauthenticated;
     }
     ```
3.5. Create a new file at `nestery-flutter/lib/core/auth/auth_notifier.dart`.
3.6. Paste the following exact content into the file:
     ```dart
     import 'package:flutter_riverpod/flutter_riverpod.dart';
     import 'package:nestery_flutter/core/auth/auth_repository.dart';
     import 'package:nestery_flutter/core/auth/auth_state.dart';
     import 'package:nestery_flutter/data/repositories/user_repository.dart';
     import 'package:nestery_flutter/providers/repository_providers.dart';

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
             final userEither = await _ref.read(userRepositoryProvider).getUserProfile();
             userEither.fold(
               (l) => throw l,
               (user) => state = AuthState.authenticated(user: user),
             );
           } catch (e) {
             await logout('Session expired. Please log in again.');
           }
         } else {
           state = const AuthState.unauthenticated();
         }
       }

       Future<void> login(String email, String password) async {
         // Placeholder for a future LFS
       }

       Future<void> logout([String? message]) async {
         await _ref.read(authRepositoryProvider).clearTokens();
         state = AuthState.unauthenticated(message: message);
       }
     }
     ```
3.7. Create a new file at `nestery-flutter/lib/core/api/auth_interceptor.dart`.
3.8. Paste the following exact content into the file:
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
             _retryHandlers.add(handler);
             return;
           }
           _isRefreshing = true;
           _retryHandlers.add(handler);
           try {
             final refreshedSuccessfully = await _refreshToken();
             if (refreshedSuccessfully) {
               await _retryAllPendingRequests(err.requestOptions.copyWith());
             } else {
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
           final dio = Dio();
           final refreshToken = await _ref.read(authRepositoryProvider).getRefreshToken();
           if (refreshToken == null) return false;
           final response = await dio.post('/auth/refresh', data: {'refreshToken': refreshToken});
           if (response.statusCode == 200) {
             final newAccessToken = response.data['accessToken'];
             final newRefreshToken = response.data['refreshToken'];
             await _ref.read(authRepositoryProvider).storeTokens(accessToken: newAccessToken, refreshToken: newRefreshToken);
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
3.9. VERIFY & REPORT: Confirm that all 4 new files have been created successfully in their correct directories.

### Step 4: Delete Obsolete File ###
4.1. Delete the file at `nestery-flutter/lib/data/repositories/auth_repository.dart`.
4.2. VERIFY & REPORT: Confirm that the file `auth_repository.dart` no longer exists in `lib/data/repositories/`.

### Step 5: Modify Existing Files ###
5.1. Open file `nestery-flutter/lib/core/network/api_client.dart`.
5.2. **Replace the entire content** of the file with the following code block. This refactors the class to use the new interceptor and simplifies it significantly.
     ```dart
     import 'package:dio/dio.dart';
     import 'package:flutter/foundation.dart';
     import 'package:flutter_riverpod/flutter_riverpod.dart';
     import 'package:nestery_flutter/core/api/auth_interceptor.dart';
     import 'package:nestery_flutter/utils/constants.dart';

     class ApiClient {
       final Dio dio;

       ApiClient(Ref ref)
           : dio = Dio(BaseOptions(
               baseUrl: Constants.apiBaseUrl,
               connectTimeout: const Duration(milliseconds: Constants.connectionTimeout),
               receiveTimeout: const Duration(milliseconds: Constants.receiveTimeout),
               headers: {
                 'Content-Type': 'application/json',
                 'Accept': 'application/json',
               },
             )) {
         dio.interceptors.addAll([
           AuthInterceptor(ref),
           if (kDebugMode)
             LogInterceptor(
               requestBody: true,
               responseBody: true,
             ),
         ]);
       }
     }
     ```
5.3. Open file `nestery-flutter/lib/providers/repository_providers.dart`.
5.4. **Replace the entire content** of the file with the following code block. This updates the `apiClientProvider` to correctly instantiate the new `ApiClient`.
     ```dart
     import 'package:flutter_riverpod/flutter_riverpod.dart';
     import 'package:nestery_flutter/core/network/api_client.dart';
     // ... other repository imports ...

     final apiClientProvider = Provider<ApiClient>((ref) {
       return ApiClient(ref);
     });

     // ... other existing repository providers ...
     ```
5.5. Open file `nestery-flutter/lib/main.dart`.
5.6. **Replace the entire content** of the file with the following code block. This removes the old complex `ProviderScope` override.
     ```dart
     import 'package:flutter/material.dart';
     import 'package:flutter_riverpod/flutter_riverpod.dart';
     import 'package:flutter_dotenv/flutter_dotenv.dart';
     import 'package:flutter_native_splash/flutter_native_splash.dart';
     import 'package:nestery_flutter/app.dart';
     import 'package:nestery_flutter/services/ad_service.dart';
     import 'package:nestery_flutter/utils/constants.dart';

     void main() async {
       WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
       FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
       
       await dotenv.load(fileName: ".env");
       Constants.initialize();
       
       FlutterNativeSplash.remove();

       runApp(
         ProviderScope(
           observers: [
             _AdServiceInitializer(),
           ],
           child: const NesteryApp(),
         ),
       );
     }

     class _AdServiceInitializer extends ProviderObserver {
       @override
       void didAddProvider(
         ProviderBase<Object?> provider,
         Object? value,
         ProviderContainer container,
       ) {
         if (provider == adServiceProvider) {
           container.read(adServiceProvider).initialize();
         }
       }
     }
     ```
5.7. VERIFY & REPORT: Confirm that all 3 files (`api_client.dart`, `repository_providers.dart`, `main.dart`) have been updated with the new content.

### Step 6: Run Build/Generation Commands ###
6.1. Navigate to the `nestery-flutter` directory.
6.2. Run `flutter pub get`.
6.3. VERIFY & REPORT: Confirm `pub get` completes successfully.
6.4. Run `flutter pub run build_runner build --delete-conflicting-outputs`.
6.5. VERIFY & REPORT: Did the build command succeed without errors? Does the file `nestery-flutter/lib/core/auth/auth_state.freezed.dart` now exist? **If it failed, STOP and report the full error.**

### Step 7: Final Verification ###
7.1. Run `flutter analyze`. Report any critical errors.
7.2. Run `flutter test`. Report if all tests pass.
7.3. Run `flutter build apk --debug`. Report if the build is successful.
7.4. Run `flutter run` on an emulator/device. Report if the app starts without crashing.
7.5. **Final Sanity Check:** Compare the final state of the entire project against the provided `@diff.md` file. Report if there are any discrepancies. This final check ensures perfect application.
7.6. VERIFY & REPORT: Confirm the outcome of all verification steps. Is the implementation now 100% identical to the provided diff in the @diff.md file?