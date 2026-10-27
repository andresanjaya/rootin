import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rootin_mobile/core/database/database.dart';
import 'package:rootin_mobile/features/reminders/data/reminder_feed.dart';
import 'package:rootin_mobile/features/reminders/presentation/reminder_pages.dart';
import 'package:rootin_mobile/features/settings/settings_provider.dart';
import 'package:rootin_mobile/l10n/generated/app_localizations.dart';

void main() {
  Item item(String id, {bool archived = false, int? odometer}) => Item(
    id: id,
    userId: 'user',
    name: 'Item $id',
    category: 'vehicle',
    brand: null,
    modelNumber: null,
    serialOrPlateNumber: null,
    purchaseDate: null,
    hasOdometer: false,
    currentOdometer: odometer,
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
    int? baseline,
    int? intervalKm,
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
    lastServiceOdometer: baseline,
    intervalKm: intervalKm,
    snoozeUntil: null,
    isActive: active,
    createdAt: '',
    updatedAt: '',
    deletedAt: null,
    version: 1,
  );

  Widget page(
    String section,
    List<ReminderEntry> entries, {
    bool emptyQueue = false,
    OutboxSummary? queue,
    Stream<UserPreference?>? preferences,
    Locale locale = const Locale('en'),
  }) => ProviderScope(
    overrides: [
      localTodayProvider.overrideWithValue(DateTime.utc(2026, 10, 25)),
      reminderFeedProvider.overrideWith((ref) => Stream.value(entries)),
      outboxSummaryProvider.overrideWith(
        (ref) => Stream.value(
          queue ??
              OutboxSummary(
                pending: 0,
                failed: emptyQueue ? 0 : 2,
                conflict: 0,
              ),
        ),
      ),
      userPreferencesProvider.overrideWith(
        (ref) => preferences ?? Stream.value(null),
      ),
    ],
    child: MaterialApp(
      locale: locale,
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

  testWidgets('empty local queue does not imply online connectivity', (
    tester,
  ) async {
    await tester.pumpWidget(page('today', [], emptyQueue: true));
    await tester.pumpAndSettle();
    expect(find.text('Connectivity unknown'), findsOneWidget);
  });

  testWidgets('large feed builds visible tiles lazily and scrolls', (
    tester,
  ) async {
    final entries = [
      for (var i = 0; i < 550; i++)
        ReminderEntry(
          reminder(i.toString().padLeft(3, '0')),
          item(i.toString().padLeft(3, '0')),
        ),
    ];
    await tester.pumpWidget(page('reminders', entries));
    await tester.pumpAndSettle();
    expect(find.byType(ListView), findsOneWidget);
    expect(
      tester.widget<ListView>(find.byType(ListView)).childrenDelegate,
      isA<SliverChildBuilderDelegate>(),
    );
    expect(find.text('Reminder 549'), findsNothing);
    expect(find.text('Reminder 000'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Reminder 549'),
      1000,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Reminder 549'), findsOneWidget);
    expect(find.byType(ListTile).evaluate().length, lessThan(550));
  });

  testWidgets('all outbox counts visible together as live status', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      page(
        'today',
        [],
        queue: const OutboxSummary(pending: 3, failed: 2, conflict: 1),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('2 local changes failed to sync'), findsOneWidget);
    expect(find.text('1 local changes have conflicts'), findsOneWidget);
    expect(find.text('3 pending local changes'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.liveRegion == true,
      ),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets(
    'distance display responds to preference changes without changing km thresholds',
    (tester) async {
      final preferences = StreamController<UserPreference?>.broadcast();
      addTearDown(preferences.close);
      final entry = ReminderEntry(
        reminder('mileage', engine: 'mileage', baseline: 1000, intervalKm: 161),
        item('mileage', odometer: 1080),
      );
      await tester.pumpWidget(
        page('reminders', [entry], preferences: preferences.stream),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('80 / 161 km · 81 km remaining'),
        findsOneWidget,
      );
      preferences.add(preference('mi'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('50 / 100 mi · 50 mi remaining'),
        findsOneWidget,
      );
      preferences.add(preference('km'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('80 / 161 km · 81 km remaining'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'unknown and zero distance remain distinguishable in Indonesian',
    (tester) async {
      final unknown = ReminderEntry(
        reminder('unknown', engine: 'mileage'),
        item('unknown'),
      );
      final zero = ReminderEntry(
        reminder('zero', engine: 'mileage', baseline: 0, intervalKm: 0),
        item('zero', odometer: 0),
      );
      await tester.pumpWidget(
        page(
          'reminders',
          [unknown, zero],
          locale: const Locale('id'),
          preferences: Stream.value(preference('mi')),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Tidak diketahui / Tidak diketahui mi'),
        findsOneWidget,
      );
      expect(find.textContaining('0 / 0 mi · Sisa 0 mi'), findsOneWidget);
    },
  );
}

UserPreference preference(String unit) => UserPreference(
  userId: 'user',
  locale: null,
  distanceUnit: unit,
  timezoneOverride: null,
  reminderTime: '09:00',
);
