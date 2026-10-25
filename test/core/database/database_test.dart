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

  group('AppDatabase in-memory and schema verification', () {
    test('enforces foreign key constraints', () async {
      final now = DateTime.now().toUtc().toIso8601String();

      // Inserting reminder with non-existent item_id must fail
      expect(
        () => db.remindersDao.insertReminder(
          RemindersCompanion.insert(
            id: 'rem-1',
            userId: 'user-1',
            itemId: 'non-existent-item',
            name: 'Oli Mesin',
            engineType: 'mileage',
            createdAt: now,
            updatedAt: now,
          ),
        ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('cascades delete from item to reminders and reminder_logs', () async {
      final now = DateTime.now().toUtc().toIso8601String();

      await db.itemsDao.insertItem(
        ItemsCompanion.insert(
          id: 'item-1',
          userId: 'user-1',
          name: 'Mobil Avanza',
          category: 'vehicle',
          createdAt: now,
          updatedAt: now,
        ),
      );

      await db.remindersDao.insertReminder(
        RemindersCompanion.insert(
          id: 'rem-1',
          userId: 'user-1',
          itemId: 'item-1',
          name: 'Ganti Oli Mesin',
          engineType: 'mileage',
          intervalKm: const Value(5000),
          createdAt: now,
          updatedAt: now,
        ),
      );

      await db.reminderLogsDao.insertLog(
        ReminderLogsCompanion.insert(
          id: 'log-1',
          userId: 'user-1',
          itemId: 'item-1',
          reminderId: 'rem-1',
          completedAt: now,
          completionDate: '2026-10-25',
          createdAt: now,
        ),
      );

      // Verify records exist
      expect(await db.itemsDao.getItemById('user-1', 'item-1'), isNotNull);
      expect(
        await db.remindersDao.getReminderById('user-1', 'rem-1'),
        isNotNull,
      );
      expect(await db.reminderLogsDao.getLogById('user-1', 'log-1'), isNotNull);

      // Delete item permanently
      await db.itemsDao.deleteItemPermanently('user-1', 'item-1');

      // Verify item, reminder, and log are all deleted via CASCADE
      expect(await db.itemsDao.getItemById('user-1', 'item-1'), isNull);
      expect(await db.remindersDao.getReminderById('user-1', 'rem-1'), isNull);
      expect(await db.reminderLogsDao.getLogById('user-1', 'log-1'), isNull);
    });

    test('enforces category CHECK constraint on items', () async {
      final now = DateTime.now().toUtc().toIso8601String();

      // Invalid category throws constraint error
      expect(
        () => db.itemsDao.insertItem(
          ItemsCompanion.insert(
            id: 'item-inv',
            userId: 'user-1',
            name: 'Invalid Item',
            category:
                'spaceship', // Not in ('vehicle', 'appliance', 'furniture', 'facility', 'other')
            createdAt: now,
            updatedAt: now,
          ),
        ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('enforces engine_type CHECK constraint on reminders', () async {
      final now = DateTime.now().toUtc().toIso8601String();

      await db.itemsDao.insertItem(
        ItemsCompanion.insert(
          id: 'item-valid',
          userId: 'user-1',
          name: 'AC Ruang Tamu',
          category: 'appliance',
          createdAt: now,
          updatedAt: now,
        ),
      );

      expect(
        () => db.remindersDao.insertReminder(
          RemindersCompanion.insert(
            id: 'rem-inv',
            userId: 'user-1',
            itemId: 'item-valid',
            name: 'Invalid Reminder',
            engineType: 'solar_power', // Not in ('time', 'usage', 'mileage')
            createdAt: now,
            updatedAt: now,
          ),
        ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('sync_metadata handles upsert and retrieval per user', () async {
      final now = DateTime.now().toUtc().toIso8601String();

      await db.setSyncMetadata(
        SyncMetadataCompanion.insert(
          key: 'checkpoint_all',
          userId: 'user-1',
          lastSyncedAt: Value(now),
          lastServerVersion: const Value(5),
          updatedAt: now,
        ),
      );

      final meta1 = await db.getSyncMetadata('user-1', 'checkpoint_all');
      expect(meta1, isNotNull);
      expect(meta1!.lastServerVersion, 5);

      // Upsert update
      final later =
          DateTime.now()
              .toUtc()
              .add(const Duration(minutes: 5))
              .toIso8601String();
      await db.setSyncMetadata(
        SyncMetadataCompanion.insert(
          key: 'checkpoint_all',
          userId: 'user-1',
          lastSyncedAt: Value(later),
          lastServerVersion: const Value(12),
          updatedAt: later,
        ),
      );

      final metaUpdated = await db.getSyncMetadata('user-1', 'checkpoint_all');
      expect(metaUpdated, isNotNull);
      expect(metaUpdated!.lastServerVersion, 12);
      expect(metaUpdated.lastSyncedAt, later);

      // Delete for user
      await db.deleteSyncMetadataForUser('user-1');
      expect(await db.getSyncMetadata('user-1', 'checkpoint_all'), isNull);
    });

    test('items CRUD, archiving, and soft-delete work as expected', () async {
      final now = DateTime.now().toUtc().toIso8601String();

      await db.itemsDao.insertItem(
        ItemsCompanion.insert(
          id: 'item-crud',
          userId: 'user-1',
          name: 'Motor NMax',
          category: 'vehicle',
          brand: const Value('Yamaha'),
          modelNumber: const Value('2023 ABS'),
          hasOdometer: const Value(true),
          currentOdometer: const Value(12500),
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Get
      final item = await db.itemsDao.getItemById('user-1', 'item-crud');
      expect(item, isNotNull);
      expect(item!.name, 'Motor NMax');
      expect(item.brand, 'Yamaha');
      expect(item.currentOdometer, 12500);
      expect(item.hasOdometer, true);

      // Update
      await db.itemsDao.updateItem(
        'user-1',
        const ItemsCompanion(
          id: Value('item-crud'),
          currentOdometer: Value(13200),
        ),
      );
      final updated = await db.itemsDao.getItemById('user-1', 'item-crud');
      expect(updated!.currentOdometer, 13200);

      // Archive
      await db.itemsDao.updateItem(
        'user-1',
        const ItemsCompanion(id: Value('item-crud'), isArchived: Value(true)),
      );
      // Excluded from default getItems
      expect(await db.itemsDao.getItems('user-1'), isEmpty);
      // Included when includeArchived = true
      expect(
        await db.itemsDao.getItems('user-1', includeArchived: true),
        hasLength(1),
      );

      // Soft delete
      final deleteTime = DateTime.now().toUtc().toIso8601String();
      await db.itemsDao.softDeleteItem(
        'user-1',
        'item-crud',
        deletedAt: deleteTime,
        version: 2,
        updatedAt: deleteTime,
      );
      // Hidden from active getItems even with includeArchived
      expect(
        await db.itemsDao.getItems('user-1', includeArchived: true),
        isEmpty,
      );
      expect(await db.itemsDao.getItemById('user-1', 'item-crud'), isNull);
    });
  });
}
