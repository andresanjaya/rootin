import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rootin_mobile/core/database/database.dart';
import 'package:rootin_mobile/core/database/database_providers.dart';
import 'package:rootin_mobile/features/auth/data/repositories/in_memory_auth_repository.dart';
import 'package:rootin_mobile/features/auth/domain/entities/auth_user.dart';
import 'package:rootin_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:rootin_mobile/features/reminders/data/reminder_feed.dart';

void main() {
  test(
    'calendar status uses effective day, ignores invalid and non-time dates',
    () {
      final now = DateTime.utc(2026, 10, 25, 1);
      expect(
        todayInZone(now, 'America/Los_Angeles'),
        DateTime.utc(2026, 10, 24),
      );
      expect(todayInZone(now, 'Asia/Jakarta'), DateTime.utc(2026, 10, 25));
      Reminder reminder(String id, String engine, String? day) => Reminder(
        id: id,
        userId: 'u',
        itemId: 'i',
        name: 'A',
        engineType: engine,
        intervalUnit: null,
        intervalValue: null,
        baselineMode: null,
        anchorDay: null,
        targetDate: day,
        targetTime: null,
        usageCounter: null,
        usageThreshold: null,
        usageUnit: null,
        lastServiceOdometer: null,
        intervalKm: null,
        snoozeUntil: null,
        isActive: true,
        createdAt: '',
        updatedAt: '',
        deletedAt: null,
        version: 1,
      );
      final today = DateTime.utc(2026, 10, 25);
      expect(
        reminderState(reminder('1', 'time', '2026-10-24'), today),
        ReminderState.overdue,
      );
      expect(
        reminderState(reminder('2', 'time', '2026-10-25'), today),
        ReminderState.due,
      );
      expect(
        reminderState(reminder('3', 'time', '2026-11-01'), today),
        ReminderState.soon,
      );
      expect(
        reminderState(reminder('4', 'time', '2026-02-30'), today),
        ReminderState.noDate,
      );
      expect(
        reminderState(reminder('5', 'usage', '2026-10-25'), today),
        ReminderState.noDate,
      );
      final snoozed = reminder(
        '6',
        'time',
        '2026-10-24',
      ).copyWith(snoozeUntil: const Value('2026-10-25T01:00:00Z'));
      expect(
        reminderDay(snoozed, 'America/Los_Angeles'),
        DateTime.utc(2026, 10, 24),
      );
      expect(reminderDay(snoozed, 'Asia/Jakarta'), DateTime.utc(2026, 10, 25));
      final item = Item(
        id: 'i',
        userId: 'u',
        name: 'Car',
        category: 'vehicle',
        brand: null,
        modelNumber: null,
        serialOrPlateNumber: null,
        purchaseDate: null,
        hasOdometer: true,
        currentOdometer: 120,
        photoLocalPath: null,
        photoRemotePath: null,
        notes: null,
        isArchived: false,
        createdAt: '',
        updatedAt: '',
        deletedAt: null,
        version: 1,
      );
      final mileage = reminder('m', 'mileage', null).copyWith(
        lastServiceOdometer: const Value(100),
        intervalKm: const Value(20),
      );
      expect(
        entryState(ReminderEntry(mileage, item), today),
        ReminderState.due,
      );
      expect(reminderDay(mileage), isNull);

      final overdue = reminder('overdue', 'time', '2026-10-24');
      final later = reminder('later', 'time', '2026-11-03');
      expect(
        compareEntries(
          ReminderEntry(overdue, item),
          ReminderEntry(later, item),
          today,
        ),
        lessThan(0),
      );
    },
  );

  test(
    'Drift feed isolates users and excludes archived or deleted parents',
    () async {
      final db = AppDatabase.inMemory();
      final auth = InMemoryAuthRepository(
        initialUser: AuthUser(
          id: 'one',
          email: 'one@example.com',
          createdAt: DateTime.utc(2026),
        ),
      );
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          authRepositoryProvider.overrideWithValue(auth),
        ],
      );
      try {
        for (final id in ['live', 'archived', 'deleted', 'other']) {
          final user = id == 'other' ? 'two' : 'one';
          await db.itemsDao.insertItem(
            ItemsCompanion.insert(
              id: id,
              userId: user,
              name: id,
              category: 'other',
              isArchived: Value(id == 'archived'),
              deletedAt: Value(id == 'deleted' ? '2026-01-01' : null),
              createdAt: '2026-01-01',
              updatedAt: '2026-01-01',
            ),
          );
          await db.remindersDao.insertReminder(
            RemindersCompanion.insert(
              id: id,
              userId: user,
              itemId: id,
              name: id,
              engineType: 'time',
              targetDate: const Value('2026-10-25'),
              createdAt: '2026-01-01',
              updatedAt: '2026-01-01',
            ),
          );
        }
        final feed = await container.read(reminderFeedProvider.future);
        expect(feed.map((entry) => entry.reminder.id), ['live']);
      } finally {
        container.dispose();
        auth.dispose();
        await db.close();
      }
    },
  );
}
