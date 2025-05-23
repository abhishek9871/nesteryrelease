import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nestery_flutter/models/user.dart';
import 'package:nestery_flutter/providers/auth_provider.dart';

// Mock classes
class MockAuthService extends Mock {
  Future<User> login(String email, String password) async {
    return Future.value(User(
      id: 'test-user-id',
      email: email,
      name: 'Test User',
      role: 'user',
      createdAt: DateTime.now(),
    ));
  }
  
  Future<User> register(String name, String email, String password) async {
    return Future.value(User(
      id: 'test-user-id',
      email: email,
      name: name,
      role: 'user',
      createdAt: DateTime.now(),
    ));
  }
  
  Future<void> logout() async {
    return Future.value();
  }
}

void main() {
  late AuthProvider authProvider;
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
    authProvider = AuthProvider();
    // Inject mock service
    authProvider.authService = mockAuthService;
  });

  group('AuthProvider Tests', () {
    test('Initial state should be unauthenticated', () {
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.user, null);
      expect(authProvider.token, null);
    });

    test('Login should update authentication state', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      
      // Act
      await authProvider.login(email, password);
      
      // Assert
      expect(authProvider.isAuthenticated, true);
      expect(authProvider.user, isNotNull);
      expect(authProvider.user!.email, email);
      expect(authProvider.token, isNotNull);
    });

    test('Register should create user and update authentication state', () async {
      // Arrange
      const name = 'Test User';
      const email = 'test@example.com';
      const password = 'password123';
      
      // Act
      await authProvider.register(name, email, password);
      
      // Assert
      expect(authProvider.isAuthenticated, true);
      expect(authProvider.user, isNotNull);
      expect(authProvider.user!.name, name);
      expect(authProvider.user!.email, email);
      expect(authProvider.token, isNotNull);
    });

    test('Logout should clear authentication state', () async {
      // Arrange - first login
      const email = 'test@example.com';
      const password = 'password123';
      await authProvider.login(email, password);
      expect(authProvider.isAuthenticated, true);
      
      // Act
      await authProvider.logout();
      
      // Assert
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.user, null);
      expect(authProvider.token, null);
    });
  });
}
