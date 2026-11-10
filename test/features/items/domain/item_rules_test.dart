import 'package:flutter_test/flutter_test.dart';
import 'package:rootin_mobile/features/items/domain/item_rules.dart';

void main() {
  group('ItemRules validateItemForm', () {
    test('validates required name and max length', () {
      final errEmpty = ItemRules.validateItemForm(
        name: '',
        category: 'vehicle',
      );
      expect(errEmpty?['name'], 'name_required');

      final errWhitespace = ItemRules.validateItemForm(
        name: '   ',
        category: 'vehicle',
      );
      expect(errWhitespace?['name'], 'name_required');

      final errTooLong = ItemRules.validateItemForm(
        name: 'A' * 151,
        category: 'vehicle',
      );
      expect(errTooLong?['name'], 'name_too_long');
    });

    test('validates allowed categories', () {
      final errInvalid = ItemRules.validateItemForm(
        name: 'Barang Uji',
        category: 'spaceship',
      );
      expect(errInvalid?['category'], 'category_invalid');

      for (final cat in [
        'vehicle',
        'appliance',
        'furniture',
        'facility',
        'other',
      ]) {
        final err = ItemRules.validateItemForm(
          name: 'Barang Uji',
          category: cat,
        );
        expect(err, isNull);
      }
    });

    test('validates purchase date format', () {
      final errInvalid = ItemRules.validateItemForm(
        name: 'Toyota Vios',
        category: 'vehicle',
        purchaseDate: '2026/01/01',
      );
      expect(errInvalid?['purchase_date'], 'purchase_date_invalid');

      final errValid = ItemRules.validateItemForm(
        name: 'Toyota Vios',
        category: 'vehicle',
        purchaseDate: '2026-01-15',
      );
      expect(errValid, isNull);
    });

    test('validates non-negative odometer', () {
      final errNegative = ItemRules.validateItemForm(
        name: 'Honda Beat',
        category: 'vehicle',
        hasOdometer: true,
        currentOdometer: -50,
      );
      expect(errNegative?['current_odometer'], 'odometer_negative');

      final errValid = ItemRules.validateItemForm(
        name: 'Honda Beat',
        category: 'vehicle',
        hasOdometer: true,
        currentOdometer: 12500,
      );
      expect(errValid, isNull);
    });
  });
}
