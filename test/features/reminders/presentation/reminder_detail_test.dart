import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rootin_mobile/core/database/database.dart';
import 'package:rootin_mobile/core/database/database_providers.dart';
import 'package:rootin_mobile/features/auth/domain/entities/auth_user.dart';
import 'package:rootin_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:rootin_mobile/features/reminders/data/reminder_feed.dart';
import 'package:rootin_mobile/features/reminders/data/reminders_repository.dart';
import 'package:rootin_mobile/features/reminders/presentation/reminder_detail_screen.dart';
import 'package:rootin_mobile/features/settings/settings_provider.dart';
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
            id: 'item-vehicle',
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
            id: 'item-appliance',
            userId: userId,
            name: 'Mesin Kopi',
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

  Widget buildTestWidget({required String reminderId}) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        remindersRepositoryProvider.overrideWithValue(repository),
        currentUserProvider.overrideWith(
          (ref) => const AuthUser(id: userId, email: 'test@rootin.id'),
        ),
        localTodayProvider.overrideWithValue(DateTime.utc(2026, 3, 20)),
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
        home: ReminderDetailScreen(reminderId: reminderId),
      ),
    );
  }

  group('ReminderDetailScreen Widget Tests', () {
    testWidgets('renders time-based reminder details and empty history state', (
      tester,
    ) async {
      await db
          .into(db.reminders)
          .insert(
            RemindersCompanion.insert(
              id: 'rem-time',
              userId: userId,
              itemId: 'item-appliance',
              name: 'Descaling Mesin Kopi',
              engineType: 'time',
              intervalValue: const drift.Value(2),
              intervalUnit: const drift.Value('months'),
              targetDate: const drift.Value('2026-04-15'),
              createdAt: DateTime.now().toUtc().toIso8601String(),
              updatedAt: DateTime.now().toUtc().toIso8601String(),
            ),
          );

      await tester.pumpWidget(buildTestWidget(reminderId: 'rem-time'));
      await tester.pumpAndSettle();

      expect(find.text('Descaling Mesin Kopi'), findsWidgets);
      expect(find.textContaining('Mesin Kopi'), findsWidgets);
      expect(find.text('2026-04-15'), findsOneWidget);
      expect(find.text('2 Bulan'), findsOneWidget);
      expect(find.byKey(const Key('complete_cycle_button')), findsOneWidget);
      expect(find.byKey(const Key('no_logs_text')), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('usage reminder allows incrementing usage with micro-action', (
      tester,
    ) async {
      await db
          .into(db.reminders)
          .insert(
            RemindersCompanion.insert(
              id: 'rem-usage',
              userId: userId,
              itemId: 'item-appliance',
              name: 'Ganti Filter Kopi',
              engineType: 'usage',
              usageThreshold: const drift.Value(50),
              usageCounter: const drift.Value(10),
              usageUnit: const drift.Value('cangkir'),
              createdAt: DateTime.now().toUtc().toIso8601String(),
              updatedAt: DateTime.now().toUtc().toIso8601String(),
            ),
          );

      await tester.pumpWidget(buildTestWidget(reminderId: 'rem-usage'));
      await tester.pumpAndSettle();

      expect(find.text('10 cangkir'), findsOneWidget);
      final plusOneBtn = find.byKey(const Key('plus_one_usage_button'));
      expect(plusOneBtn, findsOneWidget);

      await tester.ensureVisible(plusOneBtn);
      await tester.tap(plusOneBtn);
      await tester.pumpAndSettle();

      expect(find.text('11 cangkir'), findsOneWidget);
      expect(find.text('Pemakaian bertambah (+1)'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('mileage reminder allows updating vehicle odometer', (
      tester,
    ) async {
      await db
          .into(db.reminders)
          .insert(
            RemindersCompanion.insert(
              id: 'rem-mileage',
              userId: userId,
              itemId: 'item-vehicle',
              name: 'Ganti Oli Mesin',
              engineType: 'mileage',
              intervalKm: const drift.Value(5000),
              lastServiceOdometer: const drift.Value(50000),
              createdAt: DateTime.now().toUtc().toIso8601String(),
              updatedAt: DateTime.now().toUtc().toIso8601String(),
            ),
          );

      await tester.pumpWidget(buildTestWidget(reminderId: 'rem-mileage'));
      await tester.pumpAndSettle();

      final updateOdoBtn = find.byKey(const Key('update_odometer_button'));
      expect(updateOdoBtn, findsOneWidget);

      await tester.ensureVisible(updateOdoBtn);
      await tester.tap(updateOdoBtn);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      final odoInput = find.byKey(const Key('new_odometer_input'));
      await tester.enterText(odoInput, '52500');

      final confirmBtn = find.byKey(
        const Key('confirm_update_odometer_button'),
      );
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      expect(find.text('52500 km'), findsOneWidget);
      expect(find.text('Odometer berhasil diperbarui'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets(
      'completing a cycle creates audit log and updates screen state',
      (tester) async {
        await db
            .into(db.reminders)
            .insert(
              RemindersCompanion.insert(
                id: 'rem-cycle',
                userId: userId,
                itemId: 'item-vehicle',
                name: 'Servis Berkala',
                engineType: 'time',
                intervalValue: const drift.Value(6),
                intervalUnit: const drift.Value('months'),
                targetDate: const drift.Value('2026-03-20'),
                baselineMode: const drift.Value('actual_completion'),
                createdAt: DateTime.now().toUtc().toIso8601String(),
                updatedAt: DateTime.now().toUtc().toIso8601String(),
              ),
            );

        await tester.pumpWidget(buildTestWidget(reminderId: 'rem-cycle'));
        await tester.pumpAndSettle();

        final completeBtn = find.byKey(const Key('complete_cycle_button'));
        await tester.ensureVisible(completeBtn);
        await tester.tap(completeBtn);
        await tester.pumpAndSettle();

        expect(find.text('Konfirmasi Selesai'), findsOneWidget);
        await tester.enterText(find.byKey(const Key('cost_input')), '350000');
        await tester.enterText(
          find.byKey(const Key('performed_by_input')),
          'Bengkel Resmi Honda',
        );
        await tester.enterText(
          find.byKey(const Key('notes_input')),
          'Ganti oli mesin dan filter udara',
        );

        final confirmBtn = find.byKey(
          const Key('confirm_complete_cycle_button'),
        );
        await tester.ensureVisible(confirmBtn);
        await tester.tap(confirmBtn);
        await tester.pumpAndSettle();

        expect(
          find.text('Siklus perawatan berhasil diselesaikan'),
          findsOneWidget,
        );
        expect(find.textContaining('Bengkel Resmi Honda'), findsOneWidget);
        expect(find.textContaining('350000'), findsOneWidget);
        expect(find.textContaining('Ganti oli mesin'), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 5));
      },
    );
  });
}
