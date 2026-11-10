import 'package:rootin_mobile/core/time/calendar_clock.dart';

/// Pure Dart business rules for item profiles and validation.
class ItemRules {
  ItemRules._();

  static const validCategories = {
    'vehicle',
    'appliance',
    'furniture',
    'facility',
    'other',
  };

  /// Validates item form inputs according to Rootin PRD specifications.
  static Map<String, String>? validateItemForm({
    required String name,
    required String category,
    String? purchaseDate,
    bool hasOdometer = false,
    int? currentOdometer,
  }) {
    final errors = <String, String>{};

    if (name.trim().isEmpty) {
      errors['name'] = 'name_required';
    } else if (name.trim().length > 150) {
      errors['name'] = 'name_too_long';
    }

    if (!validCategories.contains(category)) {
      errors['category'] = 'category_invalid';
    }

    if (purchaseDate != null && purchaseDate.trim().isNotEmpty) {
      try {
        parseCalendarDate(purchaseDate.trim());
      } catch (_) {
        errors['purchase_date'] = 'purchase_date_invalid';
      }
    }

    if (hasOdometer && currentOdometer != null && currentOdometer < 0) {
      errors['current_odometer'] = 'odometer_negative';
    }

    return errors.isEmpty ? null : errors;
  }
}
