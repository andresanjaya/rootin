import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rootin_mobile/core/database/database.dart';
import 'package:rootin_mobile/features/reminders/data/reminder_feed.dart';
import 'package:rootin_mobile/features/reminders/presentation/reminder_pages.dart';
import 'package:rootin_mobile/l10n/generated/app_localizations.dart';

void main() {
  Item item(String id, {bool archived = false}) => Item(
    id: id,
    userId: 'user',
    name: 'Item $id',
    category: 'vehicle',
    brand: null,
    modelNumber: null,
    serialOrPlateNumber: null,
    purchaseDate: null,
    hasOdometer: false,
    currentOdometer: null,
    photoLocalPath: null,
    photoRemotePath: null,
    notes: null,
    isArchived: archived,
    createdAt: '',
    updatedAt: '',
    deletedAt: null,
    version: 1,
  );

  Reminder reminder(
    String id, {
    String engine = 'time',
    bool active = true,
    int? usageCounter,
    int? usageThreshold,
  }) => Reminder(
    id: id,
    userId: 'user',
    itemId: id,
    name: 'Reminder $id',
    engineType: engine,
    intervalUnit: null,
    intervalValue: null,
    baselineMode: null,
    anchorDay: null,
    targetDate: engine == 'time' ? '2026-10-25' : null,
    targetTime: null,
    usageCounter: usageCounter,
    usageThreshold: usageThreshold,
    usageUnit: engine == 'usage' ? 'hours' : null,
    lastServiceOdometer: null,
    intervalKm: null,
    snoozeUntil: null,
    isActive: active,
    createdAt: '',
    updatedAt: '',
    deletedAt: null,
    version: 1,
  );

  Widget page(String section, List<ReminderEntry> entries) => ProviderScope(
    overrides: [
      localTodayProvider.overrideWithValue(DateTime.utc(2026, 10, 25)),
      reminderFeedProvider.overrideWith((ref) => Stream.value(entries)),
      outboxSummaryProvider.overrideWith(
        (ref) => Stream.value(
          const OutboxSummary(pending: 0, failed: 2, conflict: 0),
        ),
      ),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ReminderPage(section: section),
    ),
  );

  testWidgets('shows localized warning progress, outbox failure, and archive', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final active = ReminderEntry(
      reminder(
        'active',
        engine: 'usage',
        usageCounter: 80,
        usageThreshold: 100,
      ),
      item('active'),
    );
    final archived = ReminderEntry(
      reminder('archived', active: false),
      item('archived'),
    );
    await tester.pumpWidget(page('reminders', [active, archived]));
    await tester.pumpAndSettle();

    expect(find.text('2 local changes failed to sync'), findsOneWidget);
    expect(find.textContaining('80 / 100 hours'), findsOneWidget);
    expect(find.textContaining('20 remaining'), findsOneWidget);
    expect(find.textContaining('Warning'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    expect(find.text('Reminder archived'), findsNothing);

    await tester.tap(find.byKey(const Key('reminder_activity_filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Inactive / archived').last);
    await tester.pumpAndSettle();

    expect(find.text('Reminder active'), findsNothing);
    expect(find.text('Reminder archived'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('Today and Calendar exclude inactive reminders', (tester) async {
    final active = ReminderEntry(reminder('active'), item('active'));
    final archived = ReminderEntry(
      reminder('archived', active: false),
      item('archived'),
    );
    await tester.pumpWidget(page('calendar', [active, archived]));
    await tester.pumpAndSettle();

    expect(find.text('Reminder active'), findsOneWidget);
    expect(find.text('Reminder archived'), findsNothing);
  });
}
