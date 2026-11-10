import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rootin_mobile/core/database/database.dart';
import 'package:rootin_mobile/core/time/calendar_clock.dart';
import 'package:rootin_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:rootin_mobile/features/reminders/data/reminder_feed.dart';
import 'package:rootin_mobile/features/reminders/data/reminders_repository.dart';
import 'package:rootin_mobile/features/settings/settings_provider.dart';
import 'package:rootin_mobile/l10n/generated/app_localizations.dart';

class ReminderDetailScreen extends ConsumerStatefulWidget {
  const ReminderDetailScreen({required this.reminderId, super.key});

  final String reminderId;

  @override
  ConsumerState<ReminderDetailScreen> createState() =>
      _ReminderDetailScreenState();
}

class _ReminderDetailScreenState extends ConsumerState<ReminderDetailScreen> {
  bool _isActionInProgress = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final reminderAsync = ref.watch(reminderDetailProvider(widget.reminderId));

    return reminderAsync.when(
      loading:
          () => Scaffold(
            appBar: AppBar(title: Text(l.reminderDetail)),
            body: const Center(child: CircularProgressIndicator()),
          ),
      error:
          (_, _) => Scaffold(
            appBar: AppBar(title: Text(l.reminderDetail)),
            body: Center(child: Text(l.loadFailed)),
          ),
      data: (reminder) {
        if (reminder == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l.reminderDetail)),
            body: Center(child: Text(l.noReminders)),
          );
        }

        final itemAsync = ref.watch(itemDetailProvider(reminder.itemId));
        final logsAsync = ref.watch(reminderLogsProvider(widget.reminderId));

        final item = itemAsync.valueOrNull;
        final logs = logsAsync.valueOrNull ?? const [];

        final today = ref.watch(localTodayProvider) ?? DateTime.now();
        final zone = ref.watch(effectiveTimezoneProvider);

        final entry = item != null ? ReminderEntry(reminder, item) : null;
        final state =
            entry != null
                ? entryState(entry, today, zone)
                : reminderState(reminder, today, zone);
        final progress =
            entry != null ? reminderProgress(entry) : ReminderProgress.unknown;

        return Scaffold(
          appBar: AppBar(
            title: Text(reminder.name),
            actions: [
              IconButton(
                key: const Key('edit_reminder_action'),
                icon: const Icon(Icons.edit_outlined),
                tooltip: l.editReminder,
                onPressed:
                    () => context.push('/reminders/${widget.reminderId}/edit'),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderCard(context, l, reminder, item, state, progress),
                const SizedBox(height: 16),
                _buildProgressCard(context, l, reminder, item, today, zone),
                const SizedBox(height: 16),
                _buildActionsSection(context, l, reminder, item),
                const SizedBox(height: 24),
                _buildHistorySection(context, l, logs),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
    AppLocalizations l,
    Reminder reminder,
    Item? item,
    ReminderState state,
    ReminderProgress progress,
  ) {
    final theme = Theme.of(context);
    final engineLabel = switch (reminder.engineType) {
      'usage' => l.usageType,
      'mileage' => l.mileageType,
      _ => l.timeType,
    };

    final statusColor = switch (state) {
      ReminderState.overdue => theme.colorScheme.error,
      ReminderState.due => theme.colorScheme.error,
      ReminderState.soon => theme.colorScheme.tertiary,
      _ => theme.colorScheme.primary,
    };

    final statusText = switch (state) {
      ReminderState.overdue => l.overdue,
      ReminderState.due => l.dueToday,
      ReminderState.soon => l.soon,
      ReminderState.later => l.later,
      ReminderState.noDate => l.noDate,
    };

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    reminder.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  side: BorderSide(color: statusColor),
                  backgroundColor: statusColor.withValues(alpha: 0.1),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  item != null ? '${item.name} (${item.category})' : '...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(engineLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    AppLocalizations l,
    Reminder reminder,
    Item? item,
    DateTime today,
    String? zone,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.progressSection,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            if (reminder.engineType == 'time') ...[
              _buildInfoRow(l.targetDate, reminder.targetDate ?? l.noDate),
              if (reminder.targetTime != null)
                _buildInfoRow(l.targetTime, reminder.targetTime!),
              _buildInfoRow(
                l.intervalValue,
                '${reminder.intervalValue ?? 1} ${_intervalUnitLabel(l, reminder.intervalUnit)}',
              ),
              _buildInfoRow(
                l.baselineMode,
                reminder.baselineMode == 'strict_schedule'
                    ? l.strictSchedule
                    : l.actualCompletion,
              ),
            ] else if (reminder.engineType == 'usage') ...[
              _buildInfoRow(
                l.usageThreshold,
                '${reminder.usageThreshold ?? 0} ${reminder.usageUnit ?? ''}',
              ),
              _buildInfoRow(
                l.currentUsage,
                '${reminder.usageCounter ?? 0} ${reminder.usageUnit ?? ''}',
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value:
                    (reminder.usageThreshold ?? 0) > 0
                        ? ((reminder.usageCounter ?? 0) /
                                reminder.usageThreshold!)
                            .clamp(0.0, 1.0)
                        : 0.0,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                l.remainingUsage(
                  ((reminder.usageThreshold ?? 0) -
                          (reminder.usageCounter ?? 0))
                      .clamp(0, reminder.usageThreshold ?? 0),
                ),
                '',
              ),
            ] else if (reminder.engineType == 'mileage') ...[
              _buildInfoRow(
                l.lastServiceOdometer,
                '${reminder.lastServiceOdometer ?? 0} km',
              ),
              _buildInfoRow(
                l.currentOdometer,
                '${item?.currentOdometer ?? 0} km',
              ),
              _buildInfoRow(l.intervalKm, '${reminder.intervalKm ?? 0} km'),
              _buildInfoRow(
                l.targetOdometerPreview(
                  (reminder.lastServiceOdometer ?? 0) +
                      (reminder.intervalKm ?? 0),
                ),
                '',
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value:
                    (reminder.intervalKm ?? 0) > 0
                        ? (((item?.currentOdometer ?? 0) -
                                    (reminder.lastServiceOdometer ?? 0)) /
                                reminder.intervalKm!)
                            .clamp(0.0, 1.0)
                        : 0.0,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                l.remainingDistance(
                  (((reminder.lastServiceOdometer ?? 0) +
                              (reminder.intervalKm ?? 0)) -
                          (item?.currentOdometer ?? 0))
                      .clamp(0, reminder.intervalKm ?? 0),
                  'km',
                ),
                '',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildActionsSection(
    BuildContext context,
    AppLocalizations l,
    Reminder reminder,
    Item? item,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (reminder.engineType == 'usage') ...[
          OutlinedButton.icon(
            key: const Key('plus_one_usage_button'),
            icon: const Icon(Icons.exposure_plus_1),
            label: Text(l.plusOneUsage),
            onPressed:
                _isActionInProgress
                    ? null
                    : () => _handleIncrementUsage(reminder),
          ),
          const SizedBox(height: 8),
        ],
        if (item != null && item.hasOdometer) ...[
          OutlinedButton.icon(
            key: const Key('update_odometer_button'),
            icon: const Icon(Icons.speed),
            label: Text(l.updateOdometer),
            onPressed:
                _isActionInProgress
                    ? null
                    : () => _showUpdateOdometerDialog(context, l, item),
          ),
          const SizedBox(height: 8),
        ],
        FilledButton.icon(
          key: const Key('complete_cycle_button'),
          icon: const Icon(Icons.check_circle_outline),
          label: Text(l.completeCycle),
          onPressed:
              _isActionInProgress
                  ? null
                  : () => _showCompleteCycleSheet(context, l, reminder, item),
        ),
      ],
    );
  }

  Widget _buildHistorySection(
    BuildContext context,
    AppLocalizations l,
    List<ReminderLog> logs,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.serviceHistory,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (logs.isEmpty)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  l.noLogsYet,
                  key: const Key('no_logs_text'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: logs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final log = logs[index];
              final details = [
                if (log.performedBy != null && log.performedBy!.isNotEmpty)
                  l.performedByLabel(log.performedBy!),
                if (log.cost != null) l.costLabel(log.cost!.toStringAsFixed(0)),
                if (log.odometerAtCompletion != null)
                  l.odometerLabel(log.odometerAtCompletion!),
                if (log.notes != null && log.notes!.isNotEmpty) log.notes!,
              ];

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                  title: Text(l.completedOn(log.completionDate)),
                  subtitle:
                      details.isNotEmpty ? Text(details.join(' · ')) : null,
                ),
              );
            },
          ),
      ],
    );
  }

  Future<void> _handleIncrementUsage(Reminder reminder) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isActionInProgress = true);
    final l = AppLocalizations.of(context)!;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await ref
          .read(remindersRepositoryProvider)
          .recordUsageIncrement(userId: user.id, reminderId: reminder.id);
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(l.usageIncremented)),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(l.usageIncrementFailed)),
      );
    } finally {
      if (mounted) {
        setState(() => _isActionInProgress = false);
      }
    }
  }

  Future<void> _showUpdateOdometerDialog(
    BuildContext context,
    AppLocalizations l,
    Item item,
  ) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final controller = TextEditingController(
      text: (item.currentOdometer ?? 0).toString(),
    );
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l.updateOdometer),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  key: const Key('new_odometer_input'),
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: l.newOdometer,
                    hintText: l.newOdometerHint,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l.newOdometerRequired;
                    }
                    final parsed = int.tryParse(value.trim());
                    if (parsed == null ||
                        parsed < (item.currentOdometer ?? 0)) {
                      return l.newOdometerInvalid;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l.cancel),
            ),
            FilledButton(
              key: const Key('confirm_update_odometer_button'),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final newOdo = int.parse(controller.text.trim());
                Navigator.pop(dialogContext);

                setState(() => _isActionInProgress = true);
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                try {
                  await ref
                      .read(remindersRepositoryProvider)
                      .recordOdometerUpdate(
                        userId: user.id,
                        itemId: item.id,
                        newOdometer: newOdo,
                      );
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text(l.odometerUpdated)),
                  );
                } catch (e) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text(l.odometerUpdateFailed)),
                  );
                } finally {
                  if (mounted) {
                    setState(() => _isActionInProgress = false);
                  }
                }
              },
              child: Text(l.save),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCompleteCycleSheet(
    BuildContext context,
    AppLocalizations l,
    Reminder reminder,
    Item? item,
  ) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final initialDate = formatCalendarDate(DateTime.now());
    final dateController = TextEditingController(text: initialDate);
    final odoController = TextEditingController(
      text:
          item?.hasOdometer == true && item?.currentOdometer != null
              ? item!.currentOdometer.toString()
              : '',
    );
    final costController = TextEditingController();
    final performedByController = TextEditingController();
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l.completeCycle,
                    style: Theme.of(sheetContext).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('completion_date_input'),
                    controller: dateController,
                    decoration: InputDecoration(
                      labelText: l.completionDate,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: sheetContext,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            dateController.text = formatCalendarDate(picked);
                          }
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l.targetDateRequired;
                      }
                      try {
                        parseCalendarDate(value.trim());
                        return null;
                      } catch (_) {
                        return l.targetDateInvalid;
                      }
                    },
                  ),
                  if (item?.hasOdometer == true) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const Key('odometer_completion_input'),
                      controller: odoController,
                      decoration: InputDecoration(
                        labelText: l.odometerAtCompletion,
                        hintText: l.odometerAtCompletionHint(
                          item?.currentOdometer ?? 0,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (reminder.engineType == 'mileage' &&
                            (value == null || value.trim().isEmpty)) {
                          return l.lastServiceOdometerRequired;
                        }
                        if (value != null && value.trim().isNotEmpty) {
                          final parsed = int.tryParse(value.trim());
                          if (parsed == null || parsed < 0) {
                            return l.intervalKmPositive;
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('cost_input'),
                    controller: costController,
                    decoration: InputDecoration(
                      labelText: l.cost,
                      hintText: l.costHint,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('performed_by_input'),
                    controller: performedByController,
                    decoration: InputDecoration(
                      labelText: l.performedBy,
                      hintText: l.performedByHint,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('notes_input'),
                    controller: notesController,
                    decoration: InputDecoration(
                      labelText: l.notes,
                      hintText: l.notesHint,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    key: const Key('confirm_complete_cycle_button'),
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;

                      final compDate = dateController.text.trim();
                      final odo = int.tryParse(odoController.text.trim());
                      final cost = double.tryParse(costController.text.trim());
                      final performedBy =
                          performedByController.text.trim().isEmpty
                              ? null
                              : performedByController.text.trim();
                      final notes =
                          notesController.text.trim().isEmpty
                              ? null
                              : notesController.text.trim();

                      Navigator.pop(sheetContext);

                      setState(() => _isActionInProgress = true);
                      final scaffoldMessenger = ScaffoldMessenger.of(context);

                      try {
                        await ref
                            .read(remindersRepositoryProvider)
                            .completeReminderCycle(
                              userId: user.id,
                              reminderId: reminder.id,
                              completionDate: compDate,
                              odometerAtCompletion: odo,
                              cost: cost,
                              performedBy: performedBy,
                              notes: notes,
                            );
                        scaffoldMessenger.showSnackBar(
                          SnackBar(content: Text(l.cycleCompleted)),
                        );
                      } catch (e) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(content: Text(l.cycleCompleteFailed)),
                        );
                      } finally {
                        if (mounted) {
                          setState(() => _isActionInProgress = false);
                        }
                      }
                    },
                    child: Text(l.confirmComplete),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _intervalUnitLabel(AppLocalizations l, String? unit) {
    return switch (unit) {
      'days' => l.daysUnit,
      'weeks' => l.weeksUnit,
      'months' => l.monthsUnit,
      'years' => l.yearsUnit,
      _ => unit ?? '',
    };
  }
}
