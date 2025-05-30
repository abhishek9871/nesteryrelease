// Basic Flutter widget tests for the Nestery app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nestery_flutter/main.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/providers/auth_provider.dart';

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
  group('Nestery App Widget Tests', () {
    setUpAll(() {
      // Initialize Flutter bindings for tests
      TestWidgetsFlutterBinding.ensureInitialized();
      // Initialize Constants for tests
      Constants.initialize();
      // Set up SharedPreferences mock
      SharedPreferences.setMockInitialValues({});
    });
    testWidgets('App should start and show basic structure', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageProvider.overrideWithValue(MockFlutterSecureStorage()),
          ],
          child: const NesteryApp(),
        ),
      );

      // Verify that the app starts (we should see some basic structure)
      expect(find.byType(ProviderScope), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App should have proper theme configuration', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageProvider.overrideWithValue(MockFlutterSecureStorage()),
          ],
          child: const NesteryApp(),
        ),
      );

      // Get the MaterialApp widget
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      // Verify that the app has a theme configured
      expect(materialApp.theme, isNotNull);
      expect(materialApp.title, 'Nestery');
    });

    testWidgets('App should be wrapped in ProviderScope', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageProvider.overrideWithValue(MockFlutterSecureStorage()),
          ],
          child: const NesteryApp(),
        ),
      );

      // Verify that the app is properly wrapped in ProviderScope for Riverpod
      expect(find.byType(ProviderScope), findsOneWidget);

      // Verify that NesteryApp is inside ProviderScope
      final providerScope = tester.widget<ProviderScope>(find.byType(ProviderScope));
      expect(providerScope.child, isA<NesteryApp>());
    });

    testWidgets('App should have Navigator in widget tree', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageProvider.overrideWithValue(MockFlutterSecureStorage()),
          ],
          child: const NesteryApp(),
        ),
      );

      // Just pump once to avoid timer issues
      await tester.pump();

      // Verify that we have a Navigator in the widget tree
      expect(find.byType(Navigator), findsOneWidget);
    });
  });
}
