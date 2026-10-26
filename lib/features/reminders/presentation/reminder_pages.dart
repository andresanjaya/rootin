import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rootin_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:rootin_mobile/features/reminders/data/reminder_feed.dart';
import 'package:rootin_mobile/features/settings/settings_provider.dart';
import 'package:rootin_mobile/l10n/generated/app_localizations.dart';

class ReminderShell extends ConsumerWidget {
  const ReminderShell({required this.navigationShell, super.key});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final destinations = [
      l.today,
      l.reminders,
      l.items,
      l.calendar,
      l.settings,
    ];
    final icons = [
      Icons.today_outlined,
      Icons.notifications_outlined,
      Icons.inventory_2_outlined,
      Icons.calendar_month_outlined,
      Icons.settings_outlined,
    ];
    final index = navigationShell.currentIndex;
    final wide = MediaQuery.sizeOf(context).width >= 700;
    void selectBranch(int selected) => navigationShell.goBranch(
      selected,
      initialLocation: selected == navigationShell.currentIndex,
    );
    final navigation = NavigationRail(
      selectedIndex: index,
      labelType: NavigationRailLabelType.all,
      onDestinationSelected: selectBranch,
      destinations: [
        for (var i = 0; i < destinations.length; i++)
          NavigationRailDestination(
            icon: Icon(icons[i]),
            label: Text(destinations[i]),
          ),
      ],
    );
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [if (wide) navigation, Expanded(child: navigationShell)],
        ),
      ),
      floatingActionButton:
          index == 0
              ? IconButton(
                key: const Key('home_logout_button'),
                icon: const Icon(Icons.logout),
                tooltip: l.logout,
                onPressed:
                    () => ref.read(authControllerProvider.notifier).signOut(),
              )
              : null,
      bottomNavigationBar:
          wide
              ? null
              : SafeArea(
                child: NavigationBar(
                  selectedIndex: index,
                  onDestinationSelected: selectBranch,
                  destinations: [
                    for (var i = 0; i < destinations.length; i++)
                      NavigationDestination(
                        icon: Icon(icons[i]),
                        label: destinations[i],
                      ),
                  ],
                ),
              ),
    );
  }
}

class ReminderPage extends ConsumerStatefulWidget {
  const ReminderPage({required this.section, super.key});
  final String section;

  @override
  ConsumerState<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends ConsumerState<ReminderPage> {
  String query = '';
  String type = 'all';
  String status = 'all';
  String activity = 'active';
  String category = 'all';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final title = switch (widget.section) {
      'today' => l.today,
      'items' => l.items,
      'calendar' => l.calendar,
      'history' => l.history,
      _ => l.reminders,
    };
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            key: const Key('refresh_local_data_button'),
            icon: const Icon(Icons.refresh),
            tooltip: l.refreshLocalData,
            onPressed: _refreshLocalData,
          ),
          if (widget.section != 'history')
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: l.history,
              onPressed:
                  () => context.push(
                    '${GoRouterState.of(context).uri.path}/history',
                  ),
            ),
        ],
      ),
      body: switch (widget.section) {
        'items' => _items(l),
        'history' => _history(l),
        _ => _reminders(l),
      },
    );
  }

  Future<void> _refreshLocalData() async {
    switch (widget.section) {
      case 'items':
        ref.invalidate(visibleItemsProvider);
        await ref.read(visibleItemsProvider.future);
      case 'history':
        ref.invalidate(historyProvider);
        await ref.read(historyProvider.future);
      default:
        ref.invalidate(reminderFeedProvider);
        ref.invalidate(outboxSummaryProvider);
        await Future.wait([
          ref.read(reminderFeedProvider.future),
          ref.read(outboxSummaryProvider.future),
        ]);
    }
  }

  Widget _items(AppLocalizations l) => ref
      .watch(visibleItemsProvider)
      .when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _message(l.loadFailed),
        data:
            (items) =>
                items.isEmpty
                    ? _message(l.noItems)
                    : ListView(
                      children: [
                        for (final item in items)
                          ListTile(
                            title: Text(item.name),
                            subtitle: Text(item.category),
                          ),
                      ],
                    ),
      );

  Widget _history(AppLocalizations l) => ref
      .watch(historyProvider)
      .when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _message(l.loadFailed),
        data:
            (logs) =>
                logs.isEmpty
                    ? _message(l.noHistory)
                    : ListView(
                      children: [
                        for (final log in logs)
                          ListTile(
                            title: Text(log.completionDate),
                            subtitle: Text(log.notes ?? l.completed),
                          ),
                      ],
                    ),
      );

  Widget _reminders(AppLocalizations l) {
    final today = ref.watch(localTodayProvider);
    final zone = ref.watch(effectiveTimezoneProvider);
    final feed = ref.watch(reminderFeedProvider);
    final outbox = ref.watch(outboxSummaryProvider);
    return feed.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => _message(l.loadFailed),
      data: (entries) {
        if (today == null) return _message(l.timezoneUnavailable);
        final filtered =
            entries.where((entry) {
                final reminder = entry.reminder;
                final state = entryState(entry, today, zone);
                final active = reminder.isActive && !entry.item.isArchived;
                if (widget.section != 'reminders' && !active) return false;
                if (widget.section == 'reminders' &&
                    activity == 'active' &&
                    !active) {
                  return false;
                }
                if (widget.section == 'reminders' &&
                    activity == 'archived' &&
                    active) {
                  return false;
                }
                if (widget.section == 'calendar' &&
                    reminderDay(reminder, zone) == null) {
                  return false;
                }
                if (widget.section == 'today' &&
                    state != ReminderState.overdue &&
                    state != ReminderState.due &&
                    state != ReminderState.soon) {
                  return false;
                }
                if (type != 'all' && reminder.engineType != type) return false;
                if (status != 'all' && state.name != status) return false;
                if (category != 'all' && entry.item.category != category) {
                  return false;
                }
                return reminder.name.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    entry.item.name.toLowerCase().contains(query.toLowerCase());
              }).toList()
              ..sort((a, b) => compareEntries(a, b, today, zone));
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _outboxStatus(l, outbox),
            if (widget.section == 'reminders') ...[
              TextField(
                decoration: InputDecoration(
                  labelText: l.searchReminders,
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (value) => setState(() => query = value),
              ),
              Wrap(
                spacing: 8,
                children: [
                  DropdownButton<String>(
                    value: type,
                    hint: Text(l.type),
                    items: [
                      DropdownMenuItem(value: 'all', child: Text(l.allTypes)),
                      DropdownMenuItem(value: 'time', child: Text(l.timeType)),
                      DropdownMenuItem(
                        value: 'usage',
                        child: Text(l.usageType),
                      ),
                      DropdownMenuItem(
                        value: 'mileage',
                        child: Text(l.mileageType),
                      ),
                    ],
                    onChanged: (value) => setState(() => type = value!),
                  ),
                  DropdownButton<String>(
                    value: status,
                    hint: Text(l.status),
                    items: [
                      DropdownMenuItem(
                        value: 'all',
                        child: Text(l.allStatuses),
                      ),
                      for (final state in ReminderState.values)
                        DropdownMenuItem(
                          value: state.name,
                          child: Text(_status(l, state)),
                        ),
                    ],
                    onChanged: (value) => setState(() => status = value!),
                  ),
                  DropdownButton<String>(
                    key: const Key('reminder_activity_filter'),
                    value: activity,
                    items: [
                      DropdownMenuItem(
                        value: 'active',
                        child: Text(l.activeReminders),
                      ),
                      DropdownMenuItem(
                        value: 'archived',
                        child: Text(l.archivedReminders),
                      ),
                    ],
                    onChanged: (value) => setState(() => activity = value!),
                  ),
                  DropdownButton<String>(
                    key: const Key('reminder_category_filter'),
                    value: category,
                    items: [
                      DropdownMenuItem(
                        value: 'all',
                        child: Text(l.allCategories),
                      ),
                      for (final value
                          in (entries
                              .map((entry) => entry.item.category)
                              .toSet()
                              .toList()
                            ..sort()))
                        DropdownMenuItem(value: value, child: Text(value)),
                    ],
                    onChanged: (value) => setState(() => category = value!),
                  ),
                ],
              ),
            ],
            if (filtered.isEmpty)
              _message(
                widget.section == 'calendar'
                    ? l.noScheduledReminders
                    : l.noReminders,
              ),
            for (final entry in filtered)
              ListTile(
                leading:
                    reminderProgress(entry) == ReminderProgress.warning
                        ? Icon(
                          Icons.warning_amber_rounded,
                          color: Theme.of(context).colorScheme.tertiary,
                          semanticLabel: l.warning,
                        )
                        : null,
                title: Text(entry.reminder.name),
                subtitle: Text(
                  '${entry.item.name} · ${_detail(l, entry, today, zone)}',
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _outboxStatus(AppLocalizations l, AsyncValue<OutboxSummary> outbox) =>
      switch (outbox) {
        AsyncData(:final value) when value.failed > 0 => Semantics(
          liveRegion: true,
          child: Text(l.failedSync(value.failed)),
        ),
        AsyncData(:final value) when value.conflict > 0 => Semantics(
          liveRegion: true,
          child: Text(l.conflictedSync(value.conflict)),
        ),
        AsyncData(:final value) when value.pending > 0 => Semantics(
          liveRegion: true,
          child: Text(l.pendingSync(value.pending)),
        ),
        AsyncError() => Text(l.syncStatusUnavailable),
        _ => Text(l.connectivityUnknown),
      };

  String _detail(
    AppLocalizations l,
    ReminderEntry entry,
    DateTime today,
    String? zone,
  ) {
    final reminder = entry.reminder;
    if (reminder.engineType == 'usage') {
      final count = reminder.usageCounter;
      final threshold = reminder.usageThreshold;
      final remaining =
          count == null || threshold == null
              ? null
              : (threshold - count).clamp(0, threshold);
      return '${l.usageType}: ${count ?? l.unknown} / ${threshold ?? l.unknown} ${reminder.usageUnit ?? ''} · ${remaining == null ? l.unknown : l.remainingUsage(remaining)} · ${_progress(l, reminderProgress(entry))}';
    }
    if (reminder.engineType == 'mileage') {
      final current = entry.item.currentOdometer;
      final baseline = reminder.lastServiceOdometer;
      final interval = reminder.intervalKm;
      final progress =
          current == null || baseline == null
              ? null
              : (current - baseline).clamp(0, interval ?? current);
      final remaining =
          current == null || baseline == null || interval == null
              ? null
              : (baseline + interval - current).clamp(0, interval);
      return '${l.mileageType}: ${progress ?? l.unknown} / ${interval ?? l.unknown} km · ${remaining == null ? l.unknown : l.remainingDistance(remaining)} · ${_progress(l, reminderProgress(entry))}';
    }
    final day = reminderDay(reminder, zone);
    return '${_status(l, reminderState(reminder, today, zone))}${day == null ? '' : ' · ${formatDay(day)}'}';
  }

  String formatDay(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

  String _status(AppLocalizations l, ReminderState state) => switch (state) {
    ReminderState.overdue => l.overdue,
    ReminderState.due => l.dueToday,
    ReminderState.soon => l.soon,
    ReminderState.later => l.later,
    ReminderState.noDate => l.noDate,
  };

  String _progress(AppLocalizations l, ReminderProgress progress) =>
      switch (progress) {
        ReminderProgress.normal => l.normal,
        ReminderProgress.warning => l.warning,
        ReminderProgress.due => l.due,
        ReminderProgress.unknown => l.unknown,
      };

  Widget _message(String text) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(text, textAlign: TextAlign.center),
    ),
  );
}
