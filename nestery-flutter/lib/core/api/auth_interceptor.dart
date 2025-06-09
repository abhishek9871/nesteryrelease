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
