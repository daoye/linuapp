import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/theme/app_theme.dart';

void main() {
  group('LinuTheme Smoke Tests', () {
    testWidgets('Light theme loads and renders basic Scaffold', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: LinuTheme.light,
          home: Scaffold(
            appBar: AppBar(title: const Text('Test')),
            body: const Center(child: Text('Hello')),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('Dark theme loads and renders basic Scaffold', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: LinuTheme.dark,
          home: Scaffold(
            appBar: AppBar(title: const Text('Test')),
            body: const Center(child: Text('Hello')),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
    });

    test('Design Tokens are properly defined', () {
      // Color tokens
      expect(LinuColors.lightChatBackground, isA<Color>());
      expect(LinuColors.darkChatBackground, isA<Color>());
      expect(LinuColors.lightPrimaryAccent, isA<Color>());
      expect(LinuColors.darkPrimaryAccent, isA<Color>());

      // Text style tokens
      expect(LinuTextStyles.headline, isA<TextStyle>());
      expect(LinuTextStyles.body, isA<TextStyle>());
      expect(LinuTextStyles.caption, isA<TextStyle>());

      // Spacing tokens
      expect(LinuSpacing.xs, 4.0);
      expect(LinuSpacing.sm, 8.0);
      expect(LinuSpacing.md, 12.0);
      expect(LinuSpacing.lg, 16.0);
      expect(LinuSpacing.xl, 24.0);

      // Radius tokens
      expect(LinuRadius.small, 4.0);
      expect(LinuRadius.medium, 8.0);
      expect(LinuRadius.large, 12.0);
      expect(LinuRadius.xlarge, 16.0);
    });
  });
}
