import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rootin_mobile/core/database/database.dart';
import 'package:rootin_mobile/core/database/database_providers.dart';
import 'package:rootin_mobile/features/auth/domain/entities/auth_user.dart';
import 'package:rootin_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:rootin_mobile/features/items/data/items_repository.dart';
import 'package:rootin_mobile/features/items/presentation/item_detail_screen.dart';
import 'package:rootin_mobile/features/reminders/data/reminders_repository.dart';
import 'package:rootin_mobile/features/settings/settings_provider.dart';
import 'package:rootin_mobile/l10n/generated/app_localizations.dart';

void main() {
  late AppDatabase db;
  late RemindersRepository remindersRepository;
  late ItemsRepository itemsRepository;
  const userId = 'user-test-item-detail';

  setUp(() async {
    db = AppDatabase.inMemory();
    remindersRepository = RemindersRepository(db);
    itemsRepository = ItemsRepository(db, remindersRepository);
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestWidget({required String itemId}) {
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
        home: ItemDetailScreen(itemId: itemId),
      ),
    );
  }

  group('ItemDetailScreen Widget Tests', () {
    testWidgets('renders vehicle item detail and empty reminders state', (
      tester,
    ) async {
      final itemId = await itemsRepository.saveItem(
        userId: userId,
        data: const ItemFormData(
          name: 'Mazda CX-5',
          category: 'vehicle',
          brand: 'Mazda',
          modelNumber: 'CX-5 Kuro',
          serialOrPlateNumber: 'B 9999 MZD',
          purchaseDate: '2025-05-20',
          hasOdometer: true,
          currentOdometer: 18000,
          notes: 'Mobil keluarga',
        ),
      );

      await tester.pumpWidget(buildTestWidget(itemId: itemId));
      await tester.pumpAndSettle();

      expect(find.text('Mazda CX-5'), findsWidgets);
      expect(find.text('Kendaraan'), findsWidgets);
      expect(find.text('18000 km'), findsWidgets);
      expect(find.text('Mazda'), findsOneWidget);
      expect(find.text('CX-5 Kuro'), findsOneWidget);
      expect(find.text('B 9999 MZD'), findsOneWidget);
      expect(find.text('2025-05-20'), findsOneWidget);
      expect(find.text('Mobil keluarga'), findsOneWidget);
      expect(find.byKey(const Key('no_reminders_text')), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('renders associated reminders linked to the item', (
      tester,
    ) async {
      final itemId = await itemsRepository.saveItem(
        userId: userId,
        data: const ItemFormData(
          name: 'Yamaha NMAX',
          category: 'vehicle',
          hasOdometer: true,
          currentOdometer: 12000,
        ),
      );

      await remindersRepository.saveReminder(
        userId: userId,
        data: ReminderFormData(
          itemId: itemId,
          name: 'Ganti Oli Gardan',
          engineType: 'mileage',
          intervalKm: 8000,
          lastServiceOdometer: 10000,
        ),
      );

      await tester.pumpWidget(buildTestWidget(itemId: itemId));
      await tester.pumpAndSettle();

      expect(find.text('Ganti Oli Gardan'), findsOneWidget);
      expect(find.text('Pengingat Terkait (1)'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('updates odometer when new value is greater', (tester) async {
      final itemId = await itemsRepository.saveItem(
        userId: userId,
        data: const ItemFormData(
          name: 'Daihatsu Xenia',
          category: 'vehicle',
          hasOdometer: true,
          currentOdometer: 60000,
        ),
      );

      await tester.pumpWidget(buildTestWidget(itemId: itemId));
      await tester.pumpAndSettle();

      final updateBtn = find.byKey(const Key('update_item_odometer_button'));
      await tester.ensureVisible(updateBtn);
      await tester.tap(updateBtn);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      final odoInput = find.byKey(const Key('new_odometer_input'));
      await tester.enterText(odoInput, '62500');

      final confirmBtn = find.byKey(
        const Key('confirm_update_odometer_button'),
      );
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      expect(find.text('Odometer berhasil diperbarui'), findsOneWidget);
      expect(find.text('62500 km'), findsWidgets);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets(
      'requires confirmation dialog when decreasing odometer (correction)',
      (tester) async {
        final itemId = await itemsRepository.saveItem(
          userId: userId,
          data: const ItemFormData(
            name: 'Mitsubishi Pajero',
            category: 'vehicle',
            hasOdometer: true,
            currentOdometer: 75000,
          ),
        );

        await tester.pumpWidget(buildTestWidget(itemId: itemId));
        await tester.pumpAndSettle();

        final updateBtn = find.byKey(const Key('update_item_odometer_button'));
        await tester.ensureVisible(updateBtn);
        await tester.tap(updateBtn);
        await tester.pumpAndSettle();

        // Enter lower odometer
        final odoInput = find.byKey(const Key('new_odometer_input'));
        await tester.enterText(odoInput, '72000');

        final confirmBtn = find.byKey(
          const Key('confirm_update_odometer_button'),
        );
        await tester.tap(confirmBtn);
        await tester.pumpAndSettle();

        // Lower confirmation dialog should appear
        expect(find.text('Konfirmasi Koreksi Odometer'), findsOneWidget);
        final confirmCorrectionBtn = find.byKey(
          const Key('confirm_odometer_correction_button'),
        );
        expect(confirmCorrectionBtn, findsOneWidget);

        await tester.tap(confirmCorrectionBtn);
        await tester.pumpAndSettle();

        expect(find.text('Odometer berhasil diperbarui'), findsOneWidget);
        expect(find.text('72000 km'), findsWidgets);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 5));
      },
    );
  });
}
