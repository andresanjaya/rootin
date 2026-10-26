import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rootin_mobile/core/database/database.dart';
import 'package:rootin_mobile/core/database/database_providers.dart';
import 'package:rootin_mobile/core/time/calendar_clock.dart';
import 'package:rootin_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:rootin_mobile/features/settings/settings_provider.dart';
import 'package:timezone/timezone.dart' as tz;

class ReminderEntry {
  const ReminderEntry(this.reminder, this.item);
  final Reminder reminder;
  final Item item;
}

enum ReminderState { overdue, due, soon, later, noDate }

// ponytail: invalid legacy dates remain undated instead of crashing the whole feed;
// add a data repair flow when editing reminders is available.
DateTime? reminderDay(Reminder reminder, [String? zone]) {
  if (reminder.engineType != 'time') return null;
  if (reminder.snoozeUntil != null && zone != null) {
    try {
      final wall = tz.TZDateTime.from(
        parseInstant(reminder.snoozeUntil!),
        locationFor(zone),
      );
      return DateTime.utc(wall.year, wall.month, wall.day);
    } on FormatException {
      // Use the base target date when legacy snooze data is invalid.
    }
  }
  final raw = reminder.targetDate;
  if (raw == null) return null;
  try {
    return parseCalendarDate(raw);
  } on FormatException {
    return null;
  }
}

DateTime todayInZone(DateTime now, String zone) {
  final wall = tz.TZDateTime.from(now, locationFor(zone));
  return DateTime.utc(wall.year, wall.month, wall.day);
}

ReminderState reminderState(Reminder reminder, DateTime today, [String? zone]) {
  final day = reminderDay(reminder, zone);
  if (day == null) return ReminderState.noDate;
  final difference = day.difference(today).inDays;
  if (difference < 0) return ReminderState.overdue;
  if (difference == 0) return ReminderState.due;
  if (difference <= 7) return ReminderState.soon;
  return ReminderState.later;
}

ReminderState entryState(ReminderEntry entry, DateTime today, [String? zone]) {
  final reminder = entry.reminder;
  if (reminder.engineType == 'usage') {
    final count = reminder.usageCounter;
    final threshold = reminder.usageThreshold;
    return count != null && threshold != null && count >= threshold
        ? ReminderState.due
        : ReminderState.noDate;
  }
  if (reminder.engineType == 'mileage') {
    final current = entry.item.currentOdometer;
    final baseline = reminder.lastServiceOdometer;
    final interval = reminder.intervalKm;
    return current != null &&
            baseline != null &&
            interval != null &&
            current >= baseline + interval
        ? ReminderState.due
        : ReminderState.noDate;
  }
  return reminderState(reminder, today, zone);
}

int compareEntries(
  ReminderEntry a,
  ReminderEntry b,
  DateTime today, [
  String? zone,
]) {
  final status = entryState(
    a,
    today,
    zone,
  ).index.compareTo(entryState(b, today, zone).index);
  if (status != 0) return status;
  final aDay = reminderDay(a.reminder, zone);
  final bDay = reminderDay(b.reminder, zone);
  final dayOrder = aDay == null || bDay == null ? 0 : aDay.compareTo(bDay);
  if (dayOrder != 0) return dayOrder;
  final name = a.reminder.name.toLowerCase().compareTo(
    b.reminder.name.toLowerCase(),
  );
  return name != 0 ? name : a.reminder.id.compareTo(b.reminder.id);
}

final reminderFeedProvider = StreamProvider<List<ReminderEntry>>((ref) {
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) return Stream.value([]);
  final db = ref.watch(appDatabaseProvider);
  final query = db.select(db.reminders).join([
    innerJoin(db.items, db.items.id.equalsExp(db.reminders.itemId)),
  ])..where(
    db.reminders.userId.equals(userId) &
        db.items.userId.equals(userId) &
        db.reminders.deletedAt.isNull() &
        db.reminders.isActive.equals(true) &
        db.items.deletedAt.isNull() &
        db.items.isArchived.equals(false),
  );
  return query.watch().map(
    (rows) => [
      for (final row in rows)
        ReminderEntry(row.readTable(db.reminders), row.readTable(db.items)),
    ],
  );
});

final visibleItemsProvider = StreamProvider<List<Item>>((ref) {
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) return Stream.value([]);
  return ref.watch(itemsDaoProvider).watchItems(userId);
});

final historyProvider = StreamProvider<List<ReminderLog>>((ref) {
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) return Stream.value([]);
  return ref.watch(reminderLogsDaoProvider).watchLogs(userId);
});

final pendingOutboxProvider = StreamProvider<int>((ref) {
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) return Stream.value(0);
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.syncOutbox)..where(
    (t) => t.userId.equals(userId) & t.status.equals('pending'),
  )).watch().map((rows) => rows.length);
});

final localTodayProvider = Provider<DateTime?>((ref) {
  final zone = ref.watch(effectiveTimezoneProvider);
  if (zone == null) return null;
  return todayInZone(DateTime.now(), zone);
});
