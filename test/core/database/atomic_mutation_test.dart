import 'dart:convert';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rootin_mobile/core/database/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.inMemory();
  });

  tearDown(() async {
    await db.close();
  });

  group('Transactional atomic mutation helper', () {
    test(
      'commits both entity and sync_outbox row atomically on success',
      () async {
        final now = DateTime.now().toUtc().toIso8601String();
        const opId = 'op-atomic-1';
        const itemId = 'item-atomic-1';
        const userId = 'user-test';

        await db.performAtomicMutation(
          action: () async {
            return db.itemsDao.insertItem(
              ItemsCompanion.insert(
                id: itemId,
                userId: userId,
                name: 'Genset Honda',
                category: 'facility',
                createdAt: now,
                updatedAt: now,
              ),
            );
          },
          outboxEntry: SyncOutboxCompanion.insert(
            operationId: opId,
            userId: userId,
            entityType: 'item',
            recordId: itemId,
            operationType: 'insert',
            payloadJson: jsonEncode({
              'name': 'Genset Honda',
              'category': 'facility',
            }),
            createdAt: now,
          ),
        );

        // Verify item exists
        final item = await db.itemsDao.getItemById(userId, itemId);
        expect(item, isNotNull);
        expect(item!.name, 'Genset Honda');

        // Verify outbox entry exists and is pending
        final outbox = await db.outboxDao.getMutationByOperationId(opId);
        expect(outbox, isNotNull);
        expect(outbox!.recordId, itemId);
        expect(outbox.entityType, 'item');
        expect(outbox.operationType, 'insert');
        expect(outbox.status, 'pending');
      },
    );

    test('rolls back outbox entry when entity action throws', () async {
      final now = DateTime.now().toUtc().toIso8601String();
      const opId = 'op-atomic-fail-action';
      const userId = 'user-test';

      expect(
        () => db.performAtomicMutation(
          action: () async {
            // Force an error in the entity action
            throw Exception('Simulated entity mutation failure');
          },
          outboxEntry: SyncOutboxCompanion.insert(
            operationId: opId,
            userId: userId,
            entityType: 'item',
            recordId: 'some-id',
            operationType: 'insert',
            payloadJson: '{}',
            createdAt: now,
          ),
        ),
        throwsA(isA<Exception>()),
      );

      // Ensure outbox entry was NOT committed
      final outbox = await db.outboxDao.getMutationByOperationId(opId);
      expect(outbox, isNull);
    });

    test('rolls back entity mutation when outbox insertion fails', () async {
      final now = DateTime.now().toUtc().toIso8601String();
      const opId = 'op-duplicate-id';
      const itemId = 'item-rollback-test';
      const userId = 'user-test';

      // First, insert an outbox entry with opId to trigger duplicate UNIQUE violation later
      await db.outboxDao.enqueue(
        SyncOutboxCompanion.insert(
          operationId: opId,
          userId: userId,
          entityType: 'item',
          recordId: 'existing-record',
          operationType: 'insert',
          payloadJson: '{}',
          createdAt: now,
        ),
      );

      // Now attempt atomic mutation reusing the same opId
      expect(
        () => db.performAtomicMutation(
          action: () async {
            return db.itemsDao.insertItem(
              ItemsCompanion.insert(
                id: itemId,
                userId: userId,
                name: 'Kulkas Samsung',
                category: 'appliance',
                createdAt: now,
                updatedAt: now,
              ),
            );
          },
          outboxEntry: SyncOutboxCompanion.insert(
            operationId: opId, // Duplicate!
            userId: userId,
            entityType: 'item',
            recordId: itemId,
            operationType: 'insert',
            payloadJson: '{}',
            createdAt: now,
          ),
        ),
        throwsA(isA<SqliteException>()),
      );

      // Verify the item was rolled back and does not exist in items table!
      final item = await db.itemsDao.getItemById(userId, itemId);
      expect(item, isNull);
    });

    test(
      'performs atomic batch mutation with multiple outbox entries',
      () async {
        final now = DateTime.now().toUtc().toIso8601String();
        const userId = 'user-test';
        const itemId = 'item-batch-1';
        const remId = 'rem-batch-1';

        await db.performAtomicBatchMutation(
          action: () async {
            await db.itemsDao.insertItem(
              ItemsCompanion.insert(
                id: itemId,
                userId: userId,
                name: 'Mobil Operasional',
                category: 'vehicle',
                createdAt: now,
                updatedAt: now,
              ),
            );
            await db.remindersDao.insertReminder(
              RemindersCompanion.insert(
                id: remId,
                userId: userId,
                itemId: itemId,
                name: 'Rotasi Ban',
                engineType: 'mileage',
                intervalKm: const Value(10000),
                createdAt: now,
                updatedAt: now,
              ),
            );
          },
          outboxEntries: [
            SyncOutboxCompanion.insert(
              operationId: 'op-batch-item',
              userId: userId,
              entityType: 'item',
              recordId: itemId,
              operationType: 'insert',
              payloadJson: jsonEncode({'name': 'Mobil Operasional'}),
              createdAt: now,
            ),
            SyncOutboxCompanion.insert(
              operationId: 'op-batch-rem',
              userId: userId,
              entityType: 'reminder',
              recordId: remId,
              operationType: 'insert',
              payloadJson: jsonEncode({'name': 'Rotasi Ban'}),
              createdAt: now,
            ),
          ],
        );

        expect(await db.itemsDao.getItemById(userId, itemId), isNotNull);
        expect(await db.remindersDao.getReminderById(userId, remId), isNotNull);

        final outboxItems = await db.outboxDao.getAllMutations(userId);
        expect(outboxItems, hasLength(2));
        expect(outboxItems[0].operationId, 'op-batch-item');
        expect(outboxItems[1].operationId, 'op-batch-rem');
      },
    );
  });
}
