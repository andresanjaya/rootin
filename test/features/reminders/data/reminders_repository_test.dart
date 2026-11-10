import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_test/flutter_test.dart';
import 'package:rootin_mobile/core/database/database.dart';
import 'package:rootin_mobile/features/reminders/data/reminders_repository.dart';

void main() {
  late AppDatabase db;
  late RemindersRepository repository;
  const userId = 'user-123';

  setUp(() async {
    db = AppDatabase.inMemory();
    repository = RemindersRepository(db);

    // Seed test items
    await db
        .into(db.items)
        .insert(
          ItemsCompanion.insert(
            id: 'item-vehicle',
            userId: userId,
            name: 'Toyota Avanza',
            category: 'vehicle',
            hasOdometer: const drift.Value(true),
            currentOdometer: const drift.Value(45000),
            createdAt: DateTime.now().toUtc().toIso8601String(),
            updatedAt: DateTime.now().toUtc().toIso8601String(),
          ),
        );

    await db
        .into(db.items)
        .insert(
          ItemsCompanion.insert(
            id: 'item-appliance',
            userId: userId,
            name: 'AC Ruang Tamu',
            category: 'appliance',
            hasOdometer: const drift.Value(false),
            createdAt: DateTime.now().toUtc().toIso8601String(),
            updatedAt: DateTime.now().toUtc().toIso8601String(),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('RemindersRepository saveReminder', () {
    test(
      'creates time-based reminder and enqueues insert outbox mutation',
      () async {
        final data = ReminderFormData(
          itemId: 'item-appliance',
          name: 'Cuci Filter AC',
          engineType: 'time',
          intervalValue: 3,
          intervalUnit: 'months',
          targetDate: '2026-12-01',
          anchorDay: 1,
        );

        final id = await repository.saveReminder(userId: userId, data: data);
        expect(id, isNotEmpty);

        // Verify in Drift table
        final saved = await db.remindersDao.getReminderById(userId, id);
        expect(saved, isNotNull);
        expect(saved!.name, 'Cuci Filter AC');
        expect(saved.engineType, 'time');
        expect(saved.intervalValue, 3);
        expect(saved.intervalUnit, 'months');
        expect(saved.targetDate, '2026-12-01');
        expect(saved.version, 1);

        // Verify in outbox table
        final outbox = await db.outboxDao.getAllMutations(userId);
        expect(outbox.length, 1);
        final entry = outbox.first;
        expect(entry.entityType, 'reminder');
        expect(entry.operationType, 'insert');
        expect(entry.recordId, id);

        final payload = jsonDecode(entry.payloadJson) as Map<String, dynamic>;
        expect(payload['operation_type'], 'insert');
        expect(payload['version'], 1);
        expect(payload['payload']['name'], 'Cuci Filter AC');
        expect(payload['payload']['item_id'], 'item-appliance');
      },
    );

    test(
      'creates mileage-based reminder with vehicle odometer verification',
      () async {
        final data = ReminderFormData(
          itemId: 'item-vehicle',
          name: 'Ganti Oli Mesin',
          engineType: 'mileage',
          intervalKm: 5000,
          lastServiceOdometer: 45000,
        );

        final id = await repository.saveReminder(userId: userId, data: data);
        final saved = await db.remindersDao.getReminderById(userId, id);
        expect(saved, isNotNull);
        expect(saved!.intervalKm, 5000);
        expect(saved.lastServiceOdometer, 45000);
      },
    );

    test(
      'fails if mileage reminder is assigned to item without odometer',
      () async {
        final data = ReminderFormData(
          itemId: 'item-appliance',
          name: 'Ganti Oli AC',
          engineType: 'mileage',
          intervalKm: 5000,
          lastServiceOdometer: 0,
        );

        expect(
          () => repository.saveReminder(userId: userId, data: data),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test(
      'updates existing reminder with version increment and update mutation',
      () async {
        final insertData = ReminderFormData(
          itemId: 'item-appliance',
          name: 'Servis AC',
          engineType: 'time',
          intervalValue: 6,
          intervalUnit: 'months',
          targetDate: '2026-12-15',
        );
        final id = await repository.saveReminder(
          userId: userId,
          data: insertData,
        );

        final updateData = ReminderFormData(
          id: id,
          itemId: 'item-appliance',
          name: 'Servis AC Rutin (Updated)',
          engineType: 'time',
          intervalValue: 6,
          intervalUnit: 'months',
          targetDate: '2026-12-20',
        );
        await repository.saveReminder(userId: userId, data: updateData);

        final updated = await db.remindersDao.getReminderById(userId, id);
        expect(updated!.name, 'Servis AC Rutin (Updated)');
        expect(updated.targetDate, '2026-12-20');
        expect(updated.version, 2);

        final mutations = await db.outboxDao.getAllMutations(userId);
        expect(mutations.length, 2);
        expect(mutations[1].operationType, 'update');
        final payload = jsonDecode(mutations[1].payloadJson);
        expect(payload['version'], 1); // expected current version before update
        expect(payload['payload']['name'], 'Servis AC Rutin (Updated)');
        // engine_type and item_id must not be present in update payload
        expect(payload['payload']['engine_type'], isNull);
        expect(payload['payload']['item_id'], isNull);
      },
    );
  });
}
