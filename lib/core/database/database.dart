import 'package:drift/drift.dart';
import 'package:rootin_mobile/core/database/connection/connection.dart';
import 'package:rootin_mobile/core/database/daos/items_dao.dart';
import 'package:rootin_mobile/core/database/daos/outbox_dao.dart';
import 'package:rootin_mobile/core/database/daos/reminder_logs_dao.dart';
import 'package:rootin_mobile/core/database/daos/reminders_dao.dart';
import 'package:rootin_mobile/core/database/tables.dart';

export 'daos/items_dao.dart';
export 'daos/outbox_dao.dart';
export 'daos/reminder_logs_dao.dart';
export 'daos/reminders_dao.dart';
export 'tables.dart';

part 'database.g.dart';

/// Central Drift database instance for Rootin Mobile.
@DriftDatabase(
  tables: [
    Items,
    Reminders,
    ReminderLogs,
    ProgressEvents,
    SyncOutbox,
    SyncMetadata,
    UserPreferences,
  ],
  daos: [ItemsDao, RemindersDao, ReminderLogsDao, OutboxDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? openConnection());

  /// Creates an in-memory database instance for testing.
  factory AppDatabase.inMemory({bool logStatements = false}) =>
      AppDatabase(openInMemoryConnection(logStatements: logStatements));

  /// Creates a default runtime instance.
  factory AppDatabase.defaults() => AppDatabase();

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      // 1. Enable SQLite foreign key enforcement
      await customStatement('PRAGMA foreign_keys = ON;');
      // 2. Enable Write-Ahead Logging for high concurrency
      await customStatement('PRAGMA journal_mode = WAL;');
      // 3. Normal synchronous mode for performance
      await customStatement('PRAGMA synchronous = NORMAL;');
      if (details.wasCreated) {
        await _createCustomIndexes();
      }
    },
    onCreate: (Migrator m) async {
      await m.createAll();
      await _createCustomIndexes();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) await m.createTable(userPreferences);
      if (from < 3) {
        await m.createTable(progressEvents);
        if (from >= 2) {
          await m.addColumn(userPreferences, userPreferences.version);
        }
        // Existing SQLite CHECK cannot be altered in place; preserve queued rows.
        await customStatement('''CREATE TABLE sync_outbox_new (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            operation_id TEXT NOT NULL UNIQUE, user_id TEXT NOT NULL,
            entity_type TEXT NOT NULL, record_id TEXT NOT NULL,
            operation_type TEXT NOT NULL, payload_json TEXT NOT NULL,
            created_at TEXT NOT NULL, retry_count INTEGER NOT NULL DEFAULT 0,
            last_attempt_at TEXT, status TEXT NOT NULL DEFAULT 'pending', error_message TEXT,
            CHECK (entity_type IN ('item','reminder','reminder_log','progress','completion','preference')),
            CHECK (operation_type IN ('insert','update','delete')),
            CHECK (status IN ('pending','processing','failed','conflict'))
          )''');
        await customStatement(
          'INSERT INTO sync_outbox_new SELECT * FROM sync_outbox',
        );
        await customStatement('DROP TABLE sync_outbox');
        await customStatement(
          'ALTER TABLE sync_outbox_new RENAME TO sync_outbox',
        );
        await _createCustomIndexes();
      }
    },
  );

  /// Creates partial indexes defined in docs/05-database-design.md
  Future<void> _createCustomIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_items_user_active ON items (user_id) WHERE deleted_at IS NULL;',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_items_user_archived ON items (user_id, is_archived) WHERE deleted_at IS NULL;',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_reminders_item ON reminders (item_id) WHERE deleted_at IS NULL;',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_reminders_user_active ON reminders (user_id, is_active) WHERE deleted_at IS NULL;',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_reminders_target_date ON reminders (user_id, target_date) WHERE deleted_at IS NULL;',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_logs_item ON reminder_logs (item_id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_logs_reminder ON reminder_logs (reminder_id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_logs_completed_date ON reminder_logs (user_id, completion_date DESC);',
    );
    await customStatement(
      "CREATE INDEX IF NOT EXISTS idx_outbox_queue ON sync_outbox (user_id, id ASC) WHERE status != 'failed';",
    );
  }

  /// Performs an atomic database transaction where entity changes and
  /// outbox queue entries are committed together. If any action fails,
  /// all mutations and outbox entries are rolled back.
  Future<T> performAtomicMutation<T>({
    required Future<T> Function() action,
    required SyncOutboxCompanion outboxEntry,
  }) {
    return transaction(() async {
      final result = await action();
      await into(syncOutbox).insert(outboxEntry);
      return result;
    });
  }

  /// Performs an atomic transaction with multiple outbox entries.
  Future<T> performAtomicBatchMutation<T>({
    required Future<T> Function() action,
    required List<SyncOutboxCompanion> outboxEntries,
  }) {
    return transaction(() async {
      final result = await action();
      for (final entry in outboxEntries) {
        await into(syncOutbox).insert(entry);
      }
      return result;
    });
  }

  /// Gets sync metadata by key for a user.
  Future<SyncMetadataData?> getSyncMetadata(String userId, String key) {
    return (select(syncMetadata)..where(
      (t) => t.userId.equals(userId) & t.key.equals(key),
    )).getSingleOrNull();
  }

  /// Inserts or updates sync metadata.
  Future<void> setSyncMetadata(SyncMetadataCompanion metadata) {
    return into(syncMetadata).insertOnConflictUpdate(metadata);
  }

  /// Deletes all sync metadata for a user.
  Future<int> deleteSyncMetadataForUser(String userId) {
    return (delete(syncMetadata)..where((t) => t.userId.equals(userId))).go();
  }

  /// Completely clears all data for a specific user (account switch or logout wipe).
  Future<void> clearAllUserData(String userId) async {
    await transaction(() async {
      if ((await outboxDao.getAllMutations(userId)).isNotEmpty) {
        throw StateError('Cannot erase unsynchronized operations');
      }
      await (delete(reminderLogs)..where((t) => t.userId.equals(userId))).go();
      await (delete(progressEvents)
        ..where((t) => t.userId.equals(userId))).go();
      await (delete(reminders)..where((t) => t.userId.equals(userId))).go();
      await (delete(items)..where((t) => t.userId.equals(userId))).go();
      await (delete(syncOutbox)..where((t) => t.userId.equals(userId))).go();
      await (delete(syncMetadata)..where((t) => t.userId.equals(userId))).go();
      await (delete(userPreferences)
        ..where((t) => t.userId.equals(userId))).go();
    });
  }
}
