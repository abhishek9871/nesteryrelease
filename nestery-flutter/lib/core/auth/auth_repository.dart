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
