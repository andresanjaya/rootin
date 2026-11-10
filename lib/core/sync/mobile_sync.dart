import 'dart:convert';
import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rootin_mobile/core/database/database.dart';
import 'package:rootin_mobile/core/database/database_providers.dart';
import 'package:rootin_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Transport kept injectable so retry, offline and account changes can be tested.
abstract class SyncTransport {
  Future<Map<String, dynamic>> push(List<Map<String, dynamic>> mutations);
  Future<Map<String, dynamic>> pull(Map<String, dynamic>? cursor);
}

class SupabaseSyncTransport implements SyncTransport {
  SupabaseSyncTransport();
  SupabaseClient get client => Supabase.instance.client;

  @override
  Future<Map<String, dynamic>> push(
    List<Map<String, dynamic>> mutations,
  ) async => Map<String, dynamic>.from(
    await client.rpc('sync_push_mutations', params: {'p_mutations': mutations})
        as Map,
  );

  @override
  Future<Map<String, dynamic>> pull(Map<String, dynamic>? cursor) async =>
      Map<String, dynamic>.from(
        await client.rpc(
              'sync_pull_changes',
              params: {'p_cursor': cursor, 'p_limit': 100},
            )
            as Map,
      );
}

final syncTransportProvider = Provider<SyncTransport>(
  (ref) => SupabaseSyncTransport(),
);

final mobileSyncProvider = Provider<MobileSync>(
  (ref) => MobileSync(
    ref.watch(appDatabaseProvider),
    ref.watch(syncTransportProvider),
    () {
      Session? session;
      try {
        session = Supabase.instance.client.auth.currentSession;
      } on AssertionError {
        return null;
      }
      final user = ref.read(currentUserProvider);
      return session == null || user == null || session.user.id != user.id
          ? null
          : user.id;
    },
  ),
);

class MobileSync {
  MobileSync(this.db, this.transport, this.authenticatedUser);
  final AppDatabase db;
  final SyncTransport transport;
  final String? Function() authenticatedUser;
  bool _running = false;
  final status = ValueNotifier<SyncRunStatus>(const SyncRunStatus());

  void _checkUser(String userId) {
    if (authenticatedUser() != userId) {
      throw StateError('Sync stopped: authenticated account changed');
    }
  }

  /// A single user-scoped pass. Pending rows remain durable on any network error.
  Future<void> run() async {
    if (_running) return;
    final userId = authenticatedUser();
    if (userId == null) {
      throw StateError('Authenticated Supabase session required');
    }
    _running = true;
    status.value = const SyncRunStatus(running: true);
    try {
      final queue = await db.outboxDao.getAllMutations(userId);
      for (final row in queue) {
        _checkUser(userId);
        if (row.status == 'conflict') break;
        if (row.status == 'failed') {
          final attempted = DateTime.tryParse(row.lastAttemptAt ?? '');
          if (attempted == null ||
              DateTime.now().toUtc().difference(attempted) <
                  Duration(seconds: 1 << row.retryCount.clamp(0, 6))) {
            break;
          }
        }
        if (row.status != 'pending' &&
            row.status != 'processing' &&
            row.status != 'failed') {
          break;
        }
        Map<String, dynamic> request;
        try {
          request = _request(row);
        } on FormatException catch (e) {
          await db.outboxDao.markFailed(
            row.id,
            errorMessage: '$e',
            incrementRetry: false,
          );
          break;
        } on StateError catch (e) {
          await db.outboxDao.markFailed(
            row.id,
            errorMessage: '$e',
            incrementRetry: false,
          );
          break;
        }
        await db.outboxDao.markProcessing(row.id);
        _checkUser(userId);
        Map<String, dynamic> response;
        try {
          response = await transport.push([request]);
        } catch (_) {
          _checkUser(userId);
          await db.outboxDao.markPending(row.id);
          rethrow;
        }
        _checkUser(userId);
        final results = response['mutations_result'];
        if (results is! List ||
            results.length != 1 ||
            results.single is! Map ||
            results.single['operation_id'] != row.operationId) {
          await db.outboxDao.markPending(row.id);
          throw const FormatException('Invalid sync push response');
        }
        final result = results.single as Map;
        if (result['status'] == 'conflict_rejected') {
          if (result['server_version'] != null &&
              result['server_version'] is! int) {
            await db.outboxDao.markPending(row.id);
            throw const FormatException('Invalid conflict version');
          }
          await db.outboxDao.markConflict(
            row.id,
            errorMessage: 'Server version: ${result['server_version']}',
          );
          break;
        }
        if (result['status'] != 'accepted') {
          await db.outboxDao.markPending(row.id);
          throw const FormatException('Unknown sync push status');
        }
        if ((result['version'] is! int || result['version'] < 1) &&
            row.entityType != 'progress' &&
            row.entityType != 'completion') {
          await db.outboxDao.markPending(row.id);
          throw const FormatException('Accepted mutation missing version');
        }
        await db.transaction(() async {
          _checkUser(userId);
          final version = result['version'];
          if (version is int) {
            if (row.entityType == 'item') {
              await (db.update(db.items)..where(
                (t) => t.id.equals(row.recordId) & t.userId.equals(userId),
              )).write(ItemsCompanion(version: Value(version)));
            } else if (row.entityType == 'reminder') {
              await (db.update(db.reminders)..where(
                (t) => t.id.equals(row.recordId) & t.userId.equals(userId),
              )).write(RemindersCompanion(version: Value(version)));
            } else if (row.entityType == 'preference') {
              await (db.update(db.userPreferences)..where(
                (t) => t.userId.equals(userId),
              )).write(UserPreferencesCompanion(version: Value(version)));
            }
          }
          // Pull authoritative values after ack; queued writes stay dirty.
          await db.outboxDao.deleteMutation(row.id);
        });
      }
      await _pull(userId);
      final remaining = await db.outboxDao.getAllMutations(userId);
      status.value = SyncRunStatus(
        hasError: remaining.any(
          (r) => r.status == 'failed' || r.status == 'conflict',
        ),
        lastSuccess: DateTime.now().toUtc(),
      );
    } catch (error) {
      status.value = SyncRunStatus(hasError: true, lastError: '$error');
      rethrow;
    } finally {
      _running = false;
      if (status.value.running) {
        status.value = const SyncRunStatus(hasError: true);
      }
    }
  }

  Map<String, dynamic> _request(SyncOutboxData row) {
    dynamic decoded;
    try {
      decoded = jsonDecode(row.payloadJson);
    } on FormatException {
      throw const FormatException('Invalid outbox JSON');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Outbox payload must be a JSON object');
    }
    // New writers must persist the entire immutable RPC request atomically.
    // Legacy insert rows contain only payload; updates cannot infer server version.
    if (decoded.containsKey('operation_id')) {
      if (decoded['operation_id'] != row.operationId ||
          decoded['record_id'] != row.recordId ||
          decoded['entity_type'] != row.entityType ||
          decoded['operation_type'] != row.operationType ||
          decoded['version'] is! int ||
          decoded['version'] < 1 ||
          decoded['payload'] is! Map) {
        throw const FormatException('Outbox request mismatches its identity');
      }
      if (decoded['payload'] is Map &&
          (decoded['payload'] as Map).keys.any((key) => key is! String)) {
        throw const FormatException('Invalid outbox payload keys');
      }
      return Map<String, dynamic>.from(decoded);
    }
    if (row.operationType != 'insert' ||
        row.entityType != 'item' && row.entityType != 'reminder') {
      throw StateError('Legacy mutation requires explicit server version');
    }
    if (decoded['name'] is! String ||
        decoded['name'].trim().isEmpty ||
        row.entityType == 'item' && decoded['category'] is! String ||
        row.entityType == 'reminder' &&
            (decoded['item_id'] is! String ||
                decoded['engine_type'] is! String)) {
      throw const FormatException('Legacy insert payload is incomplete');
    }
    return {
      'operation_id': row.operationId,
      'record_id': row.recordId,
      'entity_type': row.entityType,
      'operation_type': row.operationType,
      'version': 1,
      'payload': decoded,
    };
  }

  Future<void> _pull(String userId) async {
    final stored = await db.getSyncMetadata(userId, 'pull_cursor');
    Map<String, dynamic>? cursor =
        stored?.lastSyncedAt == null
            ? null
            : Map<String, dynamic>.from(
              jsonDecode(stored!.lastSyncedAt!) as Map,
            );
    while (true) {
      _checkUser(userId);
      final page = await transport.pull(cursor);
      _checkUser(userId);
      final changes = page['changes'];
      final next = page['next_cursor'];
      if (changes is! List || next != null && next is! Map) {
        throw const FormatException('Invalid sync pull response');
      }
      if (changes.isNotEmpty && next == null) {
        throw const FormatException('Pull page missing cursor');
      }
      if (changes.isEmpty) break;
      final nextCursor = Map<String, dynamic>.from(next as Map);
      if (nextCursor['sequence'] is! int ||
          nextCursor['sequence'] < 0 ||
          (cursor != null &&
              (cursor['sequence'] is! int ||
                  nextCursor['sequence'] <= cursor['sequence']))) {
        throw const FormatException('Pull cursor did not advance');
      }
      final batch = <Map<String, dynamic>>[];
      for (final raw in changes) {
        if (raw is! Map ||
            raw['record'] is! Map ||
            raw['entity_type'] is! String) {
          throw const FormatException('Invalid sync change');
        }
        final record = Map<String, dynamic>.from(raw['record'] as Map);
        if (record['user_id'] != userId) {
          throw const FormatException('Cross-account sync record');
        }
        batch.add({'entity_type': raw['entity_type'], 'record': record});
      }
      // A skipped dirty change must be replayed after its mutation resolves.
      // Never advance checkpoint past an unapplied record.
      final outstanding = await db.outboxDao.getAllMutations(userId);
      if (batch.any(
        (change) => _blockedByPending(
          change['entity_type'] as String,
          change['record'] as Map<String, dynamic>,
          outstanding,
        ),
      )) {
        break;
      }
      await db.transaction(() async {
        _checkUser(userId);
        for (final type in [
          'item',
          'reminder',
          'reminder_log',
          'progress_event',
          'preference',
        ]) {
          for (final change in batch.where(
            (entry) => entry['entity_type'] == type,
          )) {
            await _apply(
              userId,
              type,
              change['record'] as Map<String, dynamic>,
            );
          }
        }
        _checkUser(userId);
        await db.setSyncMetadata(
          SyncMetadataCompanion.insert(
            key: 'pull_cursor',
            userId: userId,
            lastSyncedAt: Value(jsonEncode(nextCursor)),
            updatedAt: DateTime.now().toUtc().toIso8601String(),
          ),
        );
      });
      cursor = nextCursor;
    }
  }

  Future<bool> _dirty(String userId, String type, String id) async =>
      (await db.outboxDao.getAllMutations(
        userId,
      )).any((row) => row.entityType == type && row.recordId == id);

  bool _blockedByPending(
    String type,
    Map<String, dynamic> record,
    List<SyncOutboxData> pending,
  ) {
    if (pending.isEmpty) return false;
    final id = type == 'preference' ? record['user_id'] : record['id'];
    return pending.any(
      (row) =>
          (row.entityType == type ||
                  type == 'reminder_log' && row.entityType == 'completion' ||
                  type == 'progress_event' && row.entityType == 'progress') &&
              row.recordId == id ||
          (type == 'item' &&
              row.entityType == 'progress' &&
              _queuedParent(row) == id) ||
          (type == 'reminder' &&
              row.entityType == 'completion' &&
              _queuedParent(row, key: 'reminder_id') == id) ||
          ((type == 'reminder' ||
                  type == 'reminder_log' ||
                  type == 'progress_event') &&
              row.entityType == 'item' &&
              row.recordId == record['item_id']) ||
          ((type == 'reminder_log' || type == 'progress_event') &&
              row.entityType == 'reminder' &&
              row.recordId == record['reminder_id']),
    );
  }

  Future<void> _apply(
    String userId,
    String type,
    Map<String, dynamic> r,
  ) async {
    final id = r['id'];
    if (type == 'item') {
      if (id is! String ||
          await _dirty(userId, 'item', id) ||
          (await db.outboxDao.getAllMutations(userId)).any(
            (row) => row.entityType == 'progress' && _queuedParent(row) == id,
          )) {
        return;
      }
      final current =
          await (db.select(db.items)
            ..where((t) => t.id.equals(id))).getSingleOrNull();
      if (current != null && current.userId != userId) {
        throw const FormatException('Local record belongs to another account');
      }
      if (current != null && current.version > (r['version'] as int)) return;
      await db
          .into(db.items)
          .insertOnConflictUpdate(
            ItemsCompanion.insert(
              id: id,
              userId: userId,
              name: r['name'] as String,
              category: r['category'] as String,
              brand: Value(r['brand'] as String?),
              modelNumber: Value(r['model_number'] as String?),
              serialOrPlateNumber: Value(
                r['serial_or_plate_number'] as String?,
              ),
              purchaseDate: Value(r['purchase_date'] as String?),
              hasOdometer: Value(r['has_odometer'] as bool),
              currentOdometer: Value(r['current_odometer'] as int),
              photoRemotePath: Value(r['photo_remote_path'] as String?),
              notes: Value(r['notes'] as String?),
              isArchived: Value(r['is_archived'] as bool),
              createdAt: r['created_at'] as String,
              updatedAt: r['updated_at'] as String,
              deletedAt: Value(r['deleted_at'] as String?),
              version: Value(r['version'] as int),
            ),
          );
    } else if (type == 'reminder') {
      if (id is! String ||
          await _dirty(userId, 'reminder', id) ||
          await _dirty(userId, 'item', r['item_id'] as String) ||
          (await db.outboxDao.getAllMutations(userId)).any(
            (row) =>
                row.entityType == 'completion' &&
                _queuedParent(row, key: 'reminder_id') == id,
          )) {
        return;
      }
      final current =
          await (db.select(db.reminders)
            ..where((t) => t.id.equals(id))).getSingleOrNull();
      if (current != null && current.userId != userId) {
        throw const FormatException('Local record belongs to another account');
      }
      if (current != null && current.version > (r['version'] as int)) return;
      await db
          .into(db.reminders)
          .insertOnConflictUpdate(
            RemindersCompanion.insert(
              id: id,
              userId: userId,
              itemId: r['item_id'] as String,
              name: r['name'] as String,
              engineType: r['engine_type'] as String,
              intervalUnit: Value(r['interval_unit'] as String?),
              intervalValue: Value(r['interval_value'] as int?),
              baselineMode: Value(r['baseline_mode'] as String?),
              anchorDay: Value(r['anchor_day'] as int?),
              targetDate: Value(r['target_date'] as String?),
              targetTime: Value(r['target_time'] as String?),
              usageCounter: Value(r['usage_counter'] as int?),
              usageThreshold: Value(r['usage_threshold'] as int?),
              usageUnit: Value(r['usage_unit'] as String?),
              lastServiceOdometer: Value(r['last_service_odometer'] as int?),
              intervalKm: Value(r['interval_km'] as int?),
              snoozeUntil: Value(r['snooze_until'] as String?),
              isActive: Value(r['is_active'] as bool),
              createdAt: r['created_at'] as String,
              updatedAt: r['updated_at'] as String,
              deletedAt: Value(r['deleted_at'] as String?),
              version: Value(r['version'] as int),
            ),
          );
    } else if (type == 'reminder_log') {
      if (id is! String ||
          await _dirty(userId, 'item', r['item_id'] as String) ||
          await _dirty(userId, 'reminder', r['reminder_id'] as String)) {
        return;
      }
      final current =
          await (db.select(db.reminderLogs)
            ..where((t) => t.id.equals(id))).getSingleOrNull();
      if (current != null && current.userId != userId) {
        throw const FormatException('Local record belongs to another account');
      }
      await db
          .into(db.reminderLogs)
          .insertOnConflictUpdate(
            ReminderLogsCompanion.insert(
              id: id,
              userId: userId,
              itemId: r['item_id'] as String,
              reminderId: r['reminder_id'] as String,
              completedAt: r['completed_at'] as String,
              completionDate: r['completion_date'] as String,
              odometerAtCompletion: Value(r['odometer_at_completion'] as int?),
              cost: Value((r['cost'] as num?)?.toDouble()),
              performedBy: Value(r['performed_by'] as String?),
              notes: Value(r['notes'] as String?),
              createdAt: r['created_at'] as String,
              version: Value(r['version'] as int),
            ),
          );
    } else if (type == 'progress_event') {
      if (id is! String ||
          await _dirty(userId, 'progress', id) ||
          await _dirty(userId, 'item', r['item_id'] as String) ||
          (r['reminder_id'] != null &&
              await _dirty(userId, 'reminder', r['reminder_id'] as String))) {
        return;
      }
      final current =
          await (db.select(db.progressEvents)
            ..where((t) => t.id.equals(id))).getSingleOrNull();
      if (current != null && current.userId != userId) {
        throw const FormatException('Local record belongs to another account');
      }
      await db
          .into(db.progressEvents)
          .insertOnConflictUpdate(
            ProgressEventsCompanion.insert(
              id: id,
              userId: userId,
              itemId: r['item_id'] as String,
              reminderId: Value(r['reminder_id'] as String?),
              kind: r['kind'] as String,
              amount: r['amount'] as int,
              recordedAt: r['recorded_at'] as String,
            ),
          );
    } else if (type == 'preference') {
      if (r['user_id'] != userId ||
          await _dirty(userId, 'preference', userId)) {
        return;
      }
      final current =
          await (db.select(db.userPreferences)
            ..where((t) => t.userId.equals(userId))).getSingleOrNull();
      final version = r['version'] as int;
      if (current != null && version < current.version) return;
      await db
          .into(db.userPreferences)
          .insertOnConflictUpdate(
            UserPreferencesCompanion.insert(
              userId: userId,
              locale: Value(r['locale'] as String?),
              distanceUnit: Value(r['distance_unit'] as String),
              timezoneOverride: Value(r['time_zone'] as String?),
              reminderTime: Value(current?.reminderTime ?? '09:00'),
              version: Value(version),
            ),
          );
    } else {
      throw FormatException('Unsupported sync entity: $type');
    }
  }

  String? _queuedParent(SyncOutboxData row, {String key = 'item_id'}) {
    try {
      final request = _request(row);
      return (request['payload'] as Map)[key] as String?;
    } on FormatException {
      return null; // Malformed rows stay failed; no local write is discarded.
    } on StateError {
      return null;
    }
  }

  /// Explicitly discard one rejected local mutation and reload remote snapshot.
  /// Dependent mutations must be resolved first; no data silently dropped.
  Future<void> acceptServer(String userId, int outboxId) async {
    _checkUser(userId);
    await db.transaction(() async {
      final queue = await db.outboxDao.getAllMutations(userId);
      final index = queue.indexWhere(
        (row) => row.id == outboxId && row.status == 'conflict',
      );
      if (index < 0) {
        throw StateError('Conflict not found');
      }
      if (queue
          .skip(index + 1)
          .any(
            (row) =>
                row.recordId == queue[index].recordId ||
                _queuedParent(row) == queue[index].recordId ||
                _queuedParent(row, key: 'reminder_id') == queue[index].recordId,
          )) {
        throw StateError('Resolve dependent queued mutations first');
      }
      await db.outboxDao.deleteMutation(outboxId);
      await db.deleteSyncMetadataForUser(userId);
    });
    await run();
  }
}

class SyncRunStatus {
  const SyncRunStatus({
    this.running = false,
    this.hasError = false,
    this.lastSuccess,
    this.lastError,
  });
  final bool running;
  final bool hasError;
  final DateTime? lastSuccess;
  final String? lastError;
}
