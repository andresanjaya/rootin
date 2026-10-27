import 'dart:convert';

import 'package:drift/drift.dart';
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
  SupabaseSyncTransport(this.client);
  final SupabaseClient client;

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
  (ref) => SupabaseSyncTransport(Supabase.instance.client),
);

final mobileSyncProvider = Provider<MobileSync>(
  (ref) => MobileSync(
    ref.watch(appDatabaseProvider),
    ref.watch(syncTransportProvider),
    () {
      final session = Supabase.instance.client.auth.currentSession;
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
    try {
      // Snapshot RPC exposes latest row only, not an append-only change log.
      // Each pass starts at null; keep prior checkpoint until replacement commits.
      final queue = await db.outboxDao.getAllMutations(userId);
      for (final row in queue) {
        _checkUser(userId);
        if (row.status == 'conflict' || row.status == 'failed') break;
        if (row.status != 'pending' && row.status != 'processing') break;
        Map<String, dynamic> request;
        try {
          request = _request(row);
        } on FormatException catch (e) {
          await db.outboxDao.markFailed(row.id, errorMessage: '$e');
          break;
        } on StateError catch (e) {
          await db.outboxDao.markFailed(row.id, errorMessage: '$e');
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
        await db.outboxDao.deleteMutation(row.id);
      }
      await _pull(userId);
    } finally {
      _running = false;
    }
  }

  Map<String, dynamic> _request(SyncOutboxData row) {
    final decoded = jsonDecode(row.payloadJson);
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
          decoded['payload'] is! Map) {
        throw const FormatException('Outbox request mismatches its identity');
      }
      return decoded;
    }
    if (row.operationType != 'insert' ||
        row.entityType != 'item' && row.entityType != 'reminder') {
      throw StateError('Legacy mutation requires explicit server version');
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
    Map<String, dynamic>? cursor;
    final all = <Map<String, dynamic>>[];
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
      if (all.length + changes.length > 10000) {
        throw StateError('Sync snapshot exceeds 10000 records');
      }
      final nextCursor = Map<String, dynamic>.from(next as Map);
      if (jsonEncode(cursor) == jsonEncode(nextCursor)) {
        throw const FormatException('Pull cursor did not advance');
      }
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
        all.add({'entity_type': raw['entity_type'], 'record': record});
      }
      cursor = nextCursor;
    }
    await db.transaction(() async {
      _checkUser(userId);
      for (final type in ['item', 'reminder', 'reminder_log']) {
        for (final change in all.where(
          (entry) => entry['entity_type'] == type,
        )) {
          await _apply(userId, type, change['record'] as Map<String, dynamic>);
        }
      }
      _checkUser(userId);
      if (cursor != null) {
        await db.setSyncMetadata(
          SyncMetadataCompanion.insert(
            key: 'pull_cursor',
            userId: userId,
            lastSyncedAt: Value(jsonEncode(cursor)),
            updatedAt: DateTime.now().toUtc().toIso8601String(),
          ),
        );
      }
    });
  }

  Future<bool> _dirty(String userId, String type, String id) async =>
      (await db.outboxDao.getAllMutations(
        userId,
      )).any((row) => row.entityType == type && row.recordId == id);

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
            (row) =>
                row.entityType == 'progress' &&
                ((jsonDecode(row.payloadJson) as Map)['payload']
                        as Map?)?['item_id'] ==
                    id,
          )) {
        return;
      }
      final current =
          await (db.select(db.items)
            ..where((t) => t.id.equals(id))).getSingleOrNull();
      if (current != null && current.userId != userId) {
        throw const FormatException('Local record belongs to another account');
      }
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
                ((jsonDecode(row.payloadJson) as Map)['payload']
                        as Map?)?['reminder_id'] ==
                    id,
          )) {
        return;
      }
      final current =
          await (db.select(db.reminders)
            ..where((t) => t.id.equals(id))).getSingleOrNull();
      if (current != null && current.userId != userId) {
        throw const FormatException('Local record belongs to another account');
      }
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
    }
    // progress_event and preference have no matching synced local table.
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
      if (index < 0 || index != queue.length - 1) {
        throw StateError('Resolve later queued mutations first');
      }
      await db.outboxDao.deleteMutation(outboxId);
      await db.deleteSyncMetadataForUser(userId);
    });
    await run();
  }
}
