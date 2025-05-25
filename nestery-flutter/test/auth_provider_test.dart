import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:nestery_flutter/providers/auth_provider.dart';
import 'package:nestery_flutter/models/user.dart';
import 'package:nestery_flutter/data/repositories/user_repository.dart';

@GenerateMocks([UserRepository])
void main() {
  late MockUserRepository mockUserRepository;
  late ProviderContainer container;

  setUp(() {
    mockUserRepository = MockUserRepository();
    container = ProviderContainer(
      overrides: [
        userRepositoryProvider.overrideWithValue(mockUserRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthProvider', () {
    test('initial state is unauthenticated', () {
      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, false);
      expect(authState.user, null);
      expect(authState.isLoading, false);
      expect(authState.error, null);
    });

    test('login success updates state correctly', () async {
      // Arrange
      final testUser = User(
        id: '1',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        role: 'user',
      );
      
      when(mockUserRepository.login(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => testUser);

      // Act
      await container.read(authProvider.notifier).login(
        email: 'test@example.com',
        password: 'password123',
      );

      // Assert
      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, true);
      expect(authState.user, testUser);
      expect(authState.isLoading, false);
      expect(authState.error, null);
    });

    test('login failure updates state with error', () async {
      // Arrange
      when(mockUserRepository.login(
        email: 'test@example.com',
        password: 'wrong_password',
      )).thenThrow(Exception('Invalid credentials'));

      // Act
      await container.read(authProvider.notifier).login(
        email: 'test@example.com',
        password: 'wrong_password',
      );

      // Assert
      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, false);
      expect(authState.user, null);
      expect(authState.isLoading, false);
      expect(authState.error, 'Invalid credentials');
    });

    test('register success updates state correctly', () async {
      // Arrange
      final testUser = User(
        id: '1',
        email: 'new@example.com',
        firstName: 'New',
        lastName: 'User',
        role: 'user',
      );
      
      when(mockUserRepository.register(
        email: 'new@example.com',
        password: 'password123',
        firstName: 'New',
        lastName: 'User',
      )).thenAnswer((_) async => testUser);

      // Act
      await container.read(authProvider.notifier).register(
        email: 'new@example.com',
        password: 'password123',
        firstName: 'New',
        lastName: 'User',
      );

      // Assert
      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, true);
      expect(authState.user, testUser);
      expect(authState.isLoading, false);
      expect(authState.error, null);
    });

    test('register failure updates state with error', () async {
      // Arrange
      when(mockUserRepository.register(
        email: 'existing@example.com',
        password: 'password123',
        firstName: 'Existing',
        lastName: 'User',
      )).thenThrow(Exception('Email already exists'));

      // Act
      await container.read(authProvider.notifier).register(
        email: 'existing@example.com',
        password: 'password123',
        firstName: 'Existing',
        lastName: 'User',
      );

      // Assert
      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, false);
      expect(authState.user, null);
      expect(authState.isLoading, false);
      expect(authState.error, 'Email already exists');
    });

    test('logout updates state correctly', () async {
      // Arrange - first login
      final testUser = User(
        id: '1',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        role: 'user',
      );
      
      when(mockUserRepository.login(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => testUser);

      await container.read(authProvider.notifier).login(
        email: 'test@example.com',
        password: 'password123',
      );

      // Verify logged in
      expect(container.read(authProvider).isAuthenticated, true);

      // Arrange for logout
      when(mockUserRepository.logout()).thenAnswer((_) async => true);

      // Act
      await container.read(authProvider.notifier).logout();

      // Assert
      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, false);
      expect(authState.user, null);
      expect(authState.isLoading, false);
      expect(authState.error, null);
    });

    test('checkAuthStatus updates state correctly when token is valid', () async {
      // Arrange
      final testUser = User(
        id: '1',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        role: 'user',
      );
      
      when(mockUserRepository.getCurrentUser()).thenAnswer((_) async => testUser);

      // Act
      await container.read(authProvider.notifier).checkAuthStatus();

      // Assert
      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, true);
      expect(authState.user, testUser);
      expect(authState.isLoading, false);
      expect(authState.error, null);
    });

    test('checkAuthStatus updates state correctly when token is invalid', () async {
      // Arrange
      when(mockUserRepository.getCurrentUser()).thenThrow(Exception('Token expired'));

      // Act
      await container.read(authProvider.notifier).checkAuthStatus();

      // Assert
      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, false);
      expect(authState.user, null);
      expect(authState.isLoading, false);
      expect(authState.error, null); // We don't show error for token expiration
    });

    test('refreshToken updates state correctly on success', () async {
      // Arrange
      final testUser = User(
        id: '1',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        role: 'user',
      );
      
      when(mockUserRepository.refreshToken()).thenAnswer((_) async => testUser);

      // Act
      final result = await container.read(authProvider.notifier).refreshToken();

      // Assert
      expect(result, true);
      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, true);
      expect(authState.user, testUser);
      expect(authState.isLoading, false);
      expect(authState.error, null);
    });

    test('refreshToken updates state correctly on failure', () async {
      // Arrange
      when(mockUserRepository.refreshToken()).thenThrow(Exception('Invalid refresh token'));

      // Act
      final result = await container.read(authProvider.notifier).refreshToken();

      // Assert
      expect(result, false);
      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, false);
      expect(authState.user, null);
      expect(authState.isLoading, false);
      expect(authState.error, null); // We don't show error for refresh token failure
    });
  });
}
