import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// A calendar date has no time zone or offset; wire format YYYY-MM-DD.
DateTime parseCalendarDate(String value) {
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
    throw FormatException('Expected YYYY-MM-DD', value);
  }
  final date = DateTime.utc(
    int.parse(value.substring(0, 4)),
    int.parse(value.substring(5, 7)),
    int.parse(value.substring(8, 10)),
  );
  if (formatCalendarDate(date) != value) {
    throw FormatException('Invalid date', value);
  }
  return date;
}

String formatCalendarDate(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

/// Store an instant in UTC with an explicit Z suffix, never as a local date.
String formatInstant(DateTime value) => value.toUtc().toIso8601String();

DateTime parseInstant(String value) {
  if (!RegExp(r'(Z|[+-]\d{2}:\d{2})$').hasMatch(value)) {
    throw FormatException('Instant requires an offset', value);
  }
  return DateTime.parse(value).toUtc();
}

// ponytail: TZ database initializes once in process; upgrade tz data with the
// pinned timezone package when jurisdictional rules change.
bool _initialized = false;
tz.Location locationFor(String name) {
  if (!_initialized) {
    tzdata.initializeTimeZones();
    _initialized = true;
  }
  return tz.getLocation(name);
}

/// Resolve wall time: skip nonexistent spring-forward times; choose earliest
/// instant in a fall-back fold. Caller can reschedule on zone/preference changes.
DateTime? wallTimeToUtc(String day, String hourMinute, String zone) {
  parseCalendarDate(day);
  if (!RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(hourMinute)) {
    throw FormatException('Expected HH:mm', hourMinute);
  }
  final location = locationFor(zone);
  final hour = int.parse(hourMinute.substring(0, 2));
  final minute = int.parse(hourMinute.substring(3));
  final year = int.parse(day.substring(0, 4));
  final month = int.parse(day.substring(5, 7));
  final date = int.parse(day.substring(8, 10));
  final candidate = tz.TZDateTime(location, year, month, date, hour, minute);
  if (candidate.year != year ||
      candidate.month != month ||
      candidate.day != date ||
      candidate.hour != hour ||
      candidate.minute != minute) {
    return null;
  }
  // Probe an hour earlier for a second valid mapping of an ambiguous wall time.
  final earlier = tz.TZDateTime.from(
    candidate.subtract(const Duration(hours: 1)),
    location,
  );
  if (earlier.year == year &&
      earlier.month == month &&
      earlier.day == date &&
      earlier.hour == hour &&
      earlier.minute == minute) {
    return earlier.toUtc();
  }
  return candidate.toUtc();
}
