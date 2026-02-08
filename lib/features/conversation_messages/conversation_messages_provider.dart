import 'package:drift/drift.dart' as dr;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/db/database.dart';
import 'package:app/db/database_provider.dart';

/// Group conversation provider (nullable group id, `_ungrouped` treated as null).
/// Uses StreamProvider to auto-update when group data changes in database.
final groupConversationProvider = StreamProvider.family<Group?, String?>((
  ref,
  groupId,
) {
  if (groupId == null || groupId == '_ungrouped') {
    return Stream.value(null);
  }

  final db = ref.watch(databaseProvider);
  return (db.select(
    db.groups,
  )..where((t) => t.id.equals(groupId))).watchSingleOrNull();
});

/// Group conversation messages provider - stream so UI auto-updates on delete/add.
final groupConversationMessagesProvider =
    StreamProvider.family<List<Message>, String>((ref, groupId) {
      final db = ref.watch(databaseProvider);

      return (db.select(db.messages)
            ..where((t) => t.groupId.equals(groupId))
            ..orderBy([
              (t) => dr.OrderingTerm(
                expression: t.createdAt,
                mode: dr.OrderingMode.desc,
              ),
            ]))
          .watch();
    });
