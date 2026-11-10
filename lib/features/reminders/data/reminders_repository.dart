import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rootin_mobile/core/database/database.dart';
import 'package:rootin_mobile/core/database/database_providers.dart';
import 'package:rootin_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:rootin_mobile/features/reminders/domain/reminder_rules.dart';

String generateUuidV4() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40; // Version 4
  bytes[8] = (bytes[8] & 0x3f) | 0x80; // Variant 10xx
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}

/// DTO representing the submitted form data for creating or updating a reminder.
class ReminderFormData {
  const ReminderFormData({
    this.id,
    required this.itemId,
    required this.name,
    required this.engineType,
    // Time-based
    this.intervalUnit,
    this.intervalValue,
    this.baselineMode = 'actual_completion',
    this.anchorDay,
    this.targetDate,
    this.targetTime,
    // Usage-based
    this.usageCounter = 0,
    this.usageThreshold,
    this.usageUnit,
    // Mileage-based
    this.lastServiceOdometer,
    this.intervalKm,
    // Audit / state
    this.isActive = true,
  });

  final String? id;
  final String itemId;
  final String name;
  final String engineType;

  final String? intervalUnit;
  final int? intervalValue;
  final String baselineMode;
  final int? anchorDay;
  final String? targetDate;
  final String? targetTime;

  final int usageCounter;
  final int? usageThreshold;
  final String? usageUnit;

  final int? lastServiceOdometer;
  final int? intervalKm;
  final bool isActive;
}

class RemindersRepository {
  RemindersRepository(this.db);
  final AppDatabase db;

  /// In-memory guard to prevent double-submit within the app session.
  final Set<String> _inFlightOperations = <String>{};

  /// Gets all active items owned by the specified user.
  Future<List<Item>> getActiveItems(String userId) {
    return db.itemsDao.getItems(userId);
  }

  /// Streams active items owned by the specified user.
  Stream<List<Item>> watchActiveItems(String userId) {
    return db.itemsDao.watchItems(userId);
  }

  /// Gets a single reminder by ID.
  Future<Reminder?> getReminderById(String userId, String reminderId) {
    return db.remindersDao.getReminderById(userId, reminderId);
  }

  /// Saves a reminder atomically to local Drift DB and enqueues durable mutation in outbox.
  /// Throws [StateError] or [ArgumentError] if invalid or in-flight duplicate submission occurs.
  Future<String> saveReminder({
    required String userId,
    required ReminderFormData data,
  }) async {
    // 1. Verify item exists and belongs to user
    final item = await db.itemsDao.getItemById(userId, data.itemId);
    if (item == null || item.userId != userId || item.isArchived) {
      throw StateError('Active owned item is required');
    }

    // 2. Validate form data with domain rules
    final validationErrors = ReminderRules.validateReminderForm(
      name: data.name,
      engineType: data.engineType,
      itemId: data.itemId,
      intervalValue: data.intervalValue,
      intervalUnit: data.intervalUnit,
      targetDate: data.targetDate,
      targetTime: data.targetTime,
      anchorDay: data.anchorDay,
      usageThreshold: data.usageThreshold,
      usageCounter: data.usageCounter,
      intervalKm: data.intervalKm,
      lastServiceOdometer: data.lastServiceOdometer,
      itemHasOdometer: item.hasOdometer,
    );

    if (validationErrors != null && validationErrors.isNotEmpty) {
      throw ArgumentError('Validation failed: $validationErrors');
    }

    final isEdit = data.id != null && data.id!.trim().isNotEmpty;
    final reminderId = isEdit ? data.id! : generateUuidV4();

    // Idempotency / Double submit guard
    if (_inFlightOperations.contains(reminderId)) {
      throw StateError(
        'A save operation for this reminder is already in flight',
      );
    }
    _inFlightOperations.add(reminderId);

    try {
      final nowUtcIso = DateTime.now().toUtc().toIso8601String();
      final operationId = generateUuidV4();

      return await db.transaction(() async {
        Reminder? existing;
        if (isEdit) {
          existing = await db.remindersDao.getReminderById(userId, reminderId);
          if (existing == null) {
            throw StateError('Reminder to update not found: $reminderId');
          }
          if (existing.engineType != data.engineType) {
            throw ArgumentError(
              'Engine type cannot be changed on an existing reminder',
            );
          }
        }

        final version = isEdit ? existing!.version : 1;
        final nextVersion = isEdit ? version + 1 : 1;

        // Prepare companion for Drift
        final companion = RemindersCompanion(
          id: Value(reminderId),
          userId: Value(userId),
          itemId: Value(data.itemId),
          name: Value(data.name.trim()),
          engineType: Value(data.engineType),
          intervalUnit: Value(data.intervalUnit),
          intervalValue: Value(data.intervalValue),
          baselineMode: Value(data.baselineMode),
          anchorDay: Value(data.anchorDay),
          targetDate: Value(data.targetDate),
          targetTime: Value(data.targetTime),
          usageCounter: Value(data.usageCounter),
          usageThreshold: Value(data.usageThreshold),
          usageUnit: Value(data.usageUnit),
          lastServiceOdometer: Value(data.lastServiceOdometer),
          intervalKm: Value(data.intervalKm),
          isActive: Value(data.isActive),
          createdAt: Value(isEdit ? existing!.createdAt : nowUtcIso),
          updatedAt: Value(nowUtcIso),
          version: Value(nextVersion),
        );

        if (isEdit) {
          await db.remindersDao.updateReminder(userId, companion);
        } else {
          await db.remindersDao.insertReminder(companion);
        }

        // Construct payload according to backend sync_push_mutations schema
        final Map<String, dynamic> rpcPayload = <String, dynamic>{
          'name': data.name.trim(),
          if (!isEdit) 'item_id': data.itemId,
          if (!isEdit) 'engine_type': data.engineType,
          if (data.intervalUnit != null) 'interval_unit': data.intervalUnit,
          if (data.intervalValue != null) 'interval_value': data.intervalValue,
          'baseline_mode': data.baselineMode,
          if (data.anchorDay != null) 'anchor_day': data.anchorDay,
          if (data.targetDate != null) 'target_date': data.targetDate,
          if (data.targetTime != null) 'target_time': data.targetTime,
          'usage_counter': data.usageCounter,
          if (data.usageThreshold != null)
            'usage_threshold': data.usageThreshold,
          if (data.usageUnit != null) 'usage_unit': data.usageUnit,
          if (data.lastServiceOdometer != null)
            'last_service_odometer': data.lastServiceOdometer,
          if (data.intervalKm != null) 'interval_km': data.intervalKm,
          'is_active': data.isActive,
        };

        final outboxRequest = {
          'operation_id': operationId,
          'record_id': reminderId,
          'entity_type': 'reminder',
          'operation_type': isEdit ? 'update' : 'insert',
          'version': isEdit ? version : 1,
          'payload': rpcPayload,
        };

        await db.outboxDao.enqueue(
          SyncOutboxCompanion.insert(
            operationId: operationId,
            userId: userId,
            entityType: 'reminder',
            recordId: reminderId,
            operationType: isEdit ? 'update' : 'insert',
            createdAt: nowUtcIso,
            payloadJson: jsonEncode(outboxRequest),
          ),
        );

        return reminderId;
      });
    } finally {
      _inFlightOperations.remove(reminderId);
    }
  }

  /// Gets an item by ID.
  Future<Item?> getItemById(String userId, String itemId) {
    return db.itemsDao.getItemById(userId, itemId);
  }

  /// Streams a single item by ID.
  Stream<Item?> watchItemById(String userId, String itemId) {
    return db.itemsDao.watchItemById(userId, itemId);
  }

  /// Streams a single reminder by ID.
  Stream<Reminder?> watchReminderById(String userId, String reminderId) {
    return db.remindersDao.watchReminderById(userId, reminderId);
  }

  /// Streams logs for a specific reminder.
  Stream<List<ReminderLog>> watchReminderLogs(
    String userId,
    String reminderId,
  ) {
    return db.reminderLogsDao.watchLogs(userId, reminderId: reminderId);
  }

  /// Streams all logs for a user.
  Stream<List<ReminderLog>> watchAllLogs(String userId) {
    return db.reminderLogsDao.watchLogs(userId);
  }

  /// Completes a reminder service cycle, creating an audit log and advancing schedule.
  Future<String> completeReminderCycle({
    required String userId,
    required String reminderId,
    required String completionDate,
    int? odometerAtCompletion,
    double? cost,
    String? performedBy,
    String? notes,
  }) async {
    final reminder = await db.remindersDao.getReminderById(userId, reminderId);
    if (reminder == null) throw StateError('Active owned reminder required');
    final item = await db.itemsDao.getItemById(userId, reminder.itemId);
    if (item == null) throw StateError('Active owned item required');

    final logs = await db.reminderLogsDao.getLogs(
      userId,
      reminderId: reminderId,
      limit: 1,
    );
    final previousCompletionDate =
        logs.isNotEmpty ? logs.first.completionDate : null;

    final calc = ReminderRules.calculateCycleCompletion(
      reminder: reminder,
      completionDate: completionDate,
      odometerAtCompletion: odometerAtCompletion,
      previousCompletionDate: previousCompletionDate,
    );

    final logId = generateUuidV4();
    final operationId = generateUuidV4();
    final completedAtIso = DateTime.now().toUtc().toIso8601String();

    return await db.transaction(() async {
      await db.reminderLogsDao.insertLog(
        ReminderLogsCompanion.insert(
          id: logId,
          userId: userId,
          itemId: reminder.itemId,
          reminderId: reminderId,
          completedAt: completedAtIso,
          completionDate: completionDate,
          odometerAtCompletion: Value(odometerAtCompletion),
          cost: Value(cost),
          performedBy: Value(performedBy),
          notes: Value(notes),
          createdAt: completedAtIso,
          version: const Value(1),
        ),
      );

      await db.remindersDao.updateReminder(
        userId,
        RemindersCompanion(
          id: Value(reminderId),
          targetDate: Value(calc.nextTargetDate),
          lastServiceOdometer: Value(calc.newLastServiceOdometer),
          usageCounter: Value(calc.newUsageCounter ?? reminder.usageCounter),
          snoozeUntil: const Value(null),
          version: Value(calc.newVersion),
          updatedAt: Value(completedAtIso),
        ),
      );

      final rpcPayload = <String, dynamic>{
        'item_id': reminder.itemId,
        'reminder_id': reminderId,
        'completed_at': completedAtIso,
        'completion_date': completionDate,
        if (odometerAtCompletion != null)
          'odometer_at_completion': odometerAtCompletion,
        if (cost != null) 'cost': cost,
        if (performedBy != null) 'performed_by': performedBy,
        if (notes != null) 'notes': notes,
      };

      final outboxRequest = {
        'operation_id': operationId,
        'record_id': logId,
        'entity_type': 'completion',
        'operation_type': 'insert',
        'version': reminder.version,
        'payload': rpcPayload,
      };

      await db.outboxDao.enqueue(
        SyncOutboxCompanion.insert(
          operationId: operationId,
          userId: userId,
          entityType: 'completion',
          recordId: logId,
          operationType: 'insert',
          createdAt: completedAtIso,
          payloadJson: jsonEncode(outboxRequest),
        ),
      );

      return logId;
    });
  }

  /// Increments usage counter and records a progress event atomically.
  Future<String> recordUsageIncrement({
    required String userId,
    required String reminderId,
    int amount = 1,
  }) async {
    final reminder = await db.remindersDao.getReminderById(userId, reminderId);
    if (reminder == null || reminder.engineType != 'usage') {
      throw StateError('Active owned usage reminder required');
    }

    final progressEventId = generateUuidV4();
    final operationId = generateUuidV4();
    final nowIso = DateTime.now().toUtc().toIso8601String();

    return await db.transaction(() async {
      final newCounter = (reminder.usageCounter ?? 0) + amount;
      final newVersion = reminder.version + 1;

      await db.remindersDao.updateReminder(
        userId,
        RemindersCompanion(
          id: Value(reminderId),
          usageCounter: Value(newCounter),
          version: Value(newVersion),
          updatedAt: Value(nowIso),
        ),
      );

      await db
          .into(db.progressEvents)
          .insert(
            ProgressEventsCompanion.insert(
              id: progressEventId,
              userId: userId,
              itemId: reminder.itemId,
              reminderId: Value(reminderId),
              kind: 'usage',
              amount: amount,
              recordedAt: nowIso,
            ),
          );

      final outboxRequest = {
        'operation_id': operationId,
        'record_id': progressEventId,
        'entity_type': 'progress',
        'operation_type': 'insert',
        'version': 1,
        'payload': {
          'item_id': reminder.itemId,
          'reminder_id': reminderId,
          'kind': 'usage',
          'amount': amount,
        },
      };

      await db.outboxDao.enqueue(
        SyncOutboxCompanion.insert(
          operationId: operationId,
          userId: userId,
          entityType: 'progress',
          recordId: progressEventId,
          operationType: 'insert',
          createdAt: nowIso,
          payloadJson: jsonEncode(outboxRequest),
        ),
      );

      return progressEventId;
    });
  }

  /// Updates vehicle odometer and records an odometer progress event atomically.
  Future<String> recordOdometerUpdate({
    required String userId,
    required String itemId,
    required int newOdometer,
  }) async {
    final item = await db.itemsDao.getItemById(userId, itemId);
    if (item == null || !item.hasOdometer) {
      throw StateError('Active owned vehicle item required');
    }
    if (newOdometer < (item.currentOdometer ?? 0)) {
      throw ArgumentError(
        'Odometer cannot decrease: $newOdometer < ${item.currentOdometer}',
      );
    }

    final progressEventId = generateUuidV4();
    final operationId = generateUuidV4();
    final nowIso = DateTime.now().toUtc().toIso8601String();

    return await db.transaction(() async {
      await db.itemsDao.updateItem(
        userId,
        ItemsCompanion(
          id: Value(itemId),
          currentOdometer: Value(newOdometer),
          version: Value(item.version + 1),
          updatedAt: Value(nowIso),
        ),
      );

      await db
          .into(db.progressEvents)
          .insert(
            ProgressEventsCompanion.insert(
              id: progressEventId,
              userId: userId,
              itemId: itemId,
              kind: 'odometer',
              amount: newOdometer,
              recordedAt: nowIso,
            ),
          );

      final outboxRequest = {
        'operation_id': operationId,
        'record_id': progressEventId,
        'entity_type': 'progress',
        'operation_type': 'insert',
        'version': 1,
        'payload': {
          'item_id': itemId,
          'kind': 'odometer',
          'amount': newOdometer,
        },
      };

      await db.outboxDao.enqueue(
        SyncOutboxCompanion.insert(
          operationId: operationId,
          userId: userId,
          entityType: 'progress',
          recordId: progressEventId,
          operationType: 'insert',
          createdAt: nowIso,
          payloadJson: jsonEncode(outboxRequest),
        ),
      );

      return progressEventId;
    });
  }
}

final remindersRepositoryProvider = Provider<RemindersRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return RemindersRepository(db);
});

final reminderDetailProvider = StreamProvider.family<Reminder?, String>((
  ref,
  reminderId,
) {
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) return Stream.value(null);
  return ref
      .watch(remindersRepositoryProvider)
      .watchReminderById(userId, reminderId);
});

final itemDetailProvider = StreamProvider.family<Item?, String>((ref, itemId) {
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) return Stream.value(null);
  return ref.watch(remindersRepositoryProvider).watchItemById(userId, itemId);
});

final reminderLogsProvider = StreamProvider.family<List<ReminderLog>, String>((
  ref,
  reminderId,
) {
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) return Stream.value([]);
  return ref
      .watch(remindersRepositoryProvider)
      .watchReminderLogs(userId, reminderId);
});
