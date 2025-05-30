import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/providers/auth_provider.dart';
import 'package:nestery_flutter/models/user.dart';
import 'package:nestery_flutter/models/loyalty.dart';

void main() {
  group('AuthProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is unauthenticated', () {
      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, false);
      expect(authState.user, null);
      expect(authState.isLoading, false);
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
