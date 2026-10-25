import 'package:drift/drift.dart';

/// Items table definition.
@DataClassName('Item')
class Items extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get category => text()();
  TextColumn get brand => text().nullable()();
  TextColumn get modelNumber => text().nullable()();
  TextColumn get serialOrPlateNumber => text().nullable()();
  TextColumn get purchaseDate => text().nullable()();
  BoolColumn get hasOdometer => boolean().withDefault(const Constant(false))();
  IntColumn get currentOdometer =>
      integer().nullable().withDefault(const Constant(0))();
  TextColumn get photoLocalPath => text().nullable()();
  TextColumn get photoRemotePath => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  TextColumn get deletedAt => text().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (category IN ('vehicle', 'appliance', 'furniture', 'facility', 'other'))",
  ];
}

/// Reminders table definition.
@DataClassName('Reminder')
class Reminders extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get itemId =>
      text().references(Items, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get engineType => text()();

  // Time-based
  TextColumn get intervalUnit => text().nullable()();
  IntColumn get intervalValue => integer().nullable()();
  TextColumn get baselineMode =>
      text().nullable().withDefault(const Constant('actual_completion'))();
  IntColumn get anchorDay => integer().nullable()();
  TextColumn get targetDate => text().nullable()();
  TextColumn get targetTime => text().nullable()();

  // Usage-based
  IntColumn get usageCounter =>
      integer().nullable().withDefault(const Constant(0))();
  IntColumn get usageThreshold => integer().nullable()();
  TextColumn get usageUnit => text().nullable()();

  // Mileage-based
  IntColumn get lastServiceOdometer => integer().nullable()();
  IntColumn get intervalKm => integer().nullable()();

  // Snooze & status
  TextColumn get snoozeUntil => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  // Audit
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  TextColumn get deletedAt => text().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (engine_type IN ('time', 'usage', 'mileage'))",
    "CHECK (interval_unit IS NULL OR interval_unit IN ('days', 'weeks', 'months', 'years'))",
    "CHECK (interval_value IS NULL OR interval_value > 0)",
    "CHECK (baseline_mode IS NULL OR baseline_mode IN ('actual_completion', 'strict_schedule'))",
    "CHECK (anchor_day IS NULL OR (anchor_day BETWEEN 1 AND 31))",
    "CHECK (usage_counter IS NULL OR usage_counter >= 0)",
    "CHECK (usage_threshold IS NULL OR usage_threshold > 0)",
    "CHECK (last_service_odometer IS NULL OR last_service_odometer >= 0)",
    "CHECK (interval_km IS NULL OR interval_km > 0)",
  ];
}

/// Reminder logs table definition (immutable audit trail).
@DataClassName('ReminderLog')
class ReminderLogs extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get itemId =>
      text().references(Items, #id, onDelete: KeyAction.cascade)();
  TextColumn get reminderId =>
      text().references(Reminders, #id, onDelete: KeyAction.cascade)();
  TextColumn get completedAt => text()();
  TextColumn get completionDate => text()();
  IntColumn get odometerAtCompletion => integer().nullable()();
  RealColumn get cost => real().nullable()();
  TextColumn get performedBy => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdAt => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Durable outbox table for local mutation queue.
@DataClassName('SyncOutboxData')
class SyncOutbox extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get operationId => text().unique()();
  TextColumn get userId => text()();
  TextColumn get entityType => text()();
  TextColumn get recordId => text()();
  TextColumn get operationType => text()();
  TextColumn get payloadJson => text()();
  TextColumn get createdAt => text()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastAttemptAt => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get errorMessage => text().nullable()();

  @override
  List<String> get customConstraints => [
    "CHECK (entity_type IN ('item', 'reminder', 'reminder_log'))",
    "CHECK (operation_type IN ('insert', 'update', 'delete'))",
    "CHECK (status IN ('pending', 'processing', 'failed', 'conflict'))",
  ];
}

/// Sync metadata table for tracking sync checkpoints per user.
@DataClassName('SyncMetadataData')
class SyncMetadata extends Table {
  TextColumn get key => text()();
  TextColumn get userId => text()();
  TextColumn get lastSyncedAt => text().nullable()();
  IntColumn get lastServerVersion =>
      integer().nullable().withDefault(const Constant(0))();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {key, userId};
}

/// Device-local preferences scoped by authenticated user; never sent to outbox.
class UserPreferences extends Table {
  TextColumn get userId => text()();
  TextColumn get locale => text().nullable()();
  TextColumn get distanceUnit => text().withDefault(const Constant('km'))();
  TextColumn get timezoneOverride => text().nullable()();
  TextColumn get reminderTime => text().withDefault(const Constant('09:00'))();

  @override
  Set<Column> get primaryKey => {userId};

  @override
  List<String> get customConstraints => [
    "CHECK (locale IS NULL OR locale IN ('id', 'en'))",
    "CHECK (distance_unit IN ('km', 'mi'))",
    "CHECK (reminder_time GLOB '[0-2][0-9]:[0-5][0-9]' AND reminder_time BETWEEN '00:00' AND '23:59')",
  ];
}
