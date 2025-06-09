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
