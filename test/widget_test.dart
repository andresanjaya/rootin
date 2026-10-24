import 'package:flutter_test/flutter_test.dart';
import 'package:rootin_mobile/core/constants/app_constants.dart';

void main() {
  group('App Constants', () {
    test('app version is defined', () {
      expect(AppConstants.appVersion, isNotEmpty);
    });

    test('database name is defined', () {
      expect(AppConstants.databaseName, isNotEmpty);
    });
  });
}
