import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rootin_mobile/core/database/database.dart';
import 'package:rootin_mobile/core/database/database_providers.dart';
import 'package:rootin_mobile/core/time/calendar_clock.dart';
import 'package:rootin_mobile/features/auth/presentation/controllers/auth_controller.dart';

final deviceTimezoneProvider = StateNotifierProvider<DeviceTimezone, String?>((
  ref,
) {
  final notifier = DeviceTimezone()..refresh();
  return notifier;
});

/// Emits a change only when the native device IANA identifier changes.
class DeviceTimezone extends StateNotifier<String?>
    with WidgetsBindingObserver {
  DeviceTimezone() : super(null) {
    WidgetsBinding.instance.addObserver(this);
  }

  static const _channel = MethodChannel('rootin/timezone');

  Future<void> refresh() async {
    try {
      final zone = await _channel.invokeMethod<String>('getDeviceTimezone');
      if (zone != null) {
        locationFor(zone);
        if (mounted && state != zone) state = zone;
      }
    } on PlatformException catch (_) {
      // No native channel in widget tests or unsupported runtime.
    } on ArgumentError catch (_) {
      // Unknown device zone: do not quietly use a different zone.
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

final userPreferencesProvider = StreamProvider<UserPreference?>((ref) {
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) return Stream.value(null);
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.userPreferences)
    ..where((table) => table.userId.equals(userId))).watchSingleOrNull();
});

final effectiveTimezoneProvider = Provider<String?>(
  (ref) =>
      ref.watch(userPreferencesProvider).valueOrNull?.timezoneOverride ??
      ref.watch(deviceTimezoneProvider),
);

Future<void> saveUserPreferences(
  AppDatabase db,
  String userId, {
  String? locale,
  required String distanceUnit,
  String? timezoneOverride,
  required String reminderTime,
  String? deviceTimezone,
}) async {
  if (locale != null && locale != 'id' && locale != 'en') {
    throw ArgumentError.value(locale, 'locale');
  }
  if (distanceUnit != 'km' && distanceUnit != 'mi') {
    throw ArgumentError.value(distanceUnit, 'distanceUnit');
  }
  if (timezoneOverride != null) locationFor(timezoneOverride);
  if (!RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(reminderTime)) {
    throw ArgumentError.value(reminderTime, 'reminderTime');
  }
  final zone = timezoneOverride ?? deviceTimezone;
  if (zone == null) throw StateError('Device timezone required for sync');
  locationFor(zone);
  await db.transaction(() async {
    final existing =
        await (db.select(db.userPreferences)
          ..where((t) => t.userId.equals(userId))).getSingleOrNull();
    final pending =
        (await db.outboxDao.getAllMutations(
          userId,
        )).where((row) => row.entityType == 'preference').toList();
    if (pending.isNotEmpty) {
      throw StateError('Resolve pending preference sync before saving again');
    }
    final bytes = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    final operationId =
        '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
    final version = existing?.version ?? 0;
    await db
        .into(db.userPreferences)
        .insertOnConflictUpdate(
          UserPreferencesCompanion.insert(
            userId: userId,
            locale: Value(locale),
            distanceUnit: Value(distanceUnit),
            timezoneOverride: Value(timezoneOverride),
            reminderTime: Value(reminderTime),
            version: Value(version),
          ),
        );
    await db.outboxDao.enqueue(
      SyncOutboxCompanion.insert(
        operationId: operationId,
        userId: userId,
        entityType: 'preference',
        recordId: userId,
        operationType: version == 0 ? 'insert' : 'update',
        createdAt: DateTime.now().toUtc().toIso8601String(),
        payloadJson: jsonEncode({
          'operation_id': operationId,
          'entity_type': 'preference',
          'record_id': userId,
          'operation_type': version == 0 ? 'insert' : 'update',
          'version': version == 0 ? 1 : version,
          'payload': {
            'locale': locale ?? 'id',
            'distance_unit': distanceUnit,
            'time_zone': zone,
          },
        }),
      ),
    );
  });
}
