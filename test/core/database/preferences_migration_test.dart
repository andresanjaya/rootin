import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rootin_mobile/core/database/database.dart';
import 'package:rootin_mobile/features/settings/settings_provider.dart';

void main() {
  test(
    'v1 file upgrades without losing item, reminder, or pending outbox; survives restart',
    () async {
      final dir = await Directory.systemTemp.createTemp('rootin-v1-');
      final file = File('${dir.path}/rootin.sqlite');
      try {
        // Reconstruct actual v1 table shape from the pre-upgrade baseline using
        // Drift's schema SQL, then downgrade only the newly added table/version.
        var db = AppDatabase(NativeDatabase(file));
        await db.customSelect('SELECT 1').get();
        await db.customStatement(
          "INSERT INTO items (id,user_id,name,category,created_at,updated_at) VALUES ('item','u1','Bike','vehicle','2026-01-01T00:00:00Z','2026-01-01T00:00:00Z')",
        );
        await db.customStatement(
          "INSERT INTO reminders (id,user_id,item_id,name,engine_type,created_at,updated_at) VALUES ('rem','u1','item','Oil','mileage','2026-01-01T00:00:00Z','2026-01-01T00:00:00Z')",
        );
        await db.customStatement(
          "INSERT INTO sync_outbox (operation_id,user_id,entity_type,record_id,operation_type,payload_json,created_at) VALUES ('op','u1','reminder','rem','update','{}','2026-01-01T00:00:00Z')",
        );
        await db.customStatement('DROP TABLE user_preferences');
        await db.customStatement('PRAGMA user_version = 1');
        await db.close();

        db = AppDatabase(NativeDatabase(file));
        expect(
          (await db.customSelect('PRAGMA user_version').getSingle()).read<int>(
            'user_version',
          ),
          2,
        );
        expect(
          (await db.customSelect('SELECT id FROM items').getSingle())
              .read<String>('id'),
          'item',
        );
        expect(
          (await db.customSelect('SELECT id FROM reminders').getSingle())
              .read<String>('id'),
          'rem',
        );
        expect(
          (await db
                  .customSelect('SELECT operation_id, status FROM sync_outbox')
                  .getSingle())
              .read<String>('status'),
          'pending',
        );
        await saveUserPreferences(
          db,
          'u1',
          locale: 'en',
          distanceUnit: 'mi',
          timezoneOverride: 'America/New_York',
          reminderTime: '07:45',
        );
        await saveUserPreferences(
          db,
          'u2',
          distanceUnit: 'km',
          reminderTime: '09:00',
        );
        await db.close();

        db = AppDatabase(NativeDatabase(file));
        expect(
          (await db
                  .customSelect(
                    "SELECT locale,distance_unit,timezone_override,reminder_time FROM user_preferences WHERE user_id='u1'",
                  )
                  .getSingle())
              .read<String>('locale'),
          'en',
        );
        expect(
          (await db
                  .customSelect(
                    "SELECT distance_unit FROM user_preferences WHERE user_id='u2'",
                  )
                  .getSingle())
              .read<String>('distance_unit'),
          'km',
        );
        expect(
          (await db
                  .customSelect('SELECT operation_id FROM sync_outbox')
                  .getSingle())
              .read<String>('operation_id'),
          'op',
        );
        await db.close();
      } finally {
        await dir.delete(recursive: true);
      }
    },
  );
}
