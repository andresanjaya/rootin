import 'package:flutter_test/flutter_test.dart';
import 'package:rootin_mobile/core/time/calendar_clock.dart';

void main() {
  test('calendar dates are strict and instants retain their UTC meaning', () {
    expect(formatCalendarDate(parseCalendarDate('2024-02-29')), '2024-02-29');
    expect(() => parseCalendarDate('2025-02-29'), throwsFormatException);
    expect(() => parseCalendarDate('2024-02-30'), throwsFormatException);
    expect(
      formatCalendarDate(
        DateTime.utc(2024, 3, 1).subtract(const Duration(days: 1)),
      ),
      '2024-02-29',
    );
    expect(
      formatCalendarDate(
        DateTime.utc(2025, 3, 1).subtract(const Duration(days: 1)),
      ),
      '2025-02-28',
    );
    expect(
      parseInstant('2026-01-01T00:30:00+14:00').toIso8601String(),
      '2025-12-31T10:30:00.000Z',
    );
    expect(
      parseInstant('2026-01-01T00:30:00-12:00').toIso8601String(),
      '2026-01-01T12:30:00.000Z',
    );
    expect(() => parseInstant('2026-01-01T00:30:00'), throwsFormatException);
  });

  test('spring gap skipped, fall fold takes earliest instant', () {
    expect(wallTimeToUtc('2026-03-08', '02:30', 'America/New_York'), isNull);
    expect(
      wallTimeToUtc(
        '2026-11-01',
        '01:30',
        'America/New_York',
      )?.toIso8601String(),
      '2026-11-01T05:30:00.000Z',
    );
    expect(
      wallTimeToUtc(
        '2026-01-01',
        '00:30',
        'Pacific/Kiritimati',
      )?.toIso8601String(),
      '2025-12-31T10:30:00.000Z',
    );
    expect(
      wallTimeToUtc('2026-01-01', '00:30', 'Etc/GMT+12')?.toIso8601String(),
      '2026-01-01T12:30:00.000Z',
    );
  });
}
