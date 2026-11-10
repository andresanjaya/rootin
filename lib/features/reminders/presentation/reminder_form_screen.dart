import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rootin_mobile/core/database/database.dart';
import 'package:rootin_mobile/core/time/calendar_clock.dart';
import 'package:rootin_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:rootin_mobile/features/reminders/data/reminders_repository.dart';
import 'package:rootin_mobile/features/reminders/domain/reminder_rules.dart';
import 'package:rootin_mobile/l10n/generated/app_localizations.dart';

class ReminderFormScreen extends ConsumerStatefulWidget {
  const ReminderFormScreen({super.key, this.reminderId, this.initialItemId});

  final String? reminderId;
  final String? initialItemId;

  @override
  ConsumerState<ReminderFormScreen> createState() => _ReminderFormScreenState();
}

class _ReminderFormScreenState extends ConsumerState<ReminderFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _targetDateController;
  late final TextEditingController _targetTimeController;
  late final TextEditingController _intervalValueController;
  late final TextEditingController _usageThresholdController;
  late final TextEditingController _usageCounterController;
  late final TextEditingController _usageUnitController;
  late final TextEditingController _intervalKmController;
  late final TextEditingController _lastServiceOdometerController;

  String? _selectedItemId;
  String _engineType = 'time';
  String _intervalUnit = 'months';
  String _baselineMode = 'actual_completion';

  bool _isLoading = false;
  bool _isSaving = false;
  List<Item> _items = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _targetDateController = TextEditingController(
      text: formatCalendarDate(DateTime.now().toUtc()),
    );
    _targetTimeController = TextEditingController(text: '09:00');
    _intervalValueController = TextEditingController(text: '1');
    _usageThresholdController = TextEditingController();
    _usageCounterController = TextEditingController(text: '0');
    _usageUnitController = TextEditingController();
    _intervalKmController = TextEditingController(text: '5000');
    _lastServiceOdometerController = TextEditingController(text: '0');

    _selectedItemId = widget.initialItemId;
    _loadInitialData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetDateController.dispose();
    _targetTimeController.dispose();
    _intervalValueController.dispose();
    _usageThresholdController.dispose();
    _usageCounterController.dispose();
    _usageUnitController.dispose();
    _intervalKmController.dispose();
    _lastServiceOdometerController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isLoading = true);
    final repo = ref.read(remindersRepositoryProvider);

    try {
      final items = await repo.getActiveItems(user.id);
      Reminder? existing;
      if (widget.reminderId != null) {
        existing = await repo.getReminderById(user.id, widget.reminderId!);
      }

      if (!mounted) return;

      setState(() {
        _items = items;
        if (_selectedItemId == null && items.isNotEmpty) {
          _selectedItemId = items.first.id;
        }

        if (existing != null) {
          _selectedItemId = existing.itemId;
          _nameController.text = existing.name;
          _engineType = existing.engineType;

          if (existing.engineType == 'time') {
            _intervalUnit = existing.intervalUnit ?? 'months';
            _intervalValueController.text =
                existing.intervalValue?.toString() ?? '1';
            _baselineMode = existing.baselineMode ?? 'actual_completion';
            if (existing.targetDate != null) {
              _targetDateController.text = existing.targetDate!;
            }
            if (existing.targetTime != null) {
              _targetTimeController.text = existing.targetTime!;
            }
          } else if (existing.engineType == 'usage') {
            _usageThresholdController.text =
                existing.usageThreshold?.toString() ?? '';
            _usageCounterController.text =
                existing.usageCounter?.toString() ?? '0';
            _usageUnitController.text = existing.usageUnit ?? '';
          } else if (existing.engineType == 'mileage') {
            _intervalKmController.text = existing.intervalKm?.toString() ?? '';
            _lastServiceOdometerController.text =
                existing.lastServiceOdometer?.toString() ?? '0';
          }
        } else if (_selectedItemId != null) {
          final currentItem = items.firstWhere(
            (it) => it.id == _selectedItemId,
            orElse: () => items.first,
          );
          if (currentItem.hasOdometer) {
            _lastServiceOdometerController.text =
                (currentItem.currentOdometer ?? 0).toString();
          }
        }
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Item? get _selectedItem {
    if (_selectedItemId == null || _items.isEmpty) return null;
    try {
      return _items.firstWhere((it) => it.id == _selectedItemId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickTargetDate() async {
    DateTime initial = DateTime.now().toUtc();
    try {
      initial = parseCalendarDate(_targetDateController.text.trim());
    } catch (_) {}

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && mounted) {
      setState(() {
        _targetDateController.text = formatCalendarDate(picked);
      });
    }
  }

  Future<void> _pickTargetTime() async {
    TimeOfDay initial = const TimeOfDay(hour: 9, minute: 0);
    try {
      final parts = _targetTimeController.text.split(':');
      if (parts.length == 2) {
        initial = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (_) {}

    final picked = await showTimePicker(context: context, initialTime: initial);

    if (picked != null && mounted) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        _targetTimeController.text = formatted;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_isSaving) return;
    final l = AppLocalizations.of(context)!;
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    if (!_formKey.currentState!.validate()) return;

    final selectedItem = _selectedItem;
    if (selectedItem == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.selectItemRequired)));
      return;
    }

    if (_engineType == 'mileage' && !selectedItem.hasOdometer) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.vehicleRequiredForMileage)));
      return;
    }

    int? anchorDay;
    if (_engineType == 'time' && _targetDateController.text.isNotEmpty) {
      try {
        final parsed = parseCalendarDate(_targetDateController.text.trim());
        anchorDay = parsed.day;
      } catch (_) {}
    }

    final formData = ReminderFormData(
      id: widget.reminderId,
      itemId: selectedItem.id,
      name: _nameController.text.trim(),
      engineType: _engineType,
      // Time fields
      intervalUnit: _engineType == 'time' ? _intervalUnit : null,
      intervalValue:
          _engineType == 'time'
              ? int.tryParse(_intervalValueController.text.trim())
              : null,
      baselineMode: _baselineMode,
      anchorDay: anchorDay,
      targetDate:
          _engineType == 'time' ? _targetDateController.text.trim() : null,
      targetTime:
          _engineType == 'time' && _targetTimeController.text.isNotEmpty
              ? _targetTimeController.text.trim()
              : null,
      // Usage fields
      usageThreshold:
          _engineType == 'usage'
              ? int.tryParse(_usageThresholdController.text.trim())
              : null,
      usageCounter:
          _engineType == 'usage'
              ? int.tryParse(_usageCounterController.text.trim()) ?? 0
              : 0,
      usageUnit:
          _engineType == 'usage' && _usageUnitController.text.isNotEmpty
              ? _usageUnitController.text.trim()
              : null,
      // Mileage fields
      intervalKm:
          _engineType == 'mileage'
              ? int.tryParse(_intervalKmController.text.trim())
              : null,
      lastServiceOdometer:
          _engineType == 'mileage'
              ? int.tryParse(_lastServiceOdometerController.text.trim())
              : null,
    );

    setState(() => _isSaving = true);
    try {
      await ref
          .read(remindersRepositoryProvider)
          .saveReminder(userId: user.id, data: formData);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.reminderSaved)));
        context.pop();
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l.reminderSaveFailed}: $error')),
        );
      }
    }
  }

  Widget _buildLivePreview(AppLocalizations l) {
    final theme = Theme.of(context);

    if (_engineType == 'time') {
      DateTime? startDate;
      try {
        startDate = parseCalendarDate(_targetDateController.text.trim());
      } catch (_) {}

      final intervalVal = int.tryParse(_intervalValueController.text.trim());

      if (startDate != null && intervalVal != null && intervalVal > 0) {
        final previewDates = ReminderRules.generateNextDueDatesPreview(
          startDate: startDate,
          intervalValue: intervalVal,
          intervalUnit: _intervalUnit,
          anchorDay: startDate.day,
          count: 3,
        );

        return Card(
          color: theme.colorScheme.surfaceContainerHighest,
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.preview_outlined,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l.schedulePreview,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (var i = 0; i < previewDates.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '${i + 1}. ${formatCalendarDate(previewDates[i])}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
              ],
            ),
          ),
        );
      }
    } else if (_engineType == 'usage') {
      final counter = int.tryParse(_usageCounterController.text.trim()) ?? 0;
      final threshold = int.tryParse(_usageThresholdController.text.trim());

      if (threshold != null && threshold > 0) {
        final wear = ReminderRules.calculateUsageWearPercentage(
          counter: counter,
          threshold: threshold,
        );
        final remaining = ReminderRules.calculateRemainingUsage(
          counter: counter,
          threshold: threshold,
        );
        final status = ReminderRules.evaluateUsageProgress(
          counter: counter,
          threshold: threshold,
        );

        final color =
            status == 'due'
                ? theme.colorScheme.error
                : status == 'warning'
                ? Colors.amber.shade800
                : theme.colorScheme.primary;

        return Card(
          color: theme.colorScheme.surfaceContainerHighest,
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.speed_outlined, size: 20, color: color),
                    const SizedBox(width: 8),
                    Text(
                      l.wearPreview,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (wear / 100.0).clamp(0.0, 1.0),
                  color: color,
                  backgroundColor: theme.colorScheme.surfaceContainer,
                ),
                const SizedBox(height: 6),
                Text(
                  '${wear.toStringAsFixed(1)}% — ${l.remainingUsage(remaining)}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      }
    } else if (_engineType == 'mileage') {
      final lastService = int.tryParse(
        _lastServiceOdometerController.text.trim(),
      );
      final interval = int.tryParse(_intervalKmController.text.trim());
      final currentOdo = _selectedItem?.currentOdometer ?? 0;

      if (lastService != null &&
          lastService >= 0 &&
          interval != null &&
          interval > 0) {
        final targetOdo = ReminderRules.calculateTargetOdometer(
          lastServiceOdometer: lastService,
          intervalKm: interval,
        );
        final remainingKm = ReminderRules.calculateRemainingKm(
          targetOdometer: targetOdo,
          currentOdometer: currentOdo,
        );
        final status = ReminderRules.evaluateMileageProgress(
          lastServiceOdometer: lastService,
          intervalKm: interval,
          currentOdometer: currentOdo,
        );

        final color =
            status == 'due'
                ? theme.colorScheme.error
                : status == 'warning'
                ? Colors.amber.shade800
                : theme.colorScheme.primary;

        return Card(
          color: theme.colorScheme.surfaceContainerHighest,
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.directions_car_outlined, size: 20, color: color),
                    const SizedBox(width: 8),
                    Text(
                      l.targetOdometerPreview(targetOdo),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  l.remainingDistance(remainingKm, 'km'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isEdit = widget.reminderId != null;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(isEdit ? l.editReminder : l.addReminder)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? l.editReminder : l.addReminder)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Item Selection
                DropdownButtonFormField<String>(
                  value: _selectedItemId,
                  decoration: InputDecoration(
                    labelText: l.selectItem,
                    prefixIcon: const Icon(Icons.inventory_2_outlined),
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    for (final item in _items)
                      DropdownMenuItem(
                        value: item.id,
                        child: Text(
                          item.name + (item.hasOdometer ? ' (Odo)' : ''),
                        ),
                      ),
                  ],
                  onChanged:
                      isEdit
                          ? null // Immutable parent item on edit
                          : (val) {
                            setState(() {
                              _selectedItemId = val;
                              final selected = _selectedItem;
                              if (selected != null && selected.hasOdometer) {
                                _lastServiceOdometerController.text =
                                    (selected.currentOdometer ?? 0).toString();
                              }
                            });
                          },
                  validator:
                      (val) =>
                          val == null || val.isEmpty
                              ? l.selectItemRequired
                              : null,
                ),
                const SizedBox(height: 16),

                // 2. Reminder Name
                TextFormField(
                  key: const Key('reminder_name_input'),
                  controller: _nameController,
                  maxLength: 150,
                  decoration: InputDecoration(
                    labelText: l.reminderName,
                    hintText: l.reminderNameHint,
                    prefixIcon: const Icon(Icons.label_outlined),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return l.reminderNameRequired;
                    }
                    if (val.trim().length > 150) {
                      return l.reminderNameTooLong;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 3. Engine Type Selection
                Text(
                  l.engineType,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'time',
                      label: Text(l.timeType),
                      icon: const Icon(Icons.calendar_today_outlined),
                    ),
                    ButtonSegment(
                      value: 'usage',
                      label: Text(l.usageType),
                      icon: const Icon(Icons.repeat_outlined),
                    ),
                    ButtonSegment(
                      value: 'mileage',
                      label: Text(l.mileageType),
                      icon: const Icon(Icons.speed_outlined),
                    ),
                  ],
                  selected: {_engineType},
                  onSelectionChanged:
                      isEdit
                          ? null // Engine type immutable on edit
                          : (newSet) {
                            setState(() => _engineType = newSet.first);
                          },
                ),
                if (isEdit) ...[
                  const SizedBox(height: 4),
                  Text(
                    l.engineTypeImmutable,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // 4. Conditional Engine Fields
                if (_engineType == 'time') ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: const Key('reminder_interval_value'),
                          controller: _intervalValueController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l.intervalValue,
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (_) => setState(() {}),
                          validator: (val) {
                            final parsed = int.tryParse(val ?? '');
                            if (parsed == null || parsed <= 0) {
                              return l.intervalValue;
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _intervalUnit,
                          decoration: InputDecoration(
                            labelText: l.intervalUnit,
                            border: const OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'days',
                              child: Text(l.daysUnit),
                            ),
                            DropdownMenuItem(
                              value: 'weeks',
                              child: Text(l.weeksUnit),
                            ),
                            DropdownMenuItem(
                              value: 'months',
                              child: Text(l.monthsUnit),
                            ),
                            DropdownMenuItem(
                              value: 'years',
                              child: Text(l.yearsUnit),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _intervalUnit = val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: const Key('reminder_target_date'),
                          controller: _targetDateController,
                          readOnly: true,
                          onTap: _pickTargetDate,
                          decoration: InputDecoration(
                            labelText: l.targetDate,
                            prefixIcon: const Icon(Icons.date_range_outlined),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return l.targetDateRequired;
                            }
                            try {
                              parseCalendarDate(val.trim());
                              return null;
                            } catch (_) {
                              return l.targetDateInvalid;
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          key: const Key('reminder_target_time'),
                          controller: _targetTimeController,
                          readOnly: true,
                          onTap: _pickTargetTime,
                          decoration: InputDecoration(
                            labelText: l.targetTime,
                            prefixIcon: const Icon(Icons.access_time_outlined),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    l.baselineMode,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: [
                      ButtonSegment(
                        value: 'actual_completion',
                        label: Text(l.actualCompletion),
                      ),
                      ButtonSegment(
                        value: 'strict_schedule',
                        label: Text(l.strictSchedule),
                      ),
                    ],
                    selected: {_baselineMode},
                    onSelectionChanged: (newSet) {
                      setState(() => _baselineMode = newSet.first);
                    },
                  ),
                ] else if (_engineType == 'usage') ...[
                  TextFormField(
                    key: const Key('reminder_usage_threshold'),
                    controller: _usageThresholdController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l.usageThreshold,
                      hintText: l.usageThresholdHint,
                      prefixIcon: const Icon(Icons.alarm_on_outlined),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (val) {
                      final parsed = int.tryParse(val ?? '');
                      if (parsed == null || parsed <= 0) {
                        return l.usageThresholdPositive;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: const Key('reminder_usage_counter'),
                          controller: _usageCounterController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l.currentUsage,
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (_) => setState(() {}),
                          validator: (val) {
                            final parsed = int.tryParse(val ?? '');
                            if (parsed == null || parsed < 0) {
                              return l.currentUsage;
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          key: const Key('reminder_usage_unit'),
                          controller: _usageUnitController,
                          decoration: InputDecoration(
                            labelText: l.usageUnit,
                            hintText: l.usageUnitHint,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (_engineType == 'mileage') ...[
                  if (_selectedItem != null && !_selectedItem!.hasOdometer)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l.vehicleRequiredForMileage,
                              style: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  TextFormField(
                    key: const Key('reminder_interval_km'),
                    controller: _intervalKmController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l.intervalKm,
                      hintText: l.intervalKmHint,
                      prefixIcon: const Icon(Icons.straighten_outlined),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (val) {
                      final parsed = int.tryParse(val ?? '');
                      if (parsed == null || parsed <= 0) {
                        return l.intervalKmPositive;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    key: const Key('reminder_last_odometer'),
                    controller: _lastServiceOdometerController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l.lastServiceOdometer,
                      prefixIcon: const Icon(Icons.history_outlined),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (val) {
                      final parsed = int.tryParse(val ?? '');
                      if (parsed == null || parsed < 0) {
                        return l.lastServiceOdometerRequired;
                      }
                      return null;
                    },
                  ),
                ],

                // 5. Live Preview
                _buildLivePreview(l),
                const SizedBox(height: 24),

                // 6. Submit Button
                FilledButton.icon(
                  key: const Key('save_reminder_button'),
                  onPressed: _isSaving ? null : _submitForm,
                  icon:
                      _isSaving
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.save_outlined),
                  label: Text(_isSaving ? l.savingReminder : l.save),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
