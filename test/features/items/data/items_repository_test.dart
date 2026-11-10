import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:rootin_mobile/core/database/database.dart';
import 'package:rootin_mobile/features/items/data/items_repository.dart';
import 'package:rootin_mobile/features/reminders/data/reminders_repository.dart';

void main() {
  late AppDatabase db;
  late RemindersRepository remindersRepository;
  late ItemsRepository itemsRepository;
  const userId = 'user-test-item-repo';

  setUp(() async {
    db = AppDatabase.inMemory();
    remindersRepository = RemindersRepository(db);
    itemsRepository = ItemsRepository(db, remindersRepository);
  });

  tearDown(() async {
    await db.close();
  });

  group('ItemsRepository saveItem', () {
    test(
      'creates new vehicle with odometer and enqueues insert outbox mutation',
      () async {
        const data = ItemFormData(
          name: 'Honda PCX 160',
          category: 'vehicle',
          brand: 'Honda',
          modelNumber: 'PCX 160 ABS',
          serialOrPlateNumber: 'B 1234 ABC',
          purchaseDate: '2026-01-10',
          hasOdometer: true,
          currentOdometer: 5000,
          notes: 'Motor harian kantor',
        );

        final itemId = await itemsRepository.saveItem(
          userId: userId,
          data: data,
        );
        expect(itemId, isNotEmpty);

        final item = await db.itemsDao.getItemById(userId, itemId);
        expect(item, isNotNull);
        expect(item!.name, 'Honda PCX 160');
        expect(item.category, 'vehicle');
        expect(item.brand, 'Honda');
        expect(item.hasOdometer, isTrue);
        expect(item.currentOdometer, 5000);
        expect(item.version, 1);
        expect(item.isArchived, isFalse);

        // Verify outbox mutation
        final outbox = await db.outboxDao.getAllMutations(userId);
        final itemInsert = outbox.firstWhere(
          (m) => m.entityType == 'item' && m.operationType == 'insert',
        );
        expect(itemInsert.recordId, itemId);
        final payload =
            jsonDecode(itemInsert.payloadJson) as Map<String, dynamic>;
        expect(payload['payload']['name'], 'Honda PCX 160');
        expect(payload['payload']['category'], 'vehicle');
        expect(payload['payload']['current_odometer'], 5000);

        // Initial odometer progress event was recorded
        final events =
            await (db.select(db.progressEvents)..where(
              (t) => t.userId.equals(userId) & t.itemId.equals(itemId),
            )).get();
        expect(events.length, 1);
        expect(events.first.kind, 'odometer');
        expect(events.first.amount, 5000);
      },
    );

    test('updates existing item and enqueues update outbox mutation', () async {
      const createData = ItemFormData(
        name: 'AC Sharp 1/2 PK',
        category: 'appliance',
        brand: 'Sharp',
      );
      final itemId = await itemsRepository.saveItem(
        userId: userId,
        data: createData,
      );

      final updateData = ItemFormData(
        id: itemId,
        name: 'AC Sharp Inverter 1/2 PK (Kamar Utama)',
        category: 'appliance',
        brand: 'Sharp',
        modelNumber: 'AH-XP6SHY',
        notes: 'Servis tiap 3 bulan',
      );
      await itemsRepository.saveItem(userId: userId, data: updateData);

      final updated = await db.itemsDao.getItemById(userId, itemId);
      expect(updated!.name, 'AC Sharp Inverter 1/2 PK (Kamar Utama)');
      expect(updated.modelNumber, 'AH-XP6SHY');
      expect(updated.version, 2);

      final outbox = await db.outboxDao.getAllMutations(userId);
      final updateMutation = outbox.firstWhere(
        (m) => m.entityType == 'item' && m.operationType == 'update',
      );
      expect(updateMutation.recordId, itemId);
      final payload = jsonDecode(updateMutation.payloadJson);
      expect(payload['version'], 1); // expected current version before update
      expect(
        payload['payload']['name'],
        'AC Sharp Inverter 1/2 PK (Kamar Utama)',
      );
    });
  });

  group('ItemsRepository archive, delete, and odometer', () {
    test(
      'archiveItem toggles isArchived and enqueues update outbox mutation',
      () async {
        const data = ItemFormData(name: 'Sepeda Gunung', category: 'other');
        final itemId = await itemsRepository.saveItem(
          userId: userId,
          data: data,
        );

        await itemsRepository.archiveItem(
          userId: userId,
          itemId: itemId,
          isArchived: true,
        );

        final archived = await db.itemsDao.getItemById(userId, itemId);
        expect(archived!.isArchived, isTrue);
        expect(archived.version, 2);

        final outbox = await db.outboxDao.getAllMutations(userId);
        final archiveMutation = outbox.firstWhere(
          (m) => m.entityType == 'item' && m.operationType == 'update',
        );
        expect(archiveMutation.recordId, itemId);
        final payload = jsonDecode(archiveMutation.payloadJson);
        expect(payload['payload']['is_archived'], isTrue);
      },
    );

    test('deleteItem soft deletes item and associated reminders', () async {
      const itemData = ItemFormData(
        name: 'Mobil Sedan',
        category: 'vehicle',
        hasOdometer: true,
      );
      final itemId = await itemsRepository.saveItem(
        userId: userId,
        data: itemData,
      );

      final reminderId = await remindersRepository.saveReminder(
        userId: userId,
        data: ReminderFormData(
          itemId: itemId,
          name: 'Ganti Oli',
          engineType: 'mileage',
          intervalKm: 5000,
          lastServiceOdometer: 10000,
        ),
      );

      await itemsRepository.deleteItem(userId: userId, itemId: itemId);

      // Item soft deleted
      final item = await db.itemsDao.getItemById(userId, itemId);
      expect(
        item,
        isNull,
      ); // deleted items are excluded from normal getItemById query

      // Reminder soft deleted
      final reminder = await db.remindersDao.getReminderById(
        userId,
        reminderId,
      );
      expect(reminder, isNull);

      final outbox = await db.outboxDao.getAllMutations(userId);
      final deleteMutation = outbox.firstWhere(
        (m) => m.entityType == 'item' && m.operationType == 'delete',
      );
      expect(deleteMutation.recordId, itemId);
    });

    test(
      'updateOdometer supports confirmed correction for decreased reading',
      () async {
        const data = ItemFormData(
          name: 'Toyota Yaris',
          category: 'vehicle',
          hasOdometer: true,
          currentOdometer: 45000,
        );
        final itemId = await itemsRepository.saveItem(
          userId: userId,
          data: data,
        );

        // Increasing odometer succeeds
        await itemsRepository.updateOdometer(
          userId: userId,
          itemId: itemId,
          newOdometer: 46200,
        );
        var item = await db.itemsDao.getItemById(userId, itemId);
        expect(item!.currentOdometer, 46200);

        // Decreasing without allowCorrection throws ArgumentError
        expect(
          () => itemsRepository.updateOdometer(
            userId: userId,
            itemId: itemId,
            newOdometer: 44000,
            allowCorrection: false,
          ),
          throwsA(isA<ArgumentError>()),
        );

        // Decreasing WITH allowCorrection succeeds
        await itemsRepository.updateOdometer(
          userId: userId,
          itemId: itemId,
          newOdometer: 44000,
          allowCorrection: true,
        );
        item = await db.itemsDao.getItemById(userId, itemId);
        expect(item!.currentOdometer, 44000);
      },
    );
  });
}
