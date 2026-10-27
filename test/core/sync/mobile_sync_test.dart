import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rootin_mobile/core/database/database.dart';
import 'package:rootin_mobile/core/sync/mobile_sync.dart';

const user = '11111111-1111-4111-8111-111111111111';
const item = '22222222-2222-4222-8222-222222222222';
const op = '33333333-3333-4333-8333-333333333333';
const reminder = '44444444-4444-4444-8444-444444444444';
const now = '2026-10-27T00:00:00Z';

class FakeTransport implements SyncTransport {
  final pushes = <List<Map<String, dynamic>>>[];
  final pages = <Map<String, dynamic>>[];
  bool timeout = false;
  bool conflict = false;

  @override
  Future<Map<String, dynamic>> push(
    List<Map<String, dynamic>> mutations,
  ) async {
    pushes.add(
      (jsonDecode(jsonEncode(mutations)) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
    );
    if (timeout) throw StateError('timeout after commit');
    return {
      'mutations_result': [
        {
          'operation_id': mutations.single['operation_id'],
          'status': conflict ? 'conflict_rejected' : 'accepted',
          'server_version': 2,
        },
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> pull(Map<String, dynamic>? cursor) async =>
      pages.isEmpty
          ? {'changes': [], 'next_cursor': cursor}
          : pages.removeAt(0);
}

Future<void> queue(AppDatabase db) async {
  await db.outboxDao.enqueue(
    SyncOutboxCompanion.insert(
      operationId: op,
      userId: user,
      entityType: 'item',
      recordId: item,
      operationType: 'insert',
      createdAt: now,
      payloadJson: jsonEncode({
        'operation_id': op,
        'entity_type': 'item',
        'record_id': item,
        'operation_type': 'insert',
        'version': 1,
        'payload': {'name': 'Bike', 'category': 'vehicle'},
      }),
    ),
  );
}

Map<String, dynamic> record({String name = 'Bike', int version = 1}) => {
  'id': item,
  'user_id': user,
  'name': name,
  'category': 'vehicle',
  'has_odometer': false,
  'current_odometer': 0,
  'is_archived': false,
  'created_at': now,
  'updated_at': now,
  'deleted_at': null,
  'version': version,
};

void main() {
  late AppDatabase db;
  late FakeTransport transport;
  setUp(() {
    db = AppDatabase.inMemory();
    transport = FakeTransport();
  });
  tearDown(() => db.close());

  test(
    'timeout then restart retries identical operation and preserves queue',
    () async {
      await queue(db);
      transport.timeout = true;
      await expectLater(
        MobileSync(db, transport, () => user).run(),
        throwsStateError,
      );
      expect(
        (await db.outboxDao.getAllMutations(user)).single.status,
        'pending',
      );
      transport.timeout = false;
      await MobileSync(db, transport, () => user).run();
      expect(transport.pushes[0], transport.pushes[1]);
      expect(await db.outboxDao.getAllMutations(user), isEmpty);
    },
  );

  test(
    'processing crash retries same operation, never another account',
    () async {
      await queue(db);
      final row = (await db.outboxDao.getAllMutations(user)).single;
      await db.outboxDao.markProcessing(row.id);
      await MobileSync(db, transport, () => 'other').run();
      expect(transport.pushes, isEmpty);
      await MobileSync(db, transport, () => user).run();
      expect(transport.pushes.single.single['operation_id'], op);
    },
  );

  test(
    'FIFO stops behind uncertain commit, retains dependent mutation',
    () async {
      await queue(db);
      await db.outboxDao.enqueue(
        SyncOutboxCompanion.insert(
          operationId: '55555555-5555-4555-8555-555555555555',
          userId: user,
          entityType: 'reminder',
          recordId: reminder,
          operationType: 'insert',
          createdAt: now,
          payloadJson: jsonEncode({
            'operation_id': '55555555-5555-4555-8555-555555555555',
            'entity_type': 'reminder',
            'record_id': reminder,
            'operation_type': 'insert',
            'version': 1,
            'payload': {
              'item_id': item,
              'name': 'Oil',
              'engine_type': 'usage',
              'usage_threshold': 5,
            },
          }),
        ),
      );
      transport.timeout = true;
      await expectLater(
        MobileSync(db, transport, () => user).run(),
        throwsStateError,
      );
      expect(transport.pushes.length, 1);
      expect(await db.outboxDao.getAllMutations(user), hasLength(2));
      transport.timeout = false;
      await MobileSync(db, transport, () => user).run();
      expect(transport.pushes.map((batch) => batch.single['entity_type']), [
        'item',
        'item',
        'reminder',
      ]);
    },
  );

  test('conflict blocks queued writes until explicit server choice', () async {
    await queue(db);
    transport.conflict = true;
    await MobileSync(db, transport, () => user).run();
    final row = (await db.outboxDao.getAllMutations(user)).single;
    expect(row.status, 'conflict');
    transport.conflict = false;
    await MobileSync(db, transport, () => user).run();
    expect(transport.pushes.length, 1);
    await MobileSync(db, transport, () => user).acceptServer(user, row.id);
    expect(await db.outboxDao.getAllMutations(user), isEmpty);
  });

  test(
    'pull checkpoint rolls back on invalid owner, then applies tombstone',
    () async {
      final cursor = {'changed_at': now, 'rank': 1, 'id': item};
      transport.pages.add({
        'changes': [
          {'entity_type': 'item', 'record': record()},
          {
            'entity_type': 'item',
            'record': {...record(), 'user_id': 'other'},
          },
        ],
        'next_cursor': cursor,
      });
      await expectLater(
        MobileSync(db, transport, () => user).run(),
        throwsFormatException,
      );
      expect(await db.itemsDao.getItemById(user, item), isNull);
      expect(await db.getSyncMetadata(user, 'pull_cursor'), isNull);
      transport.pages.add({
        'changes': [
          {'entity_type': 'item', 'record': record()},
        ],
        'next_cursor': cursor,
      });
      await MobileSync(db, transport, () => user).run();
      expect((await db.itemsDao.getItemById(user, item))!.name, 'Bike');
      transport.pages.add({
        'changes': [
          {
            'entity_type': 'item',
            'record': {...record(name: 'Gone', version: 2), 'deleted_at': now},
          },
        ],
        'next_cursor': cursor,
      });
      await MobileSync(db, transport, () => user).run();
      expect(await db.itemsDao.getItemById(user, item), isNull);
    },
  );

  test('pull resolves parent before child across pages', () async {
    transport.pages.add({
      'changes': [
        {
          'entity_type': 'reminder',
          'record': {
            'id': reminder,
            'user_id': user,
            'item_id': item,
            'name': 'Oil',
            'engine_type': 'usage',
            'usage_counter': 0,
            'usage_threshold': 5,
            'baseline_mode': 'actual_completion',
            'is_active': true,
            'created_at': now,
            'updated_at': now,
            'version': 1,
          },
        },
      ],
      'next_cursor': {'changed_at': now, 'rank': 2, 'id': reminder},
    });
    transport.pages.add({
      'changes': [
        {'entity_type': 'item', 'record': record()},
      ],
      'next_cursor': {'changed_at': now, 'rank': 1, 'id': item},
    });
    await MobileSync(db, transport, () => user).run();
    expect(await db.remindersDao.getReminderById(user, reminder), isNotNull);
  });
}
