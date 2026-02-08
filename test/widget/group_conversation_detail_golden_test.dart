import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/features/conversation_messages/widgets/template_message_card.dart';
import 'package:app/db/database.dart';

void main() {
  group('Group Conversation Detail Golden Tests', () {
    testWidgets('Light theme - Template message card with actions', (tester) async {
      final message = Message(
        id: '1',
        groupId: 'test-group',
        content: 'This is a test message with actions',
        title: 'Test Title',
        mediaType: '',
        mediaUrl: '',
        thumbnailUrl: '',
        actions: '''
        [
          {"label": "Action 1", "type": "webhook"},
          {"label": "Action 2", "type": "webhook"}
        ]
        ''',
        detailUrl: '',
        sound: '',
        createdAt: DateTime.now(),
        isClientSent: false,
        isRead: false,
        sendStatus: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: LinuTheme.light,
          home: Scaffold(
            body: Center(
              child: TemplateMessageCard(message: message),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/conversation_detail_light.png'),
      );
    });

    testWidgets('Dark theme - Template message card with actions', (tester) async {
      final message = Message(
        id: '1',
        groupId: 'test-group',
        content: 'This is a test message with actions',
        title: 'Test Title',
        mediaType: '',
        mediaUrl: '',
        thumbnailUrl: '',
        actions: '''
        [
          {"label": "Action 1", "type": "webhook"},
          {"label": "Action 2", "type": "webhook"}
        ]
        ''',
        detailUrl: '',
        sound: '',
        createdAt: DateTime.now(),
        isClientSent: false,
        isRead: false,
        sendStatus: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: LinuTheme.dark,
          home: Scaffold(
            body: Center(
              child: TemplateMessageCard(message: message),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/conversation_detail_dark.png'),
      );
    });
  });
}
