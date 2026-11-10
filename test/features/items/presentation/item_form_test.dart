import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rootin_mobile/core/database/database.dart';
import 'package:rootin_mobile/core/database/database_providers.dart';
import 'package:rootin_mobile/features/auth/domain/entities/auth_user.dart';
import 'package:rootin_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:rootin_mobile/features/items/data/items_repository.dart';
import 'package:rootin_mobile/features/items/presentation/item_form_screen.dart';
import 'package:rootin_mobile/features/reminders/data/reminders_repository.dart';
import 'package:rootin_mobile/features/settings/settings_provider.dart';
import 'package:rootin_mobile/l10n/generated/app_localizations.dart';

void main() {
  late AppDatabase db;
  late RemindersRepository remindersRepository;
  late ItemsRepository itemsRepository;
  const userId = 'user-test-item-form';

  setUp(() async {
    db = AppDatabase.inMemory();
    remindersRepository = RemindersRepository(db);
    itemsRepository = ItemsRepository(db, remindersRepository);
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestWidget({String? itemId}) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        remindersRepositoryProvider.overrideWithValue(remindersRepository),
        itemsRepositoryProvider.overrideWithValue(itemsRepository),
        currentUserProvider.overrideWith(
          (ref) => const AuthUser(id: userId, email: 'test@rootin.id'),
        ),
        effectiveTimezoneProvider.overrideWithValue('Asia/Jakarta'),
        userPreferencesProvider.overrideWith((ref) => Stream.value(null)),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('id'),
        home: ItemFormScreen(itemId: itemId),
      ),
    );
  }

  group('ItemFormScreen Widget Tests', () {
    testWidgets('renders item form inputs and validates required name', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Tambah Barang'), findsOneWidget);
      expect(find.byKey(const Key('item_name_input')), findsOneWidget);
      expect(find.byKey(const Key('item_category_input')), findsOneWidget);
      expect(find.byKey(const Key('item_brand_input')), findsOneWidget);
      expect(find.byKey(const Key('item_model_input')), findsOneWidget);
      expect(find.byKey(const Key('item_serial_input')), findsOneWidget);
      expect(find.byKey(const Key('item_purchase_date_input')), findsOneWidget);
      expect(find.byKey(const Key('item_has_odometer_switch')), findsOneWidget);
      expect(find.byKey(const Key('save_item_button')), findsOneWidget);

      // Attempt submit without name
      final saveBtn = find.byKey(const Key('save_item_button'));
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(find.text('Nama barang wajib diisi'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('creates a vehicle item and saves successfully', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('item_name_input')),
        'Toyota Innova Reborn',
      );
      await tester.enterText(
        find.byKey(const Key('item_brand_input')),
        'Toyota',
      );
      await tester.enterText(
        find.byKey(const Key('item_serial_input')),
        'B 8888 INN',
      );

      final odoInput = find.byKey(const Key('item_odometer_input'));
      await tester.ensureVisible(odoInput);
      await tester.enterText(odoInput, '32000');

      final saveBtn = find.byKey(const Key('save_item_button'));
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(find.text('Barang berhasil disimpan'), findsOneWidget);

      final items = await db.itemsDao.getItems(userId);
      expect(items.length, 1);
      expect(items.first.name, 'Toyota Innova Reborn');
      expect(items.first.currentOdometer, 32000);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('edit mode loads existing item and pre-fills fields', (
      tester,
    ) async {
      final itemId = await itemsRepository.saveItem(
        userId: userId,
        data: const ItemFormData(
          name: 'Kulkas LG Dua Pintu',
          category: 'appliance',
          brand: 'LG',
          modelNumber: 'GN-B215SQMT',
          hasOdometer: false,
        ),
      );

      await tester.pumpWidget(buildTestWidget(itemId: itemId));
      await tester.pumpAndSettle();

      expect(find.text('Edit Barang'), findsOneWidget);
      expect(find.text('Kulkas LG Dua Pintu'), findsOneWidget);
      expect(find.text('LG'), findsOneWidget);
      expect(find.text('GN-B215SQMT'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
    });
  });
}
