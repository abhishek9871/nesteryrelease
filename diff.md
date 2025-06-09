diff --git a/nestery-flutter/lib/core/api/auth_interceptor.dart b/nestery-flutter/lib/core/api/auth_interceptor.dart
new file mode 100644
index 0000000..f544975
--- /dev/null
+++ b/nestery-flutter/lib/core/api/auth_interceptor.dart
@@ -0,0 +1,93 @@
+import 'dart:async';
+import 'package:dio/dio.dart';
+import 'package:flutter_riverpod/flutter_riverpod.dart';
+import 'package:nestery_flutter/core/auth/auth_notifier.dart';
+import 'package:nestery_flutter/core/auth/auth_repository.dart';
+
+class AuthInterceptor extends QueuedInterceptor {
+  final Ref _ref;
+  bool _isRefreshing = false;
+  final List<ErrorInterceptorHandler> _retryHandlers = [];
+
+  AuthInterceptor(this._ref);
+
+  @override
+  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
+    final token = await _ref.read(authRepositoryProvider).getAccessToken();
+    if (token != null) {
+      options.headers['Authorization'] = 'Bearer $token';
+    }
+    handler.next(options);
+  }
+
+  @override
+  void onError(DioException err, ErrorInterceptorHandler handler) async {
+    if (err.response?.statusCode == 401) {
+      if (_isRefreshing) {
+        // If a refresh is already in progress, queue the handler
+        _retryHandlers.add(handler);
+        return;
+      }
+
+      _isRefreshing = true;
+      _retryHandlers.add(handler);
+
+      try {
+        final refreshedSuccessfully = await _refreshToken();
+        if (refreshedSuccessfully) {
+          // Token refreshed, retry all queued requests
+          await _retryAllPendingRequests(err.requestOptions.copyWith());
+        } else {
+          // Refresh failed, log out and reject all
+          _failAllPendingRequests(err);
+        }
+      } catch (e) {
+        _failAllPendingRequests(err);
+      } finally {
+        _isRefreshing = false;
+        _retryHandlers.clear();
+      }
+    } else {
+      handler.next(err);
+    }
+  }
+
+  Future<bool> _refreshToken() async {
+    try {
+      final dio = Dio(); // Use a separate Dio instance to avoid interceptor loop
+      final refreshToken = await _ref.read(authRepositoryProvider).getRefreshToken();
+      if (refreshToken == null) return false;
+
+      final response = await dio.post(
+        '/auth/refresh', // Replace with your actual refresh endpoint
+        data: {'refreshToken': refreshToken},
+      );
+
+      if (response.statusCode == 200) {
+        final newAccessToken = response.data['accessToken'];
+        final newRefreshToken = response.data['refreshToken'];
+        await _ref.read(authRepositoryProvider).storeTokens(
+          accessToken: newAccessToken,
+          refreshToken: newRefreshToken,
+        );
+        return true;
+      }
+      return false;
+    } catch (e) {
+      return false;
+    }
+  }
+  
+  Future<void> _retryAllPendingRequests(RequestOptions requestOptions) async {
+    final newAccessToken = await _ref.read(authRepositoryProvider).getAccessToken();
+    final dioForRetry = Dio();
+
+    for (final handler in _retryHandlers) {
+        requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
+        dioForRetry.fetch(requestOptions).then(
+          (response) => handler.resolve(response),
+          onError: (error) => handler.reject(error),
+        );
+    }
+  }
+
+  void _failAllPendingRequests(DioException error) {
+    _ref.read(authNotifierProvider.notifier).logout('Your session has expired.');
+    for (final handler in _retryHandlers) {
+      handler.reject(error);
+    }
+  }
+}
diff --git a/nestery-flutter/lib/core/auth/auth_notifier.dart b/nestery-flutter/lib/core/auth/auth_notifier.dart
new file mode 100644
index 0000000..8031350
--- /dev/null
+++ b/nestery-flutter/lib/core/auth/auth_notifier.dart
@@ -0,0 +1,46 @@
+import 'package:flutter_riverpod/flutter_riverpod.dart';
+import 'package:nestery_flutter/core/auth/auth_repository.dart';
+import 'package:nestery_flutter/core/auth/auth_state.dart';
+// Import user repository/service to fetch user profile
+import 'package:nestery_flutter/data/repositories/user_repository.dart';
+import 'package:nestery_flutter/providers/repository_providers.dart';
+
+final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
+  return AuthNotifier(ref);
+});
+
+class AuthNotifier extends StateNotifier<AuthState> {
+  final Ref _ref;
+  AuthNotifier(this._ref) : super(const AuthState.initial()) {
+    checkAuthStatus();
+  }
+
+  Future<void> checkAuthStatus() async {
+    state = const AuthState.loading();
+    final token = await _ref.read(authRepositoryProvider).getAccessToken();
+    if (token != null) {
+      try {
+        // If token exists, try to fetch user profile to validate it
+        final userEither = await _ref.read(userRepositoryProvider).getUserProfile();
+        userEither.fold(
+          (l) => throw l,
+          (user) => state = AuthState.authenticated(user: user),
+        );
+      } catch (e) {
+        // Token is invalid/expired, log out
+        await logout('Session expired. Please log in again.');
+      }
+    } else {
+      state = const AuthState.unauthenticated();
+    }
+  }
+
+  Future<void> login(String email, String password) async {
+    // This method will be implemented fully in a later LFS.
+    // For now, it's a placeholder to show the structure.
+  }
+
+  Future<void> logout([String? message]) async {
+    await _ref.read(authRepositoryProvider).clearTokens();
+    state = AuthState.unauthenticated(message: message);
+  }
+}
diff --git a/nestery-flutter/lib/core/auth/auth_repository.dart b/nestery-flutter/lib/core/auth/auth_repository.dart
new file mode 100644
index 0000000..9058729
--- /dev/null
+++ b/nestery-flutter/lib/core/auth/auth_repository.dart
@@ -0,0 +1,32 @@
+import 'package:flutter_riverpod/flutter_riverpod.dart';
+import 'package:flutter_secure_storage/flutter_secure_storage.dart';
+import 'package:nestery_flutter/utils/constants.dart';
+
+final authRepositoryProvider = Provider<AuthRepository>((ref) {
+  const storage = FlutterSecureStorage(
+    aOptions: AndroidOptions(encryptedSharedPreferences: true),
+    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
+  );
+  return AuthRepository(storage);
+});
+
+class AuthRepository {
+  final FlutterSecureStorage _storage;
+  AuthRepository(this._storage);
+
+  Future<void> storeTokens({required String accessToken, required String refreshToken}) async {
+    await Future.wait([
+      _storage.write(key: Constants.accessTokenKey, value: accessToken),
+      _storage.write(key: Constants.refreshTokenKey, value: refreshToken),
+    ]);
+  }
+
+  Future<String?> getAccessToken() => _storage.read(key: Constants.accessTokenKey);
+  Future<String?> getRefreshToken() => _storage.read(key: Constants.refreshTokenKey);
+
+  Future<void> clearTokens() async {
+    await Future.wait([
+      _storage.delete(key: Constants.accessTokenKey),
+      _storage.delete(key: Constants.refreshTokenKey),
+    ]);
+  }
+}
diff --git a/nestery-flutter/lib/core/auth/auth_state.dart b/nestery-flutter/lib/core/auth/auth_state.dart
new file mode 100644
index 0000000..2321852
--- /dev/null
+++ b/nestery-flutter/lib/core/auth/auth_state.dart
@@ -0,0 +1,11 @@
+import 'package:freezed_annotation/freezed_annotation.dart';
+import 'package:nestery_flutter/models/user.dart'; 
+
+part 'auth_state.freezed.dart';
+
+@freezed
+sealed class AuthState with _$AuthState {
+  const factory AuthState.initial() = _Initial;
+  const factory AuthState.loading() = _Loading;
+  const factory AuthState.authenticated({required User user}) = _Authenticated;
+  const factory AuthState.unauthenticated({String? message}) = _Unauthenticated;
+}
diff --git a/nestery-flutter/lib/core/auth/auth_state.freezed.dart b/nestery-flutter/lib/core/auth/auth_state.freezed.dart
new file mode 100644
index 0000000..7484439
--- /dev/null
+++ b/nestery-flutter/lib/core/auth/auth_state.freezed.dart
@@ -0,0 +1,288 @@
+// coverage:ignore-file
+// GENERATED CODE - DO NOT MODIFY BY HAND
+// ignore_for_file: type=lint
+// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark
+
+part of 'auth_state.dart';
+
+// **************************************************************************
+// FreezedGenerator
+// **************************************************************************
+
+T _$identity<T>(T value) => value;
+
+final _privateConstructorUsedError = UnsupportedError(
+    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-a-new-constructor-to-a-class');
+
+/// @nodoc
+mixin _$AuthState {
+  @optionalTypeArgs
+  TResult when<TResult extends Object?>({
+    required TResult Function() initial,
+    required TResult Function() loading,
+    required TResult Function(User user) authenticated,
+    required TResult Function(String? message) unauthenticated,
+  }) =>
+      throw _privateConstructorUsedError;
+  @optionalTypeArgs
+  TResult? whenOrNull<TResult extends Object?>({
+    TResult? Function()? initial,
+    TResult? Function()? loading,
+    TResult? Function(User user)? authenticated,
+    TResult? Function(String? message)? unauthenticated,
+  }) =>
+      throw _privateConstructorUsedError;
+  @optionalTypeArgs
+  TResult maybeWhen<TResult extends Object?>({
+    TResult Function()? initial,
+    TResult Function()? loading,
+    TResult Function(User user)? authenticated,
+    TResult Function(String? message)? unauthenticated,
+    required TResult orElse(),
+  }) =>
+      throw _privateConstructorUsedError;
+  @optionalTypeArgs
+  TResult map<TResult extends Object?>({
+    required TResult Function(_Initial value) initial,
+    required TResult Function(_Loading value) loading,
+    required TResult Function(_Authenticated value) authenticated,
+    required TResult Function(_Unauthenticated value) unauthenticated,
+  }) =>
+      throw _privateConstructorUsedError;
+  @optionalTypeArgs
+  TResult? mapOrNull<TResult extends Object?>({
+    TResult? Function(_Initial value)? initial,
+    TResult? Function(_Loading value)? loading,
+    TResult? Function(_Authenticated value)? authenticated,
+    TResult? Function(_Unauthenticated value)? unauthenticated,
+  }) =>
+      throw _privateConstructorUsedError;
+  @optionalTypeArgs
+  TResult maybeMap<TResult extends Object?>({
+    TResult Function(_Initial value)? initial,
+    TResult Function(_Loading value)? loading,
+    TResult Function(_Authenticated value)? authenticated,
+    TResult Function(_Unauthenticated value)? unauthenticated,
+    required TResult orElse(),
+  }) =>
+      throw _privateConstructorUsedError;
+}
+
+/// @nodoc
+abstract class $AuthStateCopyWith<$Res> {
+  factory $AuthStateCopyWith(AuthState value, $Res Function(AuthState) then) =
+      _$AuthStateCopyWithImpl<$Res, AuthState>;
+}
+
+/// @nodoc
+class _$AuthStateCopyWithImpl<$Res, $Val extends AuthState>
+    implements $AuthStateCopyWith<$Res> {
+  _$AuthStateCopyWithImpl(this._value, this._then);
+
+  // ignore: unused_field
+  final $Val _value;
+  // ignore: unused_field
+  final $Res Function($Val) _then;
+}
+
+/// @nodoc
+abstract class _$$InitialImplCopyWith<$Res> {
+  factory _$$InitialImplCopyWith(
+          _$InitialImpl value, $Res Function(_$InitialImpl) then) =
+      __$$InitialImplCopyWithImpl<$Res>;
+}
+
+/// @nodoc
+class __$$InitialImplCopyWithImpl<$Res>
+    extends _$AuthStateCopyWithImpl<$Res, _$InitialImpl>
+    implements _$$InitialImplCopyWith<$Res> {
+  __$$InitialImplCopyWithImpl(
+      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
+      : super(_value, _then);
+}
+
+/// @nodoc
+
+class _$InitialImpl implements _Initial {
+  const _$InitialImpl();
+
+  @override
+  String toString() {
+    return 'AuthState.initial()';
+  }
+
+  @override
+  bool operator ==(Object other) {
+    return identical(this, other) ||
+        (other.runtimeType == runtimeType && other is _$InitialImpl);
+  }
+
+  @override
+  int get hashCode => runtimeType.hashCode;
+
+  @override
+  @optionalTypeArgs
+  TResult when<TResult extends Object?>({
+    required TResult Function() initial,
+    required TResult Function() loading,
+    required TResult Function(User user) authenticated,
+    required TResult Function(String? message) unauthenticated,
+  }) {
+    return initial();
+  }
+
+  @override
+  @optionalTypeArgs
+  TResult? whenOrNull<TResult extends Object?>({
+    TResult? Function()? initial,
+    TResult? Function()? loading,
+    TResult? Function(User user)? authenticated,
+    TResult? Function(String? message)? unauthenticated,
+  }) {
+    return initial?.call();
+  }
+
+  @override
+  @optionalTypeArgs
+  TResult maybeWhen<TResult extends Object?>({
+    TResult Function()? initial,
+    TResult Function()? loading,
+    TResult Function(User user)? authenticated,
+    TResult Function(String? message)? unauthenticated,
+    required TResult orElse(),
+  }) {
+    if (initial != null) {
+      return initial();
+    }
+    return orElse();
+  }
+
+  @override
+  @optionalTypeArgs
+  TResult map<TResult extends Object?>({
+    required TResult Function(_Initial value) initial,
+    required TResult Function(_Loading value) loading,
+    required TResult Function(_Authenticated value) authenticated,
+    required TResult Function(_Unauthenticated value) unauthenticated,
+  }) {
+    return initial(this);
+  }
+
+  @override
+  @optionalTypeArgs
+  TResult? mapOrNull<TResult extends Object?>({
+    TResult? Function(_Initial value)? initial,
+    TResult? Function(_Loading value)? loading,
+    TResult? Function(_Authenticated value)? authenticated,
+    TResult? Function(_Unauthenticated value)? unauthenticated,
+  }) {
+    return initial?.call(this);
+  }
+
+  @override
+  @optionalTypeArgs
+  TResult maybeMap<TResult extends Object?>({
+    TResult Function(_Initial value)? initial,
+    TResult Function(_Loading value)? loading,
+    TResult Function(_Authenticated value)? authenticated,
+    TResult Function(_Unauthenticated value)? unauthenticated,
+    required TResult orElse(),
+  }) {
+    if (initial != null) {
+      return initial(this);
+    }
+    return orElse();
+  }
+}
+
+abstract class _Initial implements AuthState {
+  const factory _Initial() = _$InitialImpl;
+}
+
+/// @nodoc
+abstract class _$$LoadingImplCopyWith<$Res> {
+  factory _$$LoadingImplCopyWith(
+          _$LoadingImpl value, $Res Function(_$LoadingImpl) then) =
+      __$$LoadingImplCopyWithImpl<$Res>;
+}
+
+/// @nodoc
+class __$$LoadingImplCopyWithImpl<$Res>
+    extends _$AuthStateCopyWithImpl<$Res, _$LoadingImpl>
+    implements _$$LoadingImplCopyWith<$Res> {
+  __$$LoadingImplCopyWithImpl(
+      _$LoadingImpl _value, $Res Function(_$LoadingImpl) _then)
+      : super(_value, _then);
+}
+
+/// @nodoc
+
+class _$LoadingImpl implements _Loading {
+  const _$LoadingImpl();
+
+  @override
+  String toString() {
+    return 'AuthState.loading()';
+  }
+
+  @override
+  bool operator ==(Object other) {
+    return identical(this, other) ||
+        (other.runtimeType == runtimeType && other is _$LoadingImpl);
+  }
+
+  @override
+  int get hashCode => runtimeType.hashCode;
+
+  @override
+  @optionalTypeArgs
+  TResult when<TResult extends Object?>({
+    required TResult Function() initial,
+    required TResult Function() loading,
+    required TResult Function(User user) authenticated,
+    required TResult Function(String? message) unauthenticated,
+  }) {
+    return loading();
+  }
+
+  @override
+  @optionalTypeArgs
+  TResult? whenOrNull<TResult extends Object?>({
+    TResult? Function()? initial,
+    TResult? Function()? loading,
+    TResult? Function(User user)? authenticated,
+    TResult? Function(String? message)? unauthenticated,
+  }) {
+    return loading?.call();
+  }
+
+  @override
+  @optionalTypeArgs
+  TResult maybeWhen<TResult extends Object?>({
+    TResult Function()? initial,
+    TResult Function()? loading,
+    TResult Function(User user)? authenticated,
+    TResult Function(String? message)? unauthenticated,
+    required TResult orElse(),
+  }) {
+    if (loading != null) {
+      return loading();
+    }
+    return orElse();
+  }
+
+  @override
+  @optionalTypeArgs
+  TResult map<TResult extends Object?>({
+    required TResult Function(_Initial value) initial,
+    required TResult Function(_Loading value) loading,
+    required TResult Function(_Authenticated value) authenticated,
+    required TResult Function(_Unauthenticated value) unauthenticated,
+  }) {
+    return loading(this);
+  }
+
+  @override
+  @optionalTypeArgs
+  TResult? mapOrNull<TResult extends Object?>({
+    TResult? Function(_Initial value)? initial,
+    TResult? Function(_Loading value)? loading,
+    TResult? Function(_Authenticated value)? authenticated,
+    TResult? Function(_Unauthenticated value)? unauthenticated,
+  }) {
+    return loading?.call(this);
+  }
+
+  @override
+  @optionalTypeArgs
+  TResult maybeMap<TResult extends Object?>({
+    TResult Function(_Initial value)? initial,
+    TResult Function(_Loading value)? loading,
+    TResult Function(_Authenticated value)? authenticated,
+    TResult Function(_Unauthenticated value)? unauthenticated,
+    required TResult orElse(),
+  }) {
+    if (loading != null) {
+      return loading(this);
+    }
+    return orElse();
+  }
+}
+
+abstract class _Loading implements AuthState {
+  const factory _Loading() = _$LoadingImpl;
+}
+
+/// @nodoc
+abstract class _$$AuthenticatedImplCopyWith<$Res> {
+  factory _$$AuthenticatedImplCopyWith(_$AuthenticatedImpl value,
+          $Res Function(_$AuthenticatedImpl) then) =
+      __$$AuthenticatedImplCopyWithImpl<$Res>;
+  @useResult
+  $Res call({User user});
+}
+
+/// @nodoc
+class __$$AuthenticatedImplCopyWithImpl<$Res>
+    extends _$AuthStateCopyWithImpl<$Res, _$AuthenticatedImpl>
+    implements _$$AuthenticatedImplCopyWith<$Res> {
+  __$$AuthenticatedImplCopyWithImpl(
+      _$AuthenticatedImpl _value, $Res Function(_$AuthenticatedImpl) _then)
+      : super(_value, _then);
+
+  @pragma('vm:prefer-inline')
+  @override
+  $Res call({
+    Object? user = null,
+  }) {
+    return _then(_$AuthenticatedImpl(
+      user: null == user
+          ? _value.user
+          : user // ignore: cast_nullable_to_non_nullable
+              as User,
+    ));
+  }
+}
+
+/// @nodoc
+
+class _$AuthenticatedImpl implements _Authenticated {
+  const _$AuthenticatedImpl({required this.user});
+
+  @override
+  final User user;
+
+  @override
+  String toString() {
+    return 'AuthState.authenticated(user: $user)';
+  }
+
+  @override
+  bool operator ==(Object other) {
+    return identical(this, other) ||
+        (other.runtimeType == runtimeType &&
+            other is _$AuthenticatedImpl &&
+            (identical(other.user, user) || other.user == user));
+  }
+
+  @override
+  int get hashCode => Object.hash(runtimeType, user);
+
+  @JsonKey(ignore: true)
+  @override
+  @pragma('vm:prefer-inline')
+  _$$AuthenticatedImplCopyWith<_$AuthenticatedImpl> get copyWith =>
+      __$$AuthenticatedImplCopyWithImpl<_$AuthenticatedImpl>(this, _$identity);
+
+  @override
+  @optionalTypeArgs
+  TResult when<TResult extends Object?>({
+    required TResult Function() initial,
+    required TResult Function() loading,
+    required TResult Function(User user) authenticated,
+    required TResult Function(String? message) unauthenticated,
+  }) {
+    return authenticated(user);
+  }
+
+  @override
+  @optionalTypeArgs
+  TResult? whenOrNull<TResult extends Object?>({
+    TResult? Function()? initial,
+    TResult? Function()? loading,
+    TResult? Function(User user)? authenticated,
+    TResult? Function(String? message)? unauthenticated,
+  }) {
+    return authenticated?.call(user);
+  }
+
+  @override
+  @optionalTypeArgs
+  TResult maybeWhen<TResult extends Object?>({
+    TResult Function()? initial,
+    TResult Function()? loading,
+    TResult Function(User user)? authenticated,
+    TResult Function(String? message)? unauthenticated,
+    required TResult orElse(),
+  }) {
+    if (authenticated != null) {
+      return authenticated(user);
+    }
+    return orElse();
+  }
+
+  @override
+  @optionalTypeArgs
+  TResult map<TResult extends Object?>({
+    required TResult Function(_Initial value) initial,
+    required TResult Function(_Loading value) loading,
+    required TResult Function(_Authenticated value) authenticated,
+    required TResult Function(_Unauthenticated value) unauthenticated,
+  }) {
+    return authenticated(this);
+  }
+
+  @override
+  @optionalTypeArgs
+  TResult? mapOrNull<TResult extends Object?>({
+    TResult? Function(_Initial value)? initial,
+    TResult? Function(_Loading value)? loading,
+    TResult? Function(_Authenticated value)? authenticated,
+    TResult? Function(_Unauthenticated value)? unauthenticated,
+  }) {
+    return authenticated?.call(this);
+  }
+
+  @override
+  @optionalTypeArgs
+  TResult maybeMap<TResult extends Object?>({
+    TResult Function(_Initial value)? initial,
+    TResult Function(_Loading value)? loading,
+    TResult Function(_Authenticated value)? authenticated,
+    TResult Function(_Unauthenticated value)? unauthenticated,
+    required TResult orElse(),
+  }) {
+    if (authenticated != null) {
+      return authenticated(this);
+    }
+    return orElse();
+  }
+}
+
+abstract class _Authenticated implements AuthState {
+  const factory _Authenticated({required final User user}) =
+      _$AuthenticatedImpl;
+
+  User get user;
+  @JsonKey(ignore: true)
+  _$$AuthenticatedImplCopyWith<_$AuthenticatedImpl> get copyWith =>
+      throw _privateConstructorUsedError;
+}
+
+/// @nodoc
+abstract class _$$UnauthenticatedImplCopyWith<$Res> {
+  factory _$$UnauthenticatedImplCopyWith(_$UnauthenticatedImpl value,
+          $Res Function(_$UnauthenticatedImpl) then) =
+      __$$UnauthenticatedImplCopyWithImpl<$Res>;
+  @useResult
+  $Res call({String? message});
+}
+
+/// @nodoc
+class __$$UnauthenticatedImplCopyWithImpl<$Res>
+    extends _$AuthStateCopyWithImpl<$Res, _$UnauthenticatedImpl>
+    implements _$$UnauthenticatedImplCopyWith<$Res> {
+  __$$UnauthenticatedImplCopyWithImpl(
+      _$UnauthenticatedImpl _value, $Res Function(_$UnauthenticatedImpl) _then)
+      : super(_value, _then);
+
+  @pragma('vm:prefer-inline')
+  @override
+  $Res call({
+    Object? message = freezed,
+  }) {
+    return _then(_$UnauthenticatedImpl(
+      message: freezed == message
+          ? _value.message
+          : message // ignore: cast_nullable_to_non_nullable
+              as String?,
+    ));
+  }
+}
+
+/// @nodoc
+
+class _$UnauthenticatedImpl implements _Unauthenticated {
+  const _$UnauthenticatedImpl({this.message});
+
+  @override
+  final String? message;
+
+  @override
+  String toString() {
+    return 'AuthState.unauthenticated(message: $message)';
+  }
+
+  @override
+  bool operator ==(Object other) {
+    return identical(this, other) ||
+        (other.runtimeType == runtimeType &&
+            other is _$UnauthenticatedImpl &&
+            (identical(other.message, message) || other.message == message));
+  }
+
+  @override
+  int get hashCode => Object.hash(runtimeType, message);
+
+  @JsonKey(ignore: true)
+  @override
+  @pragma('vm:prefer-inline')
+  _$$UnauthenticatedImplCopyWith<_$UnauthenticatedImpl> get copyWith =>
+      __$$UnauthenticatedImplCopyWithImpl<_$UnauthenticatedImpl>(
+          this, _$identity);
+
+  @override
+  @optionalTypeArgs
+  TResult when<TResult extends Object?>({
+    required TResult Function() initial,
+    required TResult Function() loading,
+    required TResult Function(User user) authenticated,
+    required TResult Function(String? message) unauthenticated,
+  }) {
+    return unauthenticated(message);
+  }
+
+  @override
+  @optionalTypeArgs
+  TResult? whenOrNull<TResult extends Object?>({
+    TResult? Function()? initial,
+    TResult? Function()? loading,
+    TResult? Function(User user)? authenticated,
+    TResult? Function(String? message)? unauthenticated,
+  }) {
+    return unauthenticated?.call(message);
+  }
+
+  @override
+  @optionalTypeArgs
+  TResult maybeWhen<TResult extends Object?>({
+    TResult Function()? initial,
+    TResult Function()? loading,
+    TResult Function(User user)? authenticated,
+    TResult Function(String? message)? unauthenticated,
+    required TResult orElse(),
+  }) {
+    if (unauthenticated != null) {
+      return unauthenticated(message);
+    }
+    return orElse();
+  }
+
+  @override
+  @optionalTypeArgs
+  TResult map<TResult extends Object?>({
+    required TResult Function(_Initial value) initial,
+    required TResult Function(_Loading value) loading,
+    required TResult Function(_Authenticated value) authenticated,
+    required TResult Function(_Unauthenticated value) unauthenticated,
+  }) {
+    return unauthenticated(this);
+  }
+
+  @override
+  @optionalTypeArgs
+  TResult? mapOrNull<TResult extends Object?>({
+    TResult? Function(_Initial value)? initial,
+    TResult? Function(_Loading value)? loading,
+    TResult? Function(_Authenticated value)? authenticated,
+    TResult? Function(_Unauthenticated value)? unauthenticated,
+  }) {
+    return unauthenticated?.call(this);
+  }
+
+  @override
+  @optionalTypeArgs
+  TResult maybeMap<TResult extends Object?>({
+    TResult Function(_Initial value)? initial,
+    TResult Function(_Loading value)? loading,
+    TResult Function(_Authenticated value)? authenticated,
+    TResult Function(_Unauthenticated value)? unauthenticated,
+    required TResult orElse(),
+  }) {
+    if (unauthenticated != null) {
+      return unauthenticated(this);
+    }
+    return orElse();
+  }
+}
+
+abstract class _Unauthenticated implements AuthState {
+  const factory _Unauthenticated({final String? message}) =
+      _$UnauthenticatedImpl;
+
+  String? get message;
+  @JsonKey(ignore: true)
+  _$$UnauthenticatedImplCopyWith<_$UnauthenticatedImpl> get copyWith =>
+      throw _privateConstructorUsedError;
+}
diff --git a/nestery-flutter/lib/core/network/api_client.dart b/nestery-flutter/lib/core/network/api_client.dart
index 4519961..5735163 100644
--- a/nestery-flutter/lib/core/network/api_client.dart
+++ b/nestery-flutter/lib/core/network/api_client.dart
@@ -1,189 +1,100 @@
 import 'package:dio/dio.dart';
 import 'package:flutter/foundation.dart';
-import 'package:flutter_secure_storage/flutter_secure_storage.dart';
+import 'package:flutter_riverpod/flutter_riverpod.dart';
+import 'package:nestery_flutter/core/api/auth_interceptor.dart';
 import 'package:nestery_flutter/utils/constants.dart';
-import 'package:nestery_flutter/utils/api_exception.dart';
-import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
-import 'package:http_cache_drift_store/http_cache_drift_store.dart';
-import 'package:path_provider/path_provider.dart';
-import 'package:path/path.dart' as p;
 
 class ApiClient {
-  static ApiClient? _instance;
-  late final Dio _dio;
-  final FlutterSecureStorage _secureStorage;
-
-  // Cache specific fields
-  late final DriftCacheStore _cacheStore;
-  late final DioCacheInterceptor dioCacheInterceptor;
-
-  ApiClient._internal({FlutterSecureStorage? secureStorage})
-      : _secureStorage = secureStorage ?? const FlutterSecureStorage() {
-    _dio = Dio();
-    _setupDio();
-    _setupInterceptors();
-  }
-
-  factory ApiClient({FlutterSecureStorage? secureStorage}) {
-    _instance ??= ApiClient._internal(secureStorage: secureStorage);
-    return _instance!;
-  }
-
-  DriftCacheStore get cacheStore => _cacheStore;
-
-  /// Initializes the cache. Must be called after ApiClient instantiation and before first API call.
-  Future<void> initializeCache() async {
-    final documentsDir = await getApplicationDocumentsDirectory();
-    final dbPath = p.join(documentsDir.path, Constants.cacheDbName);
-
-    _cacheStore = DriftCacheStore(
-      databasePath: dbPath,
-    );
-
-    final globalCacheOptions = CacheOptions(
-      store: _cacheStore,
-      policy: CachePolicy.request, // Default policy
-      maxStale: Constants.defaultCacheTTL, // Default TTL for cached items
-      hitCacheOnErrorCodes: [500], // Use cache on error for these codes
-      hitCacheOnNetworkFailure: true, // Use cache on network failure
-      priority: CachePriority.normal,
-      cipher: null, // No encryption by default
-      keyBuilder: CacheOptions.defaultCacheKeyBuilder, // Default cache key builder
-    );
-
-    dioCacheInterceptor = DioCacheInterceptor(options: globalCacheOptions);
-    _dio.interceptors.add(dioCacheInterceptor);
-  }
-
-  void _setupDio() {
-    _dio.options.baseUrl = Constants.apiBaseUrl;
-    _dio.options.connectTimeout = const Duration(milliseconds: Constants.connectionTimeout);
-    _dio.options.receiveTimeout = const Duration(milliseconds: Constants.receiveTimeout);
-    _dio.options.sendTimeout = const Duration(milliseconds: Constants.connectionTimeout);
-    _dio.options.headers = {
+  final Dio dio;
+
+  ApiClient(Ref ref)
+      : dio = Dio(BaseOptions(
+          baseUrl: Constants.apiBaseUrl,
+          connectTimeout: const Duration(milliseconds: Constants.connectionTimeout),
+          receiveTimeout: const Duration(milliseconds: Constants.receiveTimeout),
+          headers: {
       'Content-Type': 'application/json',
       'Accept': 'application/json',
-    };
-  }
-
-  void _setupInterceptors() {
-    // Add auth interceptor
-    _dio.interceptors.add(InterceptorsWrapper(
-      onRequest: (options, handler) async {
-        // Skip auth for public endpoints
-        final publicEndpoints = [
-          Constants.loginEndpoint,
-          Constants.registerEndpoint,
-          Constants.refreshTokenEndpoint,
-        ];
-
-        if (!publicEndpoints.contains(options.path)) {
-          final token = await _secureStorage.read(key: Constants.tokenKey);
-          if (token != null) {
-            options.headers['Authorization'] = 'Bearer $token';
-          }
-        }
-
-        handler.next(options);
-      },
-      onError: (err, handler) {
-        // Transform DioException to ApiException for consistent error handling
-        final apiException = ApiException.fromDioError(err);
-
-        // For 401 errors, we'll let the repository handle token refresh
-        // This is a simplified approach - full token refresh logic would be more complex
-        if (err.response?.statusCode == 401) {
-          // Pass through 401 errors to be handled by the repository layer
-          handler.next(err);
-          return;
-        }
-
-        // Create a new DioException with the ApiException as the error
-        final newError = DioException(
-          requestOptions: err.requestOptions,
-          error: apiException,
-          response: err.response,
-          type: err.type,
-          message: apiException.message,
-        );
-
-        handler.next(newError);
-      },
-    ));
-
-    // Add logging interceptor for development
-    if (Constants.environment == 'development') {
-      _dio.interceptors.add(LogInterceptor(
-        requestBody: true,
-        responseBody: true,
-        requestHeader: true,
-        responseHeader: false,
-        error: true,
-        logPrint: (obj) => debugPrint('[API] $obj'),
-      ));
-    }
+          },
+        )) {
+    dio.interceptors.addAll([
+      AuthInterceptor(ref), // Add our new interceptor
+      // ... other interceptors like logging or caching
+      if (kDebugMode)
+        LogInterceptor(
+          requestBody: true,
+          responseBody: true,
+        ),
+    ]);
   }
 
   // Generic request methods
   Future<Response<T>> get<T>(
     String path, {
     Map<String, dynamic>? queryParameters,
     Options? options,
-    CachePolicy? cachePolicy, // Allow overriding cache policy per request
   }) async {
-    Options effectiveOptions = options ?? Options();
-    return await _dio.get<T>(
+    return await dio.get<T>(
       path,
       queryParameters: queryParameters,
-      options: effectiveOptions,
+      options: options,
     );
   }
 
   Future<Response<T>> post<T>(
     String path, {
     dynamic data,
     Map<String, dynamic>? queryParameters,
     Options? options,
   }) async {
-    return await _dio.post<T>(
+    return await dio.post<T>(
       path,
       data: data,
       queryParameters: queryParameters,
@@ -194,7 +105,7 @@
     Map<String, dynamic>? queryParameters,
     Options? options,
   }) async {
-    return await _dio.put<T>(
+    return await dio.put<T>(
       path,
       data: data,
       queryParameters: queryParameters,
@@ -207,7 +118,7 @@
     Map<String, dynamic>? queryParameters,
     Options? options,
   }) async {
-    return await _dio.patch<T>(
+    return await dio.patch<T>(
       path,
       data: data,
       queryParameters: queryParameters,
@@ -220,18 +131,11 @@
     Map<String, dynamic>? queryParameters,
     Options? options,
   }) async {
-    return await _dio.delete<T>(
+    return await dio.delete<T>(
       path,
       data: data,
       queryParameters: queryParameters,
       options: options,
     );
   }
-
-  /// Clear stored tokens
-  Future<void> clearTokens() async {
-    await _secureStorage.delete(key: Constants.tokenKey);
-    await _secureStorage.delete(key: Constants.refreshTokenKey);
-  }
 }
diff --git a/nestery-flutter/lib/data/repositories/auth_repository.dart b/nestery-flutter/lib/data/repositories/auth_repository.dart
deleted file mode 100644
index 7083861..0000000
--- a/nestery-flutter/lib/data/repositories/auth_repository.dart
+++ /dev/null
@@ -1,313 +0,0 @@
-import 'package:connectivity_plus/connectivity_plus.dart';
-import 'package:dio/dio.dart';
-import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
-import 'package:flutter_secure_storage/flutter_secure_storage.dart';
-import 'package:nestery_flutter/core/network/api_client.dart';
-import 'package:nestery_flutter/models/auth_dtos.dart';
-import 'package:nestery_flutter/models/user.dart';
-import 'package:nestery_flutter/services/api_cache_service.dart';
-import 'package:nestery_flutter/utils/api_exception.dart';
-import 'package:nestery_flutter/utils/constants.dart';
-import 'package:nestery_flutter/utils/either.dart';
-
-/// Repository for handling authentication-related API calls
-class AuthRepository {
-  final ApiClient _apiClient;
-  final ApiCacheService _apiCacheService;
-  final FlutterSecureStorage _secureStorage;
-
-  AuthRepository({
-    required ApiClient apiClient,
-    required ApiCacheService apiCacheService,
-    FlutterSecureStorage? secureStorage,
-  })  : _apiClient = apiClient,
-        _apiCacheService = apiCacheService,
-        _secureStorage = secureStorage ?? const FlutterSecureStorage();
-
-  /// Register a new user
-  Future<Either<ApiException, AuthResponse>> register(RegisterDto data) async {
-    try {
-      final response = await _apiClient.post<Map<String, dynamic>>(
-        Constants.registerEndpoint,
-        data: data.toJson(),
-      );
-
-      if (response.data != null) {
-        final authResponse = AuthResponse.fromJson(response.data!);
-        return Either.right(authResponse);
-      } else {
-        return Either.left(ApiException(
-          message: 'Invalid response from server',
-          statusCode: 500,
-        ));
-      }
-    } on DioException catch (e) {
-      return Either.left(ApiException.fromDioError(e));
-    } catch (e) {
-      return Either.left(ApiException(
-        message: e.toString(),
-        statusCode: 500,
-      ));
-    }
-  }
-
-  /// Login user
-  Future<Either<ApiException, AuthResponse>> login(LoginDto data) async {
-    try {
-      final response = await _apiClient.post<Map<String, dynamic>>(
-        Constants.loginEndpoint,
-        data: data.toJson(),
-      );
-
-      if (response.data != null) {
-        final authResponse = AuthResponse.fromJson(response.data!);
-        return Either.right(authResponse);
-      } else {
-        return Either.left(ApiException(
-          message: 'Invalid response from server',
-          statusCode: 500,
-        ));
-      }
-    } on DioException catch (e) {
-      return Either.left(ApiException.fromDioError(e));
-    } catch (e) {
-      return Either.left(ApiException(
-        message: e.toString(),
-        statusCode: 500,
-      ));
-    }
-  }
-
-  /// Refresh access token
-  Future<Either<ApiException, AuthResponse>> refreshToken(RefreshTokenDto data) async {
-    try {
-      final response = await _apiClient.post<Map<String, dynamic>>(
-        Constants.refreshTokenEndpoint,
-        data: data.toJson(),
-      );
-
-      if (response.data != null) {
-        final authResponse = AuthResponse.fromJson(response.data!);
-        return Either.right(authResponse);
-      } else {
-        return Either.left(ApiException(
-          message: 'Invalid response from server',
-          statusCode: 500,
-        ));
-      }
-    } on DioException catch (e) {
-      return Either.left(ApiException.fromDioError(e));
-    } catch (e) {
-      return Either.left(ApiException(
-        message: e.toString(),
-        statusCode: 500,
-      ));
-    }
-  }
-
-  /// Get current user profile
-  Future<Either<ApiException, User>> getCurrentUser() async {
-    final connectivityResult = await Connectivity().checkConnectivity();
-    final isOnline = connectivityResult != ConnectivityResult.none;
-
-    try {
-      Options? requestOptions;
-      if (!isOnline) {
-        // If offline, try to use cache with force cache policy
-        requestOptions = CacheOptions(
-          store: _apiClient.cacheStore, // Use the global store
-          policy: CachePolicy.forceCache,
-          hitCacheOnNetworkFailure: true,
-        ).toOptions();
-      } else {
-        // If online, use a slightly longer TTL for user profile
-        requestOptions = CacheOptions(
-          store: _apiClient.cacheStore, // Use the global store
-          policy: CachePolicy.request,
-          maxStale: Constants.userProfileCacheTTL,
-        ).toOptions();
-      }
-
-      final response = await _apiClient.get<Map<String, dynamic>>(
-        Constants.userProfileEndpoint,
-        options: requestOptions,
-      );
-
-      if (response.data != null) {
-        final user = User.fromJson(response.data!);
-        return Either.right(user);
-      } else {
-        return Either.left(ApiException(
-          message: 'Invalid response from server',
-          statusCode: 500,
-        ));
-      }
-    } on DioException catch (e) {
-      if (!isOnline && e.error.toString().contains('cache')) {
-        return Either.left(ApiException(
-          message: "Offline and no cached profile available.",
-          statusCode: 0, // Custom code for "offline and no cache"
-        ));
-      }
-      return Either.left(ApiException.fromDioError(e));
-    } catch (e) {
-      return Either.left(ApiException(
-        message: e.toString(),
-        statusCode: 500,
-      ));
-    }
-  }
-
-  /// Update user profile
-  Future<Either<ApiException, User>> updateProfile(UpdateUserDto data) async {
-    try {
-      final response = await _apiClient.put<Map<String, dynamic>>(
-        Constants.userProfileEndpoint,
-        data: data.toJson(),
-      );
-
-      if (response.data != null) {
-        final user = User.fromJson(response.data!);
-        // Invalidate user profile cache after successful update
-        await _apiCacheService.invalidateCacheEntry(Constants.apiBaseUrl + Constants.userProfileEndpoint);
-        return Either.right(user);
-      } else {
-        return Either.left(ApiException(
-          message: 'Invalid response from server',
-          statusCode: 500,
-        ));
-      }
-    } on DioException catch (e) {
-      return Either.left(ApiException.fromDioError(e));
-    } catch (e) {
-      return Either.left(ApiException(
-        message: e.toString(),
-        statusCode: 500,
-      ));
-    }
-  }
-
-  /// Store authentication tokens securely
-  Future<void> storeTokens({
-    required String accessToken,
-    required String refreshToken,
-  }) async {
-    await _secureStorage.write(key: Constants.tokenKey, value: accessToken);
-    await _secureStorage.write(key: Constants.refreshTokenKey, value: refreshToken);
-  }
-
-  /// Get stored access token
-  Future<String?> getAccessToken() async {
-    return await _secureStorage.read(key: Constants.tokenKey);
-  }
-
-  /// Get stored refresh token
-  Future<String?> getRefreshToken() async {
-    return await _secureStorage.read(key: Constants.refreshTokenKey);
-  }
-
-  /// Clear all stored tokens
-  Future<void> clearTokens() async {
-    await _secureStorage.delete(key: Constants.tokenKey);
-    await _secureStorage.delete(key: Constants.refreshTokenKey);
-    await _apiClient.clearTokens();
-  }
-
-  /// Check if user has valid tokens
-  Future<bool> hasValidTokens() async {
-    final accessToken = await getAccessToken();
-    final refreshToken = await getRefreshToken();
-    return accessToken != null && refreshToken != null;
-  }
-
-  /// Attempt to refresh token automatically
-  Future<Either<ApiException, AuthResponse>> attemptTokenRefresh() async {
-    final refreshToken = await getRefreshToken();
-    if (refreshToken == null) {
-      return Either.left(ApiException(
-        message: 'No refresh token available',
-        statusCode: 401,
-      ));
-    }
-
-    return await this.refreshToken(RefreshTokenDto(refreshToken: refreshToken));
-  }
-
-  /// Send forgot password email
-  Future<Either<ApiException, Map<String, dynamic>>> forgotPassword(String email) async {
-    try {
-      // Validate email format
-      if (email.trim().isEmpty) {
-        return Either.left(ApiException(
-          message: 'Email is required',
-          statusCode: 400,
-        ));
-      }
-
-      if (!Constants.emailPattern.hasMatch(email.trim())) {
-        return Either.left(ApiException(
-          message: 'Please enter a valid email address',
-          statusCode: 400,
-        ));
-      }
-
-      final response = await _apiClient.post<Map<String, dynamic>>(
-        Constants.forgotPasswordEndpoint,
-        data: {'email': email.trim()},
-      );
-
-      if (response.data != null) {
-        return Either.right(response.data!);
-      } else {
-        return Either.left(ApiException(
-          message: 'Invalid response from server',
-          statusCode: 500,
-        ));
-      }
-    } on DioException catch (e) {
-      return Either.left(ApiException.fromDioError(e));
-    } catch (e) {
-      return Either.left(ApiException(
-        message: e.toString(),
-        statusCode: 500,
-      ));
-    }
-  }
-
-  /// Reset password with token
-  Future<Either<ApiException, Map<String, dynamic>>> resetPassword({
-    required String token,
-    required String newPassword,
-  }) async {
-    try {
-      // Validate inputs
-      if (token.trim().isEmpty) {
-        return Either.left(ApiException(
-          message: 'Reset token is required',
-          statusCode: 400,
-        ));
-      }
-
-      if (newPassword.trim().isEmpty) {
-        return Either.left(ApiException(
-          message: 'New password is required',
-          statusCode: 400,
-        ));
-      }
-
-      if (!Constants.passwordPattern.hasMatch(newPassword)) {
-        return Either.left(ApiException(
-          message: 'Password must be at least 8 characters with letters and numbers',
-          statusCode: 400,
-        ));
-      }
-
-      final response = await _apiClient.post<Map<String, dynamic>>(
-        Constants.resetPasswordEndpoint,
-        data: {
-          'token': token.trim(),
-          'newPassword': newPassword,
-        },
-      );
-
-      if (response.data != null) {
-        return Either.right(response.data!);
-      } else {
-        return Either.left(ApiException(
-          message: 'Invalid response from server',
-          statusCode: 500,
-        ));
-      }
-    } on DioException catch (e) {
-      return Either.left(ApiException.fromDioError(e));
-    } catch (e) {
-      return Either.left(ApiException(
-        message: e.toString(),
-        statusCode: 500,
-      ));
-    }
-  }
-}
diff --git a/nestery-flutter/lib/main.dart b/nestery-flutter/lib/main.dart
index 6863619..2b23136 100644
--- a/nestery-flutter/lib/main.dart
+++ b/nestery-flutter/lib/main.dart
@@ -19,25 +19,11 @@
   // Initialize app constants
   Constants.initialize();
 
-  // Initialize ApiClient and its cache
-  final apiClient = ApiClient();
-  await apiClient.initializeCache();
-
-  // Initialize AdService (needs to be done after ApiClient for Riverpod overrides)
-  // AdService initialization will be handled by Riverpod provider itself or called explicitly after ProviderScope
-
   // Remove splash screen
   FlutterNativeSplash.remove();
 
   runApp(
     // Enable Riverpod for the entire app
     ProviderScope(
-      overrides: [
-        // Override the apiClientProvider to provide the initialized instance
-        // This ensures that the apiClientProvider in repository_providers.dart (and auth_provider.dart)
-        // uses the *same* instance of ApiClient that had its cache initialized.
-        apiClientProvider.overrideWithValue(apiClient),
-        // No need to override adServiceProvider here, it will be created by Riverpod
-      ],
       observers: [
         _AdServiceInitializer(), // Observer to initialize AdService
       ],
diff --git a/nestery-flutter/lib/providers/repository_providers.dart b/nestery-flutter/lib/providers/repository_providers.dart
index 7311142..7205126 100644
--- a/nestery-flutter/lib/providers/repository_providers.dart
+++ b/nestery-flutter/lib/providers/repository_providers.dart
@@ -9,7 +9,9 @@
 /// Provider for ApiClient (if not already defined in auth_provider.dart or similar)
 /// This ensures ApiClient is available for all repositories.
 /// If ApiClient needs async initialization (like for cache), this might need to be a FutureProvider
-final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
+final apiClientProvider = Provider<ApiClient>((ref) {
+  return ApiClient(ref);
+});
 
 /// Repository providers for dependency injection
 
diff --git a/nestery-flutter/pubspec.yaml b/nestery-flutter/pubspec.yaml
index 7531980..764032a 100644
--- a/nestery-flutter/pubspec.yaml
+++ b/nestery-flutter/pubspec.yaml
@@ -16,7 +16,7 @@
   drift: ^2.15.0
   sqlite3_flutter_libs: ^0.5.33 # For native SQLite bindings, updated to match drift_dev
   # Storage and persistence
-  flutter_secure_storage: ^9.0.0
+  flutter_secure_storage: ^9.2.2
   shared_preferences: ^2.2.2
   # File Picker
   file_picker: ^10.1.9