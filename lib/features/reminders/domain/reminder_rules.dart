import 'dart:math';
import 'package:rootin_mobile/core/database/database.dart';
import 'package:rootin_mobile/core/time/calendar_clock.dart';

/// Supported interval units for time-based reminders.
enum ReminderIntervalUnit {
  days('days'),
  weeks('weeks'),
  months('months'),
  years('years');

  const ReminderIntervalUnit(this.wireValue);
  final String wireValue;

  static ReminderIntervalUnit fromString(String value) {
    return ReminderIntervalUnit.values.firstWhere(
      (u) => u.wireValue == value,
      orElse: () => throw ArgumentError('Unknown interval unit: $value'),
    );
  }
}

/// Baseline calculation modes for time-based reminders.
enum ReminderBaselineMode {
  actualCompletion('actual_completion'),
  strictSchedule('strict_schedule');

  const ReminderBaselineMode(this.wireValue);
  final String wireValue;

  static ReminderBaselineMode fromString(String value) {
    return ReminderBaselineMode.values.firstWhere(
      (m) => m.wireValue == value,
      orElse: () => throw ArgumentError('Unknown baseline mode: $value'),
    );
  }
}

/// Engine types for reminders.
enum ReminderEngineType {
  time('time'),
  usage('usage'),
  mileage('mileage');

  const ReminderEngineType(this.wireValue);
  final String wireValue;

  static ReminderEngineType fromString(String value) {
    return ReminderEngineType.values.firstWhere(
      (e) => e.wireValue == value,
      orElse: () => throw ArgumentError('Unknown engine type: $value'),
    );
  }
}

/// Result of completing a reminder cycle according to domain rules.
class CycleCompletionResult {
  const CycleCompletionResult({
    this.nextTargetDate,
    this.newLastServiceOdometer,
    this.newUsageCounter,
    required this.newVersion,
  });

  final String? nextTargetDate;
  final int? newLastServiceOdometer;
  final int? newUsageCounter;
  final int newVersion;
}

/// Pure Dart business rules for calculation and validation of Rootin reminders.
class ReminderRules {
  ReminderRules._();

  /// Calculates the new reminder state after completing a service cycle.
  ///
  /// - Time: Starts from actual completion date (or target date if strict schedule).
  /// - Mileage: Updates baseline [lastServiceOdometer] with [odometerAtCompletion].
  /// - Usage: Resets [usageCounter] to 0 for current completions.
  /// - Backdated completion: If completed before a prior completion, future scheduled
  ///   targetDate and progress are preserved to avoid regressing upcoming cycles.
  static CycleCompletionResult calculateCycleCompletion({
    required Reminder reminder,
    required String completionDate,
    int? odometerAtCompletion,
    String? previousCompletionDate,
  }) {
    parseCalendarDate(completionDate); // Validate calendar date format
    final nextVersion = reminder.version + 1;
    final isBackdated =
        previousCompletionDate != null &&
        completionDate.compareTo(previousCompletionDate) < 0;

    String? nextTargetDate;
    if (reminder.engineType == 'time') {
      if (!isBackdated) {
        final baseDateStr =
            reminder.baselineMode == 'strict_schedule' &&
                    reminder.targetDate != null
                ? reminder.targetDate!
                : completionDate;
        final baseDate = parseCalendarDate(baseDateStr);
        final nextDate = calculateNextDueDate(
          baseDate: baseDate,
          intervalValue: reminder.intervalValue ?? 1,
          intervalUnit: reminder.intervalUnit ?? 'months',
          anchorDay: reminder.anchorDay ?? baseDate.day,
        );
        nextTargetDate = formatCalendarDate(nextDate);
      } else {
        // Preserves future target date when recording past completion
        nextTargetDate = reminder.targetDate;
      }
    }

    int? newLastServiceOdometer;
    if (reminder.engineType == 'mileage') {
      final odo = odometerAtCompletion ?? reminder.lastServiceOdometer;
      if (odo != null && odo < 0) {
        throw ArgumentError('odometerAtCompletion cannot be negative: $odo');
      }
      newLastServiceOdometer = max(reminder.lastServiceOdometer ?? 0, odo ?? 0);
    }

    int? newUsageCounter;
    if (reminder.engineType == 'usage') {
      newUsageCounter = isBackdated ? reminder.usageCounter : 0;
    }

    return CycleCompletionResult(
      nextTargetDate: nextTargetDate,
      newLastServiceOdometer: newLastServiceOdometer,
      newUsageCounter: newUsageCounter,
      newVersion: nextVersion,
    );
  }

  /// Check whether [year] is a leap year according to the Gregorian calendar rules.
  static bool isLeapYear(int year) {
    return (year % 4 == 0) && (year % 100 != 0 || year % 400 == 0);
  }

  /// Get the number of days in [month] of [year].
  static int daysInMonth(int year, int month) {
    switch (month) {
      case 1:
      case 3:
      case 5:
      case 7:
      case 8:
      case 10:
      case 12:
        return 31;
      case 4:
      case 6:
      case 9:
      case 11:
        return 30;
      case 2:
        return isLeapYear(year) ? 29 : 28;
      default:
        throw ArgumentError('Invalid month: $month');
    }
  }

  /// Add [monthsToAdd] to [baseDate] using month-end clamping with [anchorDay].
  ///
  /// For example, if anchorDay is 31 and we start on Jan 31:
  /// - +1 month (Feb): 28 Feb (or 29 Feb in leap year)
  /// - +2 months (Mar): 31 Mar (the original 31st anchor is restored)
  /// - +3 months (Apr): 30 Apr
  /// - +4 months (May): 31 May
  static DateTime addMonthsWithAnchor({
    required DateTime baseDate,
    required int monthsToAdd,
    required int anchorDay,
  }) {
    if (monthsToAdd <= 0) {
      throw ArgumentError('monthsToAdd must be greater than zero');
    }
    if (anchorDay < 1 || anchorDay > 31) {
      throw ArgumentError('anchorDay must be between 1 and 31');
    }

    final totalMonths = baseDate.month + monthsToAdd;
    final targetYear = baseDate.year + (totalMonths - 1) ~/ 12;
    final targetMonth = ((totalMonths - 1) % 12) + 1;
    final maxDays = daysInMonth(targetYear, targetMonth);
    final targetDay = min(anchorDay, maxDays);

    return DateTime.utc(targetYear, targetMonth, targetDay);
  }

  /// Add [yearsToAdd] to [baseDate] respecting leap year rules with [anchorDay].
  ///
  /// If anchorDay is 29 (Feb 29):
  /// - Non-leap year: Feb 28
  /// - Leap year: Feb 29
  static DateTime addYearsWithAnchor({
    required DateTime baseDate,
    required int yearsToAdd,
    required int anchorDay,
  }) {
    if (yearsToAdd <= 0) {
      throw ArgumentError('yearsToAdd must be greater than zero');
    }
    final targetYear = baseDate.year + yearsToAdd;
    final maxDays = daysInMonth(targetYear, baseDate.month);
    final targetDay = min(anchorDay, maxDays);

    return DateTime.utc(targetYear, baseDate.month, targetDay);
  }

  /// Calculates the next due calendar date based on [baseDate], interval parameters,
  /// and [anchorDay].
  static DateTime calculateNextDueDate({
    required DateTime baseDate,
    required int intervalValue,
    required String intervalUnit,
    int? anchorDay,
  }) {
    if (intervalValue <= 0) {
      throw ArgumentError(
        'intervalValue must be greater than zero: $intervalValue',
      );
    }
    final unit = ReminderIntervalUnit.fromString(intervalUnit);
    final effectiveAnchor = anchorDay ?? baseDate.day;

    switch (unit) {
      case ReminderIntervalUnit.days:
        return baseDate.add(Duration(days: intervalValue));
      case ReminderIntervalUnit.weeks:
        return baseDate.add(Duration(days: intervalValue * 7));
      case ReminderIntervalUnit.months:
        return addMonthsWithAnchor(
          baseDate: baseDate,
          monthsToAdd: intervalValue,
          anchorDay: effectiveAnchor,
        );
      case ReminderIntervalUnit.years:
        return addYearsWithAnchor(
          baseDate: baseDate,
          yearsToAdd: intervalValue,
          anchorDay: effectiveAnchor,
        );
    }
  }

  /// Generates a preview of the next [count] scheduled due dates starting from [startDate].
  static List<DateTime> generateNextDueDatesPreview({
    required DateTime startDate,
    required int intervalValue,
    required String intervalUnit,
    int? anchorDay,
    int count = 3,
  }) {
    if (count <= 0) return [];
    final effectiveAnchor = anchorDay ?? startDate.day;
    final results = <DateTime>[];

    var current = startDate;
    for (var i = 0; i < count; i++) {
      current = calculateNextDueDate(
        baseDate: current,
        intervalValue: intervalValue,
        intervalUnit: intervalUnit,
        anchorDay: effectiveAnchor,
      );
      results.add(current);
    }
    return results;
  }

  /// Calculates usage wear percentage: (counter / threshold) * 100%.
  static double calculateUsageWearPercentage({
    required int counter,
    required int threshold,
  }) {
    if (threshold <= 0) {
      throw ArgumentError('threshold must be greater than zero: $threshold');
    }
    if (counter < 0) {
      throw ArgumentError('counter cannot be negative: $counter');
    }
    return (counter / threshold) * 100.0;
  }

  /// Calculates remaining usage until due: max(0, threshold - counter).
  static int calculateRemainingUsage({
    required int counter,
    required int threshold,
  }) {
    if (threshold <= 0) {
      throw ArgumentError('threshold must be greater than zero: $threshold');
    }
    return max(0, threshold - counter);
  }

  /// Evaluates wear progress state:
  /// - normal (< 80%)
  /// - warning (80% - 99%)
  /// - due (>= 100%)
  static String evaluateUsageProgress({
    required int counter,
    required int threshold,
  }) {
    final wear = calculateUsageWearPercentage(
      counter: counter,
      threshold: threshold,
    );
    if (wear >= 100.0) return 'due';
    if (wear >= 80.0) return 'warning';
    return 'normal';
  }

  /// Target odometer = lastServiceOdometer + intervalKm.
  static int calculateTargetOdometer({
    required int lastServiceOdometer,
    required int intervalKm,
  }) {
    if (lastServiceOdometer < 0) {
      throw ArgumentError(
        'lastServiceOdometer cannot be negative: $lastServiceOdometer',
      );
    }
    if (intervalKm <= 0) {
      throw ArgumentError('intervalKm must be greater than zero: $intervalKm');
    }
    return lastServiceOdometer + intervalKm;
  }

  /// Remaining km = targetOdometer - currentOdometer.
  static int calculateRemainingKm({
    required int targetOdometer,
    required int currentOdometer,
  }) {
    return targetOdometer - currentOdometer;
  }

  /// Evaluates mileage progress state based on remaining distance:
  /// - normal (> 500 km)
  /// - warning (0 < remaining <= 500 km)
  /// - due (remaining <= 0 km)
  static String evaluateMileageProgress({
    required int lastServiceOdometer,
    required int intervalKm,
    required int currentOdometer,
  }) {
    final target = calculateTargetOdometer(
      lastServiceOdometer: lastServiceOdometer,
      intervalKm: intervalKm,
    );
    final remaining = calculateRemainingKm(
      targetOdometer: target,
      currentOdometer: currentOdometer,
    );

    if (remaining <= 0) return 'due';
    if (remaining <= 500) return 'warning';
    return 'normal';
  }

  /// Validates a reminder form. Returns null if valid, or a map of field -> error message.
  static Map<String, String>? validateReminderForm({
    required String name,
    required String engineType,
    required String? itemId,
    // Time fields
    int? intervalValue,
    String? intervalUnit,
    String? targetDate,
    String? targetTime,
    int? anchorDay,
    // Usage fields
    int? usageThreshold,
    int? usageCounter,
    // Mileage fields
    int? intervalKm,
    int? lastServiceOdometer,
    bool itemHasOdometer = false,
  }) {
    final errors = <String, String>{};

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      errors['name'] = 'name_required';
    } else if (trimmedName.length > 150) {
      errors['name'] = 'name_too_long';
    }

    if (itemId == null || itemId.trim().isEmpty) {
      errors['item_id'] = 'item_required';
    }

    if (engineType == 'time') {
      if (intervalValue == null || intervalValue <= 0) {
        errors['interval_value'] = 'interval_value_positive';
      }
      if (intervalUnit == null ||
          !['days', 'weeks', 'months', 'years'].contains(intervalUnit)) {
        errors['interval_unit'] = 'interval_unit_invalid';
      }
      if (targetDate == null || targetDate.trim().isEmpty) {
        errors['target_date'] = 'target_date_required';
      } else {
        try {
          parseCalendarDate(targetDate);
        } on FormatException {
          errors['target_date'] = 'target_date_invalid';
        }
      }
      if (targetTime != null && targetTime.trim().isNotEmpty) {
        if (!RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(targetTime)) {
          errors['target_time'] = 'target_time_invalid';
        }
      }
      if (anchorDay != null && (anchorDay < 1 || anchorDay > 31)) {
        errors['anchor_day'] = 'anchor_day_range';
      }
    } else if (engineType == 'usage') {
      if (usageThreshold == null || usageThreshold <= 0) {
        errors['usage_threshold'] = 'usage_threshold_positive';
      }
      if (usageCounter != null && usageCounter < 0) {
        errors['usage_counter'] = 'usage_counter_non_negative';
      }
    } else if (engineType == 'mileage') {
      if (!itemHasOdometer) {
        errors['item_id'] = 'item_odometer_required';
      }
      if (intervalKm == null || intervalKm <= 0) {
        errors['interval_km'] = 'interval_km_positive';
      }
      if (lastServiceOdometer == null || lastServiceOdometer < 0) {
        errors['last_service_odometer'] = 'odometer_non_negative';
      }
    } else {
      errors['engine_type'] = 'engine_type_unsupported';
    }

    return errors.isEmpty ? null : errors;
  }
}
