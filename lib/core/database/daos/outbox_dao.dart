import 'package:drift/drift.dart';
import 'package:rootin_mobile/core/database/database.dart';

part 'outbox_dao.g.dart';

@DriftAccessor(tables: [SyncOutbox])
class OutboxDao extends DatabaseAccessor<AppDatabase> with _$OutboxDaoMixin {
  OutboxDao(super.db);

  /// Streams pending mutations for a user in FIFO order.
  Stream<List<SyncOutboxData>> watchPendingMutations(String userId) {
    return (select(syncOutbox)
          ..where((t) => t.userId.equals(userId) & t.status.equals('pending'))
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .watch();
  }

  /// Gets pending mutations for a user in FIFO order.
  Future<List<SyncOutboxData>> getPendingMutations(
    String userId, {
    int? limit,
  }) {
    final query =
        select(syncOutbox)
          ..where((t) => t.userId.equals(userId) & t.status.equals('pending'))
          ..orderBy([(t) => OrderingTerm.asc(t.id)]);
    if (limit != null) {
      query.limit(limit);
    }
    return query.get();
  }

  /// Gets all mutations for a user regardless of status.
  Future<List<SyncOutboxData>> getAllMutations(String userId) {
    return (select(syncOutbox)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
  }

  /// Gets mutations by status for a user.
  Future<List<SyncOutboxData>> getMutationsByStatus(
    String userId,
    String status,
  ) {
    return (select(syncOutbox)
          ..where((t) => t.userId.equals(userId) & t.status.equals(status))
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
  }

  /// Gets a single mutation by ID.
  Future<SyncOutboxData?> getMutationById(int id) {
    return (select(syncOutbox)
      ..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Gets a mutation by idempotency operation ID.
  Future<SyncOutboxData?> getMutationByOperationId(String operationId) {
    return (select(syncOutbox)
      ..where((t) => t.operationId.equals(operationId))).getSingleOrNull();
  }

  /// Enqueues a mutation entry.
  Future<int> enqueue(SyncOutboxCompanion entry) {
    return into(syncOutbox).insert(entry);
  }

  /// Marks a mutation as processing.
  Future<bool> markProcessing(int id, {String? lastAttemptAt}) async {
    final nowIso = lastAttemptAt ?? DateTime.now().toUtc().toIso8601String();
    final count = await (update(syncOutbox)
      ..where((t) => t.id.equals(id))).write(
      SyncOutboxCompanion(
        status: const Value('processing'),
        lastAttemptAt: Value(nowIso),
      ),
    );
    return count > 0;
  }

  /// Marks a mutation as failed, recording error and optionally incrementing retry count.
  Future<bool> markFailed(
    int id, {
    required String errorMessage,
    String? lastAttemptAt,
    bool incrementRetry = true,
  }) async {
    final existing = await getMutationById(id);
    if (existing == null) return false;

    final nowIso = lastAttemptAt ?? DateTime.now().toUtc().toIso8601String();
    final newRetry =
        incrementRetry ? existing.retryCount + 1 : existing.retryCount;

    final count = await (update(syncOutbox)
      ..where((t) => t.id.equals(id))).write(
      SyncOutboxCompanion(
        status: const Value('failed'),
        errorMessage: Value(errorMessage),
        lastAttemptAt: Value(nowIso),
        retryCount: Value(newRetry),
      ),
    );
    return count > 0;
  }

  /// Marks a mutation as conflict_rejected.
  Future<bool> markConflict(
    int id, {
    required String errorMessage,
    String? lastAttemptAt,
  }) async {
    final nowIso = lastAttemptAt ?? DateTime.now().toUtc().toIso8601String();
    final count = await (update(syncOutbox)
      ..where((t) => t.id.equals(id))).write(
      SyncOutboxCompanion(
        status: const Value('conflict'),
        errorMessage: Value(errorMessage),
        lastAttemptAt: Value(nowIso),
      ),
    );
    return count > 0;
  }

  /// Re-sets a mutation back to pending.
  Future<bool> markPending(int id) async {
    final count = await (update(syncOutbox)..where(
      (t) => t.id.equals(id),
    )).write(const SyncOutboxCompanion(status: Value('pending')));
    return count > 0;
  }

  /// Deletes a mutation by ID upon successful sync.
  Future<int> deleteMutation(int id) {
    return (delete(syncOutbox)..where((t) => t.id.equals(id))).go();
  }

  /// Deletes all mutations for a user.
  Future<int> deleteMutationsForUser(String userId) {
    return (delete(syncOutbox)..where((t) => t.userId.equals(userId))).go();
  }
}
