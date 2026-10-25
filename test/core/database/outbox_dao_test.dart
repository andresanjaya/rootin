import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rootin_mobile/core/database/database.dart';

void main() {
  late AppDatabase db;
  const userId = 'user-outbox-test';

  setUp(() {
    db = AppDatabase.inMemory();
  });

  tearDown(() async {
    await db.close();
  });

  group('OutboxDao operations & status transitions', () {
    test('enqueues mutations and preserves FIFO order', () async {
      final now = DateTime.now().toUtc().toIso8601String();

      final id1 = await db.outboxDao.enqueue(
        SyncOutboxCompanion.insert(
          operationId: 'op-1',
          userId: userId,
          entityType: 'item',
          recordId: 'rec-1',
          operationType: 'insert',
          payloadJson: '{"step": 1}',
          createdAt: now,
        ),
      );

      final id2 = await db.outboxDao.enqueue(
        SyncOutboxCompanion.insert(
          operationId: 'op-2',
          userId: userId,
          entityType: 'reminder',
          recordId: 'rec-2',
          operationType: 'insert',
          payloadJson: '{"step": 2}',
          createdAt: now,
        ),
      );

      final id3 = await db.outboxDao.enqueue(
        SyncOutboxCompanion.insert(
          operationId: 'op-3',
          userId: userId,
          entityType: 'reminder_log',
          recordId: 'rec-3',
          operationType: 'insert',
          payloadJson: '{"step": 3}',
          createdAt: now,
        ),
      );

      expect(id1 < id2 && id2 < id3, isTrue);

      final pending = await db.outboxDao.getPendingMutations(userId);
      expect(pending, hasLength(3));
      expect(pending[0].operationId, 'op-1');
      expect(pending[1].operationId, 'op-2');
      expect(pending[2].operationId, 'op-3');
    });

    test(
      'transitions status: pending -> processing -> failed -> conflict -> pending',
      () async {
        final now = DateTime.now().toUtc().toIso8601String();

        final id = await db.outboxDao.enqueue(
          SyncOutboxCompanion.insert(
            operationId: 'op-lifecycle',
            userId: userId,
            entityType: 'item',
            recordId: 'rec-item-1',
            operationType: 'update',
            payloadJson: '{"name": "New Name"}',
            createdAt: now,
          ),
        );

        // Initial state: pending, retryCount = 0
        var mut = await db.outboxDao.getMutationById(id);
        expect(mut?.status, 'pending');
        expect(mut?.retryCount, 0);
        expect(mut?.lastAttemptAt, isNull);

        // Transition to processing
        final markProcResult = await db.outboxDao.markProcessing(id);
        expect(markProcResult, isTrue);
        mut = await db.outboxDao.getMutationById(id);
        expect(mut?.status, 'processing');
        expect(mut?.lastAttemptAt, isNotNull);

        // Transition to failed
        final markFailResult = await db.outboxDao.markFailed(
          id,
          errorMessage: '503 Service Unavailable',
          incrementRetry: true,
        );
        expect(markFailResult, isTrue);
        mut = await db.outboxDao.getMutationById(id);
        expect(mut?.status, 'failed');
        expect(mut?.errorMessage, '503 Service Unavailable');
        expect(mut?.retryCount, 1);

        // Transition to conflict (conflict_rejected from server LWW check)
        final markConflictResult = await db.outboxDao.markConflict(
          id,
          errorMessage: 'conflict_rejected: server_version = 4',
        );
        expect(markConflictResult, isTrue);
        mut = await db.outboxDao.getMutationById(id);
        expect(mut?.status, 'conflict');
        expect(mut?.errorMessage, 'conflict_rejected: server_version = 4');

        // Failed and conflict rows are NOT returned in getPendingMutations
        expect(await db.outboxDao.getPendingMutations(userId), isEmpty);

        // Can be retrieved via getMutationsByStatus
        final conflictList = await db.outboxDao.getMutationsByStatus(
          userId,
          'conflict',
        );
        expect(conflictList, hasLength(1));
        expect(conflictList.first.id, id);

        // Reset back to pending
        final markPendingResult = await db.outboxDao.markPending(id);
        expect(markPendingResult, isTrue);
        mut = await db.outboxDao.getMutationById(id);
        expect(mut?.status, 'pending');

        // Returned in getPendingMutations again
        expect(await db.outboxDao.getPendingMutations(userId), hasLength(1));

        // Successfully processed: delete from outbox
        final deleteCount = await db.outboxDao.deleteMutation(id);
        expect(deleteCount, 1);
        expect(await db.outboxDao.getMutationById(id), isNull);
      },
    );

    test('enforces CHECK constraint on sync_outbox status', () async {
      final now = DateTime.now().toUtc().toIso8601String();

      // Invalid status throws SQLite constraint exception
      expect(
        () => db.outboxDao.enqueue(
          SyncOutboxCompanion.insert(
            operationId: 'op-invalid-status',
            userId: userId,
            entityType: 'item',
            recordId: 'rec-1',
            operationType: 'insert',
            payloadJson: '{}',
            createdAt: now,
            status: const Value('unknown_status'), // Invalid!
          ),
        ),
        throwsA(isA<SqliteException>()),
      );
    });

    test(
      'enforces CHECK constraint on sync_outbox entity_type and operation_type',
      () async {
        final now = DateTime.now().toUtc().toIso8601String();

        // Invalid entity_type
        expect(
          () => db.outboxDao.enqueue(
            SyncOutboxCompanion.insert(
              operationId: 'op-invalid-entity',
              userId: userId,
              entityType: 'invalid_entity',
              recordId: 'rec-1',
              operationType: 'insert',
              payloadJson: '{}',
              createdAt: now,
            ),
          ),
          throwsA(isA<SqliteException>()),
        );

        // Invalid operation_type
        expect(
          () => db.outboxDao.enqueue(
            SyncOutboxCompanion.insert(
              operationId: 'op-invalid-op',
              userId: userId,
              entityType: 'item',
              recordId: 'rec-1',
              operationType: 'truncate', // Invalid!
              payloadJson: '{}',
              createdAt: now,
            ),
          ),
          throwsA(isA<SqliteException>()),
        );
      },
    );

    test('enforces uniqueness on operation_id idempotency key', () async {
      final now = DateTime.now().toUtc().toIso8601String();

      await db.outboxDao.enqueue(
        SyncOutboxCompanion.insert(
          operationId: 'unique-op-key',
          userId: userId,
          entityType: 'item',
          recordId: 'rec-1',
          operationType: 'insert',
          payloadJson: '{}',
          createdAt: now,
        ),
      );

      expect(
        () => db.outboxDao.enqueue(
          SyncOutboxCompanion.insert(
            operationId: 'unique-op-key', // Duplicate!
            userId: userId,
            entityType: 'item',
            recordId: 'rec-2',
            operationType: 'update',
            payloadJson: '{}',
            createdAt: now,
          ),
        ),
        throwsA(isA<SqliteException>()),
      );
    });
  });
}
