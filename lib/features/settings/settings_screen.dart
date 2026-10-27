import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rootin_mobile/core/database/database_providers.dart';
import 'package:rootin_mobile/core/sync/mobile_sync.dart';
import 'package:rootin_mobile/core/time/calendar_clock.dart';
import 'package:rootin_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:rootin_mobile/features/settings/settings_provider.dart';
import 'package:rootin_mobile/l10n/generated/app_localizations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String? _locale;
  String _distanceUnit = 'km';
  bool _useDeviceZone = true;
  final _timezone = TextEditingController();
  TimeOfDay _reminder = const TimeOfDay(hour: 9, minute: 0);
  bool _loaded = false;

  @override
  void dispose() {
    _timezone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final preferences = ref.watch(userPreferencesProvider);
    if (preferences.isLoading && !_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (preferences.hasError && !_loaded) {
      return Scaffold(
        appBar: AppBar(title: Text(l.settings)),
        body: Center(child: Text(l.settingsFailed)),
      );
    }
    if (!_loaded) {
      final current = preferences.valueOrNull;
      _locale = current?.locale;
      _distanceUnit = current?.distanceUnit ?? 'km';
      _useDeviceZone = current?.timezoneOverride == null;
      _timezone.text = current?.timezoneOverride ?? '';
      final time = (current?.reminderTime ?? '09:00').split(':');
      _reminder = TimeOfDay(
        hour: int.parse(time[0]),
        minute: int.parse(time[1]),
      );
      _loaded = true;
    }
    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: _locale ?? 'system',
              decoration: InputDecoration(labelText: l.language),
              items: [
                DropdownMenuItem(
                  value: 'system',
                  child: Text(l.systemLanguage),
                ),
                DropdownMenuItem(value: 'id', child: Text(l.indonesian)),
                DropdownMenuItem(value: 'en', child: Text(l.english)),
              ],
              onChanged:
                  (value) => setState(
                    () => _locale = value == 'system' ? null : value,
                  ),
            ),
            DropdownButtonFormField<String>(
              value: _distanceUnit,
              decoration: InputDecoration(labelText: l.distanceUnit),
              items: [
                DropdownMenuItem(value: 'km', child: Text(l.kilometers)),
                DropdownMenuItem(value: 'mi', child: Text(l.miles)),
              ],
              onChanged: (value) => setState(() => _distanceUnit = value!),
            ),
            SwitchListTile(
              title: Text(l.deviceTimezone),
              subtitle: Text(ref.watch(deviceTimezoneProvider) ?? l.timezone),
              value: _useDeviceZone,
              onChanged: (value) => setState(() => _useDeviceZone = value),
            ),
            if (!_useDeviceZone)
              TextFormField(
                controller: _timezone,
                decoration: InputDecoration(
                  labelText: l.timezone,
                  hintText: l.timezoneHint,
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  try {
                    locationFor(value ?? '');
                    return null;
                  } on ArgumentError {
                    return l.invalidTimezone;
                  }
                },
              ),
            ListTile(
              title: Text(l.reminderTime),
              subtitle: Text(_reminder.format(context)),
              onTap: () async {
                final selected = await showTimePicker(
                  context: context,
                  initialTime: _reminder,
                );
                if (selected != null) setState(() => _reminder = selected);
              },
            ),
            Text(l.localOnly),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () async {
                try {
                  await ref.read(mobileSyncProvider).run();
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(l.syncFailed)));
                  }
                }
              },
              child: Text(l.syncNow),
            ),
            _conflicts(l),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                final user = ref.read(currentUserProvider);
                if (user == null) return;
                try {
                  await saveUserPreferences(
                    ref.read(appDatabaseProvider),
                    user.id,
                    locale: _locale,
                    distanceUnit: _distanceUnit,
                    timezoneOverride:
                        _useDeviceZone ? null : _timezone.text.trim(),
                    reminderTime:
                        '${_reminder.hour.toString().padLeft(2, '0')}:${_reminder.minute.toString().padLeft(2, '0')}',
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(l.settingsSaved)));
                  }
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(l.settingsFailed)));
                  }
                }
              },
              child: Text(l.save),
            ),
          ],
        ),
      ),
    );
  }

  Widget _conflicts(AppLocalizations l) {
    final userId = ref.watch(currentUserProvider)?.id;
    if (userId == null) return const SizedBox.shrink();
    final db = ref.watch(appDatabaseProvider);
    return StreamBuilder(
      stream:
          (db.select(db.syncOutbox)
            ..where((row) => row.userId.equals(userId))).watch(),
      builder: (context, snapshot) {
        final conflicts =
            snapshot.data?.where((row) => row.status == 'conflict').toList() ??
            [];
        return Column(
          children: [
            for (final row in conflicts)
              ListTile(
                title: Text(
                  l.resolveConflict('${row.entityType} ${row.recordId}'),
                ),
                subtitle: Text(row.errorMessage ?? l.conflictedSync(1)),
                trailing: TextButton(
                  onPressed: () async {
                    final discard = await showDialog<bool>(
                      context: context,
                      builder:
                          (dialogContext) => AlertDialog(
                            title: Text(l.useServerVersion),
                            content: Text(l.conflictWarning),
                            actions: [
                              TextButton(
                                onPressed:
                                    () => Navigator.pop(dialogContext, false),
                                child: Text(l.cancel),
                              ),
                              TextButton(
                                onPressed:
                                    () => Navigator.pop(dialogContext, true),
                                child: Text(l.useServerVersion),
                              ),
                            ],
                          ),
                    );
                    if (discard != true || !context.mounted) return;
                    try {
                      await ref
                          .read(mobileSyncProvider)
                          .acceptServer(userId, row.id);
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(l.syncFailed)));
                      }
                    }
                  },
                  child: Text(l.useServerVersion),
                ),
              ),
          ],
        );
      },
    );
  }
}
