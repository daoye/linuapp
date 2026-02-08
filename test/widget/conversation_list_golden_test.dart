import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/features/conversations/widgets/conversation_group_tile.dart';
import 'package:app/db/database.dart';

void main() {
  group('Conversation List Golden Tests', () {
    testWidgets('Light theme - Conversation list with unread and pinned', (tester) async {
      final group1 = Group(
        id: '1',
        name: 'Test Group 1',
        iconUrl: '',
        replyWebhook: '',
        actions: '',
      );

      final message1 = Message(
        id: 'm1',
        groupId: '1',
        content: 'This is an unread message',
        title: '',
        mediaType: '',
        mediaUrl: '',
        thumbnailUrl: '',
        actions: '',
        detailUrl: '',
        sound: '',
        createdAt: DateTime.now(),
        isClientSent: false,
        isRead: false,
        sendStatus: 0,
      );

      final group2 = Group(
        id: '2',
        name: 'Test Group 2',
        iconUrl: '',
        replyWebhook: '',
        actions: '',
      );

      final message2 = Message(
        id: 'm2',
        groupId: '2',
        content: 'This is a read message',
        title: '',
        mediaType: '',
        mediaUrl: '',
        thumbnailUrl: '',
        actions: '',
        detailUrl: '',
        sound: '',
        createdAt: DateTime.now(),
        isClientSent: false,
        isRead: true,
        sendStatus: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: LinuTheme.light,
          home: Scaffold(
            body: ListView(
              children: [
                ConversationGroupTile(
                  group: group1,
                  lastMessage: message1,
                  isPinned: true,
                ),
                ConversationGroupTile(
                  group: group2,
                  lastMessage: message2,
                  isPinned: false,
                ),
              ],
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/conversation_list_light.png'),
      );
    });

    testWidgets('Dark theme - Conversation list with unread and pinned', (tester) async {
      final group1 = Group(
        id: '1',
        name: 'Test Group 1',
        iconUrl: '',
        replyWebhook: '',
        actions: '',
      );

      final message1 = Message(
        id: 'm1',
        groupId: '1',
        content: 'This is an unread message',
        title: '',
        mediaType: '',
        mediaUrl: '',
        thumbnailUrl: '',
        actions: '',
        detailUrl: '',
        sound: '',
        createdAt: DateTime.now(),
        isClientSent: false,
        isRead: false,
        sendStatus: 0,
      );

      final group2 = Group(
        id: '2',
        name: 'Test Group 2',
        iconUrl: '',
        replyWebhook: '',
        actions: '',
      );

      final message2 = Message(
        id: 'm2',
        groupId: '2',
        content: 'This is a read message',
        title: '',
        mediaType: '',
        mediaUrl: '',
        thumbnailUrl: '',
        actions: '',
        detailUrl: '',
        sound: '',
        createdAt: DateTime.now(),
        isClientSent: false,
        isRead: true,
        sendStatus: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: LinuTheme.dark,
          home: Scaffold(
            body: ListView(
              children: [
                ConversationGroupTile(
                  group: group1,
                  lastMessage: message1,
                  isPinned: true,
                ),
                ConversationGroupTile(
                  group: group2,
                  lastMessage: message2,
                  isPinned: false,
                ),
              ],
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/conversation_list_dark.png'),
      );
    });
  });
}
