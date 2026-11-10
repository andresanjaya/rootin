import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rootin_mobile/core/database/database.dart';
import 'package:rootin_mobile/core/database/database_providers.dart';
import 'package:rootin_mobile/features/auth/domain/entities/auth_user.dart';
import 'package:rootin_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:rootin_mobile/features/reminders/data/reminders_repository.dart';
import 'package:rootin_mobile/features/reminders/presentation/reminder_form_screen.dart';
import 'package:rootin_mobile/l10n/generated/app_localizations.dart';

void main() {
  late AppDatabase db;
  late RemindersRepository repository;
  const userId = 'user-test-1';

  setUp(() async {
    db = AppDatabase.inMemory();
    repository = RemindersRepository(db);

    // Seed test items
    await db
        .into(db.items)
        .insert(
          ItemsCompanion.insert(
            id: 'item-1',
            userId: userId,
            name: 'Honda CR-V',
            category: 'vehicle',
            hasOdometer: const drift.Value(true),
            currentOdometer: const drift.Value(50000),
            createdAt: DateTime.now().toUtc().toIso8601String(),
            updatedAt: DateTime.now().toUtc().toIso8601String(),
          ),
        );

    await db
        .into(db.items)
        .insert(
          ItemsCompanion.insert(
            id: 'item-2',
            userId: userId,
            name: 'Mesin Cuci',
            category: 'appliance',
            hasOdometer: const drift.Value(false),
            createdAt: DateTime.now().toUtc().toIso8601String(),
            updatedAt: DateTime.now().toUtc().toIso8601String(),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestWidget({String? reminderId, String? initialItemId}) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        remindersRepositoryProvider.overrideWithValue(repository),
        currentUserProvider.overrideWith(
          (ref) => const AuthUser(id: userId, email: 'test@rootin.id'),
        ),
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
        home: ReminderFormScreen(
          reminderId: reminderId,
          initialItemId: initialItemId,
        ),
      ),
    );
  }

  group('ReminderFormScreen Widget Tests', () {
    testWidgets('renders form elements and validates required name', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Tambah Pengingat'), findsOneWidget);
      expect(find.byKey(const Key('reminder_name_input')), findsOneWidget);
      expect(find.text('Waktu'), findsOneWidget);
      expect(find.text('Pemakaian'), findsOneWidget);
      expect(find.text('Jarak tempuh'), findsOneWidget);

      // Attempt to submit empty form
      final saveBtn = find.byKey(const Key('save_reminder_button'));
      expect(saveBtn, findsOneWidget);
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      // Form validation error should appear
      expect(find.text('Nama pengingat wajib diisi'), findsOneWidget);
    });

    testWidgets('creates a time-based reminder successfully', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Enter name
      await tester.enterText(
        find.byKey(const Key('reminder_name_input')),
        'Servis 10.000 KM',
      );
      await tester.pumpAndSettle();

      // Verify schedule preview exists for default time engine
      expect(find.text('Pratinjau Jadwal Berikutnya'), findsOneWidget);

      // Save form
      final saveBtn = find.byKey(const Key('save_reminder_button'));
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      // Verify created in DB
      final reminders = await db.remindersDao.getReminders(userId);
      expect(reminders.length, 1);
      expect(reminders.first.name, 'Servis 10.000 KM');
      expect(reminders.first.engineType, 'time');
      expect(reminders.first.itemId, isNotEmpty);
    });

    testWidgets('switches to usage engine and saves usage reminder', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Select usage engine
      await tester.tap(find.text('Pemakaian'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('reminder_usage_threshold')), findsOneWidget);
      expect(find.byKey(const Key('reminder_usage_counter')), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('reminder_name_input')),
        'Ganti Filter Air',
      );
      await tester.enterText(
        find.byKey(const Key('reminder_usage_threshold')),
        '50',
      );
      await tester.pumpAndSettle();

      expect(find.text('Pratinjau Keausan & Sisa'), findsOneWidget);

      final saveBtn = find.byKey(const Key('save_reminder_button'));
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      final reminders = await db.remindersDao.getReminders(userId);
      expect(reminders.length, 1);
      expect(reminders.first.engineType, 'usage');
      expect(reminders.first.usageThreshold, 50);
    });

    testWidgets('switches to mileage engine and verifies vehicle validation', (
      tester,
    ) async {
      // Open form with appliance item (no odometer)
      await tester.pumpWidget(buildTestWidget(initialItemId: 'item-2'));
      await tester.pumpAndSettle();

      // Select mileage engine
      await tester.tap(find.text('Jarak tempuh'));
      await tester.pumpAndSettle();

      // Warning message should be visible for non-vehicle item
      expect(
        find.text(
          'Hanya barang dengan odometer (kendaraan) yang dapat menggunakan pengingat jarak',
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      'edit mode loads existing reminder and disallows changing engine type',
      (tester) async {
        // Seed existing reminder
        await repository.saveReminder(
          userId: userId,
          data: const ReminderFormData(
            itemId: 'item-1',
            name: 'Rotasi Ban',
            engineType: 'mileage',
            intervalKm: 10000,
            lastServiceOdometer: 50000,
          ),
        );

        final reminders = await db.remindersDao.getReminders(userId);
        final reminder = reminders.first;

        await tester.pumpWidget(buildTestWidget(reminderId: reminder.id));
        await tester.pumpAndSettle();

        expect(find.text('Edit Pengingat'), findsOneWidget);
        expect(find.text('Rotasi Ban'), findsOneWidget);
        expect(
          find.text('Jenis pengingat tidak dapat diubah setelah dibuat'),
          findsOneWidget,
        );
      },
    );
  });
}
