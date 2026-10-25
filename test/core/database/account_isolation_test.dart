import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:rootin_mobile/core/database/database.dart';

void main() {
  late AppDatabase db;

  const userA = 'user-uuid-aaa';
  const userB = 'user-uuid-bbb';

  setUp(() async {
    db = AppDatabase.inMemory();

    final now = DateTime.now().toUtc().toIso8601String();

    // Seed data for User A
    await db.itemsDao.insertItem(
      ItemsCompanion.insert(
        id: 'item-a-1',
        userId: userA,
        name: 'Item Milik User A',
        category: 'appliance',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await db.remindersDao.insertReminder(
      RemindersCompanion.insert(
        id: 'rem-a-1',
        userId: userA,
        itemId: 'item-a-1',
        name: 'Reminder A1',
        engineType: 'time',
        intervalUnit: const Value('months'),
        intervalValue: const Value(1),
        createdAt: now,
        updatedAt: now,
      ),
    );
    await db.reminderLogsDao.insertLog(
      ReminderLogsCompanion.insert(
        id: 'log-a-1',
        userId: userA,
        itemId: 'item-a-1',
        reminderId: 'rem-a-1',
        completedAt: now,
        completionDate: '2026-10-25',
        createdAt: now,
      ),
    );
    await db.outboxDao.enqueue(
      SyncOutboxCompanion.insert(
        operationId: 'op-a-1',
        userId: userA,
        entityType: 'item',
        recordId: 'item-a-1',
        operationType: 'insert',
        payloadJson: '{}',
        createdAt: now,
      ),
    );
    await db.setSyncMetadata(
      SyncMetadataCompanion.insert(
        key: 'checkpoint',
        userId: userA,
        lastServerVersion: const Value(10),
        updatedAt: now,
      ),
    );

    // Seed data for User B
    await db.itemsDao.insertItem(
      ItemsCompanion.insert(
        id: 'item-b-1',
        userId: userB,
        name: 'Item Milik User B',
        category: 'vehicle',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await db.remindersDao.insertReminder(
      RemindersCompanion.insert(
        id: 'rem-b-1',
        userId: userB,
        itemId: 'item-b-1',
        name: 'Reminder B1',
        engineType: 'mileage',
        intervalKm: const Value(5000),
        createdAt: now,
        updatedAt: now,
      ),
    );
    await db.reminderLogsDao.insertLog(
      ReminderLogsCompanion.insert(
        id: 'log-b-1',
        userId: userB,
        itemId: 'item-b-1',
        reminderId: 'rem-b-1',
        completedAt: now,
        completionDate: '2026-10-25',
        createdAt: now,
      ),
    );
    await db.outboxDao.enqueue(
      SyncOutboxCompanion.insert(
        operationId: 'op-b-1',
        userId: userB,
        entityType: 'item',
        recordId: 'item-b-1',
        operationType: 'insert',
        payloadJson: '{}',
        createdAt: now,
      ),
    );
    await db.setSyncMetadata(
      SyncMetadataCompanion.insert(
        key: 'checkpoint',
        userId: userB,
        lastServerVersion: const Value(25),
        updatedAt: now,
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('Multi-tenant account isolation', () {
    test('Items queries strictly isolate by user_id', () async {
      final itemsA = await db.itemsDao.getItems(userA);
      expect(itemsA, hasLength(1));
      expect(itemsA.first.name, 'Item Milik User A');

      final itemsB = await db.itemsDao.getItems(userB);
      expect(itemsB, hasLength(1));
      expect(itemsB.first.name, 'Item Milik User B');

      // User A querying User B's item ID returns null
      expect(await db.itemsDao.getItemById(userA, 'item-b-1'), isNull);
      expect(await db.itemsDao.getItemById(userB, 'item-a-1'), isNull);
    });

    test('Reminders queries strictly isolate by user_id', () async {
      final remsA = await db.remindersDao.getReminders(userA);
      expect(remsA, hasLength(1));
      expect(remsA.first.name, 'Reminder A1');

      final remsB = await db.remindersDao.getReminders(userB);
      expect(remsB, hasLength(1));
      expect(remsB.first.name, 'Reminder B1');

      expect(await db.remindersDao.getReminderById(userA, 'rem-b-1'), isNull);
      expect(await db.remindersDao.getReminderById(userB, 'rem-a-1'), isNull);
    });

    test('ReminderLogs queries strictly isolate by user_id', () async {
      final logsA = await db.reminderLogsDao.getLogs(userA);
      expect(logsA, hasLength(1));
      expect(logsA.first.id, 'log-a-1');

      final logsB = await db.reminderLogsDao.getLogs(userB);
      expect(logsB, hasLength(1));
      expect(logsB.first.id, 'log-b-1');

      expect(await db.reminderLogsDao.getLogById(userA, 'log-b-1'), isNull);
      expect(await db.reminderLogsDao.getLogById(userB, 'log-a-1'), isNull);
    });

    test('Outbox queue strictly isolates mutations by user_id', () async {
      final outboxA = await db.outboxDao.getPendingMutations(userA);
      expect(outboxA, hasLength(1));
      expect(outboxA.first.operationId, 'op-a-1');

      final outboxB = await db.outboxDao.getPendingMutations(userB);
      expect(outboxB, hasLength(1));
      expect(outboxB.first.operationId, 'op-b-1');
    });

    test('Sync metadata isolates checkpoints by user_id', () async {
      final metaA = await db.getSyncMetadata(userA, 'checkpoint');
      expect(metaA?.lastServerVersion, 10);

      final metaB = await db.getSyncMetadata(userB, 'checkpoint');
      expect(metaB?.lastServerVersion, 25);
    });

    test('User A cannot update or delete User B entities', () async {
      // User A attempts to update User B's item
      final updated = await db.itemsDao.updateItem(
        userA,
        const ItemsCompanion(
          id: Value('item-b-1'),
          name: Value('Hacked Item Name'),
        ),
      );
      expect(updated, isFalse);

      final itemB = await db.itemsDao.getItemById(userB, 'item-b-1');
      expect(itemB?.name, 'Item Milik User B');

      // User A attempts to delete User B's reminder
      final deletedCount = await db.remindersDao.deleteReminderPermanently(
        userA,
        'rem-b-1',
      );
      expect(deletedCount, 0);

      final remB = await db.remindersDao.getReminderById(userB, 'rem-b-1');
      expect(remB, isNotNull);
    });

    test(
      'clearAllUserData clears only target user data and preserves other users',
      () async {
        await db.clearAllUserData(userA);

        // Verify User A has 0 records left
        expect(await db.itemsDao.getItems(userA), isEmpty);
        expect(await db.remindersDao.getReminders(userA), isEmpty);
        expect(await db.reminderLogsDao.getLogs(userA), isEmpty);
        expect(await db.outboxDao.getAllMutations(userA), isEmpty);
        expect(await db.getSyncMetadata(userA, 'checkpoint'), isNull);

        // Verify User B is completely untouched
        expect(await db.itemsDao.getItems(userB), hasLength(1));
        expect(await db.remindersDao.getReminders(userB), hasLength(1));
        expect(await db.reminderLogsDao.getLogs(userB), hasLength(1));
        expect(await db.outboxDao.getAllMutations(userB), hasLength(1));
        expect(await db.getSyncMetadata(userB, 'checkpoint'), isNotNull);
      },
    );
  });
}
