import 'package:drift/drift.dart';
import 'package:rootin_mobile/core/database/database.dart';

part 'reminder_logs_dao.g.dart';

@DriftAccessor(tables: [ReminderLogs])
class ReminderLogsDao extends DatabaseAccessor<AppDatabase>
    with _$ReminderLogsDaoMixin {
  ReminderLogsDao(super.db);

  /// Streams immutable reminder logs for a user.
  Stream<List<ReminderLog>> watchLogs(
    String userId, {
    String? itemId,
    String? reminderId,
  }) {
    final query = select(reminderLogs)..where((t) => t.userId.equals(userId));
    if (itemId != null) {
      query.where((t) => t.itemId.equals(itemId));
    }
    if (reminderId != null) {
      query.where((t) => t.reminderId.equals(reminderId));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.completedAt)]);
    return query.watch();
  }

  /// Gets immutable reminder logs for a user.
  Future<List<ReminderLog>> getLogs(
    String userId, {
    String? itemId,
    String? reminderId,
    int? limit,
  }) {
    final query = select(reminderLogs)..where((t) => t.userId.equals(userId));
    if (itemId != null) {
      query.where((t) => t.itemId.equals(itemId));
    }
    if (reminderId != null) {
      query.where((t) => t.reminderId.equals(reminderId));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.completedAt)]);
    if (limit != null) {
      query.limit(limit);
    }
    return query.get();
  }

  /// Gets a log entry by ID for the user.
  Future<ReminderLog?> getLogById(String userId, String id) {
    return (select(reminderLogs)..where(
      (t) => t.userId.equals(userId) & t.id.equals(id),
    )).getSingleOrNull();
  }

  /// Inserts a log entry (append-only audit trail).
  Future<int> insertLog(
    ReminderLogsCompanion log, {
    InsertMode mode = InsertMode.insertOrReplace,
  }) {
    return into(reminderLogs).insert(log, mode: mode);
  }

  /// Deletes all logs for a user.
  Future<int> deleteAllForUser(String userId) {
    return (delete(reminderLogs)..where((t) => t.userId.equals(userId))).go();
  }
}
