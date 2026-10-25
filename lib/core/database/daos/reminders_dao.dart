import 'package:drift/drift.dart';
import 'package:rootin_mobile/core/database/database.dart';

part 'reminders_dao.g.dart';

@DriftAccessor(tables: [Reminders])
class RemindersDao extends DatabaseAccessor<AppDatabase>
    with _$RemindersDaoMixin {
  RemindersDao(super.db);

  /// Streams active reminders for the specified user.
  Stream<List<Reminder>> watchReminders(
    String userId, {
    String? itemId,
    bool activeOnly = false,
  }) {
    final query = select(reminders)
      ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull());
    if (itemId != null) {
      query.where((t) => t.itemId.equals(itemId));
    }
    if (activeOnly) {
      query.where((t) => t.isActive.equals(true));
    }
    query.orderBy([(t) => OrderingTerm.asc(t.targetDate)]);
    return query.watch();
  }

  /// Gets active reminders for the specified user.
  Future<List<Reminder>> getReminders(
    String userId, {
    String? itemId,
    bool activeOnly = false,
  }) {
    final query = select(reminders)
      ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull());
    if (itemId != null) {
      query.where((t) => t.itemId.equals(itemId));
    }
    if (activeOnly) {
      query.where((t) => t.isActive.equals(true));
    }
    query.orderBy([(t) => OrderingTerm.asc(t.targetDate)]);
    return query.get();
  }

  /// Gets a single reminder by ID for the specified user.
  Future<Reminder?> getReminderById(String userId, String id) {
    return (select(reminders)..where(
      (t) => t.userId.equals(userId) & t.id.equals(id) & t.deletedAt.isNull(),
    )).getSingleOrNull();
  }

  /// Streams a single reminder by ID for the specified user.
  Stream<Reminder?> watchReminderById(String userId, String id) {
    return (select(reminders)..where(
      (t) => t.userId.equals(userId) & t.id.equals(id) & t.deletedAt.isNull(),
    )).watchSingleOrNull();
  }

  /// Inserts or replaces a reminder.
  Future<int> insertReminder(
    RemindersCompanion reminder, {
    InsertMode mode = InsertMode.insertOrReplace,
  }) {
    return into(reminders).insert(reminder, mode: mode);
  }

  /// Updates a reminder scoped to the user.
  Future<bool> updateReminder(
    String userId,
    RemindersCompanion reminder,
  ) async {
    final count = await (update(reminders)..where(
      (t) => t.id.equals(reminder.id.value) & t.userId.equals(userId),
    )).write(reminder);
    return count > 0;
  }

  /// Soft deletes a reminder by setting deletedAt and version.
  Future<bool> softDeleteReminder(
    String userId,
    String id, {
    required String deletedAt,
    required int version,
    required String updatedAt,
  }) async {
    final count = await (update(reminders)
      ..where((t) => t.id.equals(id) & t.userId.equals(userId))).write(
      RemindersCompanion(
        deletedAt: Value(deletedAt),
        version: Value(version),
        updatedAt: Value(updatedAt),
      ),
    );
    return count > 0;
  }

  /// Permanently deletes a reminder scoped to the user.
  Future<int> deleteReminderPermanently(String userId, String id) {
    return (delete(reminders)
      ..where((t) => t.id.equals(id) & t.userId.equals(userId))).go();
  }

  /// Deletes all reminders belonging to a user.
  Future<int> deleteAllForUser(String userId) {
    return (delete(reminders)..where((t) => t.userId.equals(userId))).go();
  }
}
