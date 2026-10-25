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
  ref.onDispose(notifier.dispose);
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
  await db
      .into(db.userPreferences)
      .insertOnConflictUpdate(
        UserPreferencesCompanion.insert(
          userId: userId,
          locale: Value(locale),
          distanceUnit: Value(distanceUnit),
          timezoneOverride: Value(timezoneOverride),
          reminderTime: Value(reminderTime),
        ),
      );
}
