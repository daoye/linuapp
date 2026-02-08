import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/features/conversation_actions/widgets/conversation_action_bar.dart';

void main() {
  group('Conversation Bottom Bar Tests', () {
    testWidgets('Action bar renders with correct minimum height', (tester) async {
      const menuConfig = '''
      {
        "actions": [
          {"label": "Action 1", "callback": "test1"},
          {"label": "Action 2", "callback": "test2"}
        ]
      }
      ''';

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: LinuTheme.light,
            home: Scaffold(
              body: ConversationActionBar(
                menuConfigJson: menuConfig,
                groupId: 'test-group',
              ),
            ),
          ),
        ),
      );

      // Verify action bar exists
      expect(find.byType(ConversationActionBar), findsOneWidget);
      
      // Verify buttons exist
      expect(find.text('Action 1'), findsOneWidget);
      expect(find.text('Action 2'), findsOneWidget);
      
      // Verify minimum touch target size
      final button1 = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Action 1'),
      );
      expect(button1.style?.minimumSize?.resolve({}), const Size(0, 48));
    });

    testWidgets('Action bar renders in dark theme', (tester) async {
      const menuConfig = '''
      {
        "actions": [
          {"label": "Action 1", "callback": "test1"}
        ]
      }
      ''';

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: LinuTheme.dark,
            home: Scaffold(
              body: ConversationActionBar(
                menuConfigJson: menuConfig,
                groupId: 'test-group',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Action 1'), findsOneWidget);
    });

    testWidgets('Empty menu config returns empty widget', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: LinuTheme.light,
            home: const Scaffold(
              body: ConversationActionBar(
                menuConfigJson: '{}',
                groupId: 'test-group',
              ),
            ),
          ),
        ),
      );

      // Should render SizedBox.shrink
      expect(find.byType(ConversationActionBar), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
    });
  });
}
