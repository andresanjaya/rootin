import 'package:flutter_test/flutter_test.dart';
import 'package:rootin_mobile/features/reminders/domain/reminder_rules.dart';

void main() {
  group('ReminderRules Leap Year & Days In Month', () {
    test('isLeapYear correctly identifies leap and non-leap years', () {
      expect(ReminderRules.isLeapYear(2020), isTrue); // divisible by 4
      expect(ReminderRules.isLeapYear(2024), isTrue);
      expect(ReminderRules.isLeapYear(2028), isTrue);
      expect(ReminderRules.isLeapYear(2000), isTrue); // divisible by 400

      expect(ReminderRules.isLeapYear(2021), isFalse);
      expect(ReminderRules.isLeapYear(2022), isFalse);
      expect(ReminderRules.isLeapYear(2023), isFalse);
      expect(ReminderRules.isLeapYear(2025), isFalse);
      expect(
        ReminderRules.isLeapYear(1900),
        isFalse,
      ); // century year not div by 400
      expect(ReminderRules.isLeapYear(2100), isFalse);
    });

    test('daysInMonth returns correct days for each month', () {
      expect(ReminderRules.daysInMonth(2024, 1), 31);
      expect(ReminderRules.daysInMonth(2024, 2), 29); // leap year
      expect(ReminderRules.daysInMonth(2023, 2), 28); // non-leap year
      expect(ReminderRules.daysInMonth(2024, 3), 31);
      expect(ReminderRules.daysInMonth(2024, 4), 30);
      expect(ReminderRules.daysInMonth(2024, 5), 31);
      expect(ReminderRules.daysInMonth(2024, 6), 30);
      expect(ReminderRules.daysInMonth(2024, 7), 31);
      expect(ReminderRules.daysInMonth(2024, 8), 31);
      expect(ReminderRules.daysInMonth(2024, 9), 30);
      expect(ReminderRules.daysInMonth(2024, 10), 31);
      expect(ReminderRules.daysInMonth(2024, 11), 30);
      expect(ReminderRules.daysInMonth(2024, 12), 31);
    });
  });

  group('ReminderRules Month-End Clamping & Anchor Day', () {
    test('31-day cycle preserves 31st anchor across varying month lengths', () {
      final start = DateTime.utc(2026, 1, 31);
      const anchor = 31;

      // 1 month: Feb 2026 (non-leap, 28 days) -> Feb 28
      final feb = ReminderRules.addMonthsWithAnchor(
        baseDate: start,
        monthsToAdd: 1,
        anchorDay: anchor,
      );
      expect(feb, DateTime.utc(2026, 2, 28));

      // 2 months: Mar 2026 (31 days) -> Mar 31 (anchor restored!)
      final mar = ReminderRules.addMonthsWithAnchor(
        baseDate: start,
        monthsToAdd: 2,
        anchorDay: anchor,
      );
      expect(mar, DateTime.utc(2026, 3, 31));

      // 3 months: Apr 2026 (30 days) -> Apr 30
      final apr = ReminderRules.addMonthsWithAnchor(
        baseDate: start,
        monthsToAdd: 3,
        anchorDay: anchor,
      );
      expect(apr, DateTime.utc(2026, 4, 30));

      // 4 months: May 2026 (31 days) -> May 31
      final may = ReminderRules.addMonthsWithAnchor(
        baseDate: start,
        monthsToAdd: 4,
        anchorDay: anchor,
      );
      expect(may, DateTime.utc(2026, 5, 31));
    });

    test(
      'Feb 29 leap year anchor clamps to Feb 28 in non-leap year and restores on next leap year',
      () {
        final leapStart = DateTime.utc(2024, 2, 29);
        const anchor = 29;

        // +1 year (2025 non-leap) -> Feb 28
        final y2025 = ReminderRules.addYearsWithAnchor(
          baseDate: leapStart,
          yearsToAdd: 1,
          anchorDay: anchor,
        );
        expect(y2025, DateTime.utc(2025, 2, 28));

        // +2 years (2026 non-leap) -> Feb 28
        final y2026 = ReminderRules.addYearsWithAnchor(
          baseDate: leapStart,
          yearsToAdd: 2,
          anchorDay: anchor,
        );
        expect(y2026, DateTime.utc(2026, 2, 28));

        // +4 years (2028 leap year) -> Feb 29 (anchor 29 restored!)
        final y2028 = ReminderRules.addYearsWithAnchor(
          baseDate: leapStart,
          yearsToAdd: 4,
          anchorDay: anchor,
        );
        expect(y2028, DateTime.utc(2028, 2, 29));
      },
    );
  });

  group('ReminderRules calculateNextDueDate & Preview', () {
    test('calculates days interval', () {
      final base = DateTime.utc(2026, 10, 1);
      final next = ReminderRules.calculateNextDueDate(
        baseDate: base,
        intervalValue: 14,
        intervalUnit: 'days',
      );
      expect(next, DateTime.utc(2026, 10, 15));
    });

    test('calculates weeks interval', () {
      final base = DateTime.utc(2026, 10, 1);
      final next = ReminderRules.calculateNextDueDate(
        baseDate: base,
        intervalValue: 2,
        intervalUnit: 'weeks',
      );
      expect(next, DateTime.utc(2026, 10, 15));
    });

    test('calculates months interval with implicit anchor from base date', () {
      final base = DateTime.utc(2026, 1, 31);
      final next = ReminderRules.calculateNextDueDate(
        baseDate: base,
        intervalValue: 1,
        intervalUnit: 'months',
      );
      expect(next, DateTime.utc(2026, 2, 28));
    });

    test('generates preview list for consecutive due dates', () {
      final start = DateTime.utc(2026, 1, 31);
      final preview = ReminderRules.generateNextDueDatesPreview(
        startDate: start,
        intervalValue: 1,
        intervalUnit: 'months',
        anchorDay: 31,
        count: 4,
      );
      expect(preview.length, 4);
      expect(preview[0], DateTime.utc(2026, 2, 28));
      expect(preview[1], DateTime.utc(2026, 3, 31));
      expect(preview[2], DateTime.utc(2026, 4, 30));
      expect(preview[3], DateTime.utc(2026, 5, 31));
    });

    test('rejects non-positive interval values', () {
      final base = DateTime.utc(2026, 10, 1);
      expect(
        () => ReminderRules.calculateNextDueDate(
          baseDate: base,
          intervalValue: 0,
          intervalUnit: 'days',
        ),
        throwsArgumentError,
      );
      expect(
        () => ReminderRules.calculateNextDueDate(
          baseDate: base,
          intervalValue: -5,
          intervalUnit: 'days',
        ),
        throwsArgumentError,
      );
    });
  });

  group('ReminderRules Usage & Mileage engines', () {
    test('usage wear percentage and progress evaluation', () {
      expect(
        ReminderRules.calculateUsageWearPercentage(counter: 50, threshold: 100),
        50.0,
      );
      expect(
        ReminderRules.evaluateUsageProgress(counter: 50, threshold: 100),
        'normal',
      );
      expect(
        ReminderRules.evaluateUsageProgress(counter: 80, threshold: 100),
        'warning',
      );
      expect(
        ReminderRules.evaluateUsageProgress(counter: 100, threshold: 100),
        'due',
      );
      expect(
        ReminderRules.evaluateUsageProgress(counter: 120, threshold: 100),
        'due',
      );
      expect(
        ReminderRules.calculateRemainingUsage(counter: 40, threshold: 100),
        60,
      );
      expect(
        ReminderRules.calculateRemainingUsage(counter: 110, threshold: 100),
        0,
      );
    });

    test('mileage calculations and evaluation', () {
      final target = ReminderRules.calculateTargetOdometer(
        lastServiceOdometer: 40000,
        intervalKm: 5000,
      );
      expect(target, 45000);

      // Current 44000: remaining 1000 (> 500 -> normal)
      expect(
        ReminderRules.evaluateMileageProgress(
          lastServiceOdometer: 40000,
          intervalKm: 5000,
          currentOdometer: 44000,
        ),
        'normal',
      );

      // Current 44600: remaining 400 (<= 500 -> warning)
      expect(
        ReminderRules.evaluateMileageProgress(
          lastServiceOdometer: 40000,
          intervalKm: 5000,
          currentOdometer: 44600,
        ),
        'warning',
      );

      // Current 45000: remaining 0 (<= 0 -> due)
      expect(
        ReminderRules.evaluateMileageProgress(
          lastServiceOdometer: 40000,
          intervalKm: 5000,
          currentOdometer: 45000,
        ),
        'due',
      );

      // Current 45200: overdue
      expect(
        ReminderRules.evaluateMileageProgress(
          lastServiceOdometer: 40000,
          intervalKm: 5000,
          currentOdometer: 45200,
        ),
        'due',
      );
    });
  });

  group('ReminderRules validateReminderForm', () {
    test('validates required name and length', () {
      final errEmpty = ReminderRules.validateReminderForm(
        name: '   ',
        engineType: 'time',
        itemId: 'item-1',
        intervalValue: 1,
        intervalUnit: 'months',
        targetDate: '2026-11-01',
      );
      expect(errEmpty?['name'], 'name_required');

      final longName = 'A' * 151;
      final errLong = ReminderRules.validateReminderForm(
        name: longName,
        engineType: 'time',
        itemId: 'item-1',
        intervalValue: 1,
        intervalUnit: 'months',
        targetDate: '2026-11-01',
      );
      expect(errLong?['name'], 'name_too_long');
    });

    test('validates time engine parameters', () {
      final err = ReminderRules.validateReminderForm(
        name: 'Ganti Filter AC',
        engineType: 'time',
        itemId: 'item-1',
        intervalValue: 0,
        intervalUnit: 'invalid_unit',
        targetDate: 'not-a-date',
      );
      expect(err?['interval_value'], 'interval_value_positive');
      expect(err?['interval_unit'], 'interval_unit_invalid');
      expect(err?['target_date'], 'target_date_invalid');
    });

    test('validates usage engine parameters', () {
      final err = ReminderRules.validateReminderForm(
        name: 'Ganti Pisau Blender',
        engineType: 'usage',
        itemId: 'item-1',
        usageThreshold: 0,
        usageCounter: -1,
      );
      expect(err?['usage_threshold'], 'usage_threshold_positive');
      expect(err?['usage_counter'], 'usage_counter_non_negative');
    });

    test('validates mileage requires item with odometer', () {
      final errNoOdo = ReminderRules.validateReminderForm(
        name: 'Ganti Oli Mesin',
        engineType: 'mileage',
        itemId: 'item-1',
        itemHasOdometer: false,
        intervalKm: 5000,
        lastServiceOdometer: 10000,
      );
      expect(errNoOdo?['item_id'], 'item_odometer_required');
    });

    test('returns null when valid for time, usage, and mileage', () {
      expect(
        ReminderRules.validateReminderForm(
          name: 'Servis Rutin',
          engineType: 'time',
          itemId: 'item-1',
          intervalValue: 1,
          intervalUnit: 'months',
          targetDate: '2026-12-01',
        ),
        isNull,
      );

      expect(
        ReminderRules.validateReminderForm(
          name: 'Penggantian Filter',
          engineType: 'usage',
          itemId: 'item-1',
          usageThreshold: 100,
          usageCounter: 10,
        ),
        isNull,
      );

      expect(
        ReminderRules.validateReminderForm(
          name: 'Ganti Oli Transmisi',
          engineType: 'mileage',
          itemId: 'item-1',
          itemHasOdometer: true,
          intervalKm: 10000,
          lastServiceOdometer: 30000,
        ),
        isNull,
      );
    });
  });
}
