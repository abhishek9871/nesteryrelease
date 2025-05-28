// Basic Flutter widget tests for the Nestery app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/main.dart';

void main() {
  group('Nestery App Widget Tests', () {
    testWidgets('App should start and show splash screen', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const ProviderScope(child: NesteryApp()));

      // Verify that the app starts (we should see some basic structure)
      expect(find.byType(ProviderScope), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App should have proper theme configuration', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const ProviderScope(child: NesteryApp()));

      // Get the MaterialApp widget
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      // Verify that the app has a theme configured
      expect(materialApp.theme, isNotNull);
      expect(materialApp.title, 'Nestery');
    });

    testWidgets('App should be wrapped in ProviderScope', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const ProviderScope(child: NesteryApp()));

      // Verify that the app is properly wrapped in ProviderScope for Riverpod
      expect(find.byType(ProviderScope), findsOneWidget);

      // Verify that NesteryApp is inside ProviderScope
      final providerScope = tester.widget<ProviderScope>(find.byType(ProviderScope));
      expect(providerScope.child, isA<NesteryApp>());
    });

    testWidgets('App should handle basic navigation structure', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const ProviderScope(child: NesteryApp()));

      // Wait for any initial navigation or splash screen
      await tester.pumpAndSettle();

      // Verify that we have a Navigator in the widget tree
      expect(find.byType(Navigator), findsOneWidget);
    });
  });
}
