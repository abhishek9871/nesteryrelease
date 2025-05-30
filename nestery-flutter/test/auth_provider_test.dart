import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nestery_flutter/providers/auth_provider.dart';
import 'package:nestery_flutter/models/user.dart';
import 'package:nestery_flutter/models/loyalty.dart';
import 'package:nestery_flutter/utils/constants.dart';

// Mock FlutterSecureStorage for testing
class MockFlutterSecureStorage extends FlutterSecureStorage {
  final Map<String, String> _storage = {};

  @override
  Future<String?> read({required String key, IOSOptions? iOptions, AndroidOptions? aOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions}) async {
    return _storage[key];
  }

  @override
  Future<void> write({required String key, required String? value, IOSOptions? iOptions, AndroidOptions? aOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions}) async {
    if (value == null) {
      _storage.remove(key);
    } else {
      _storage[key] = value;
    }
  }

  @override
  Future<void> delete({required String key, IOSOptions? iOptions, AndroidOptions? aOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions}) async {
    _storage.remove(key);
  }

  @override
  Future<void> deleteAll({IOSOptions? iOptions, AndroidOptions? aOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions}) async {
    _storage.clear();
  }
}

void main() {
  group('AuthProvider', () {
    late ProviderContainer container;

    setUpAll(() {
      // Initialize Flutter bindings for tests
      TestWidgetsFlutterBinding.ensureInitialized();
      // Initialize Constants for tests
      Constants.initialize();
      // Set up SharedPreferences mock
      SharedPreferences.setMockInitialValues({});
    });

    setUp(() {
      container = ProviderContainer(
        overrides: [
          // Override the secure storage provider with our mock
          secureStorageProvider.overrideWithValue(MockFlutterSecureStorage()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is unauthenticated', () async {
      // Wait a bit for any async initialization to complete
      await Future.delayed(const Duration(milliseconds: 100));

      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, false);
      expect(authState.user, null);
      // Note: isLoading might be true initially due to tryAutoLogin, then becomes false
      // We'll check the final state after auto-login attempt
    });

    test('User model should be correctly instantiated', () {
      final testUser = User(
        id: '1',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        role: 'user',
        loyaltyTier: LoyaltyTier.scout,
        loyaltyMilesBalance: 0,
        emailVerified: true,
        phoneVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(testUser.id, '1');
      expect(testUser.email, 'test@example.com');
      expect(testUser.firstName, 'Test');
      expect(testUser.lastName, 'User');
      expect(testUser.role, 'user');
      expect(testUser.loyaltyTier, LoyaltyTier.scout);
      expect(testUser.loyaltyMilesBalance, 0);
      expect(testUser.emailVerified, true);
      expect(testUser.phoneVerified, false);
      expect(testUser.fullName, 'Test User');
    });

    test('User fromJson should parse correctly', () {
      final json = {
        'id': '1',
        'email': 'test@example.com',
        'firstName': 'Test',
        'lastName': 'User',
        'role': 'user',
        'loyaltyTier': 'SCOUT',
        'loyaltyMilesBalance': 0,
        'emailVerified': true,
        'phoneVerified': false,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final user = User.fromJson(json);

      expect(user.id, '1');
      expect(user.email, 'test@example.com');
      expect(user.firstName, 'Test');
      expect(user.lastName, 'User');
      expect(user.role, 'user');
      expect(user.loyaltyTier, LoyaltyTier.scout);
      expect(user.loyaltyMilesBalance, 0);
      expect(user.emailVerified, true);
      expect(user.phoneVerified, false);
      expect(user.fullName, 'Test User');
    });

    test('User toJson should convert correctly', () {
      final testUser = User(
        id: '1',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        role: 'user',
        loyaltyTier: LoyaltyTier.scout,
        loyaltyMilesBalance: 0,
        emailVerified: true,
        phoneVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final json = testUser.toJson();

      expect(json['id'], '1');
      expect(json['email'], 'test@example.com');
      expect(json['firstName'], 'Test');
      expect(json['lastName'], 'User');
      expect(json['role'], 'user');
      expect(json['loyaltyTier'], 'scout');
      expect(json['loyaltyMilesBalance'], 0);
      expect(json['emailVerified'], true);
      expect(json['phoneVerified'], false);
    });

    test('User copyWith should work correctly', () {
      final testUser = User(
        id: '1',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        role: 'user',
        loyaltyTier: LoyaltyTier.scout,
        loyaltyMilesBalance: 0,
        emailVerified: true,
        phoneVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updatedUser = testUser.copyWith(
        firstName: 'Updated',
        loyaltyMilesBalance: 100,
        loyaltyTier: LoyaltyTier.explorer,
      );

      expect(updatedUser.id, '1');
      expect(updatedUser.email, 'test@example.com');
      expect(updatedUser.firstName, 'Updated');
      expect(updatedUser.lastName, 'User');
      expect(updatedUser.role, 'user');
      expect(updatedUser.loyaltyTier, LoyaltyTier.explorer);
      expect(updatedUser.loyaltyMilesBalance, 100);
      expect(updatedUser.emailVerified, true);
      expect(updatedUser.phoneVerified, false);
      expect(updatedUser.fullName, 'Updated User');
    });
  });
}
