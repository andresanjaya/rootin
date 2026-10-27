import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';
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

enum ReminderProgress { normal, warning, due, unknown }

class OutboxSummary {
  const OutboxSummary({
    required this.pending,
    required this.failed,
    required this.conflict,
  });

  final int pending;
  final int failed;
  final int conflict;
}

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

ReminderProgress reminderProgress(ReminderEntry entry) {
  final reminder = entry.reminder;
  if (reminder.engineType == 'usage') {
    final count = reminder.usageCounter;
    final threshold = reminder.usageThreshold;
    if (count == null || threshold == null || threshold <= 0) {
      return ReminderProgress.unknown;
    }
    if (count >= threshold) return ReminderProgress.due;
    return count / threshold >= 0.8
        ? ReminderProgress.warning
        : ReminderProgress.normal;
  }
  if (reminder.engineType == 'mileage') {
    final current = entry.item.currentOdometer;
    final baseline = reminder.lastServiceOdometer;
    final interval = reminder.intervalKm;
    if (current == null || baseline == null || interval == null) {
      return ReminderProgress.unknown;
    }
    final remaining = baseline + interval - current;
    if (remaining <= 0) return ReminderProgress.due;
    return remaining <= 500
        ? ReminderProgress.warning
        : ReminderProgress.normal;
  }
  return ReminderProgress.unknown;
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
        db.items.deletedAt.isNull(),
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

final outboxSummaryProvider = StreamProvider<OutboxSummary>((ref) {
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) {
    return Stream.value(
      const OutboxSummary(pending: 0, failed: 0, conflict: 0),
    );
  }
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.syncOutbox)
    ..where((t) => t.userId.equals(userId))).watch().map(
    (rows) => OutboxSummary(
      pending: rows.where((row) => row.status == 'pending').length,
      failed: rows.where((row) => row.status == 'failed').length,
      conflict: rows.where((row) => row.status == 'conflict').length,
    ),
  );
});

final reminderClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

Duration untilNextDay(DateTime now, String zone) {
  final location = locationFor(zone);
  final wall = tz.TZDateTime.from(now, location);
  final midnight = tz.TZDateTime(location, wall.year, wall.month, wall.day + 1);
  return midnight.difference(now);
}

final _localTodayRefreshProvider = StateNotifierProvider<LocalToday, int>((
  ref,
) {
  final zone = ref.watch(effectiveTimezoneProvider);
  return LocalToday(zone, ref.watch(reminderClockProvider));
});

final localTodayProvider = Provider<DateTime?>((ref) {
  ref.watch(_localTodayRefreshProvider);
  final zone = ref.watch(effectiveTimezoneProvider);
  return zone == null
      ? null
      : todayInZone(ref.watch(reminderClockProvider)(), zone);
});

class LocalToday extends StateNotifier<int> with WidgetsBindingObserver {
  LocalToday(this.zone, this.now) : super(0) {
    WidgetsBinding.instance.addObserver(this);
    refresh();
  }

  final String? zone;
  final DateTime Function() now;
  Timer? _timer;

  void refresh() {
    _timer?.cancel();
    if (zone == null) return;
    final instant = now();
    state++;
    final delay = untilNextDay(instant, zone!);
    _timer = Timer(
      delay > Duration.zero ? delay : const Duration(seconds: 1),
      refresh,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refresh();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
