import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rootin_mobile/core/database/database.dart';
import 'package:rootin_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:rootin_mobile/features/items/data/items_repository.dart';
import 'package:rootin_mobile/l10n/generated/app_localizations.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  const ItemDetailScreen({required this.itemId, super.key});

  final String itemId;

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  bool _isActionInProgress = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final itemAsync = ref.watch(itemDetailStreamProvider(widget.itemId));

    return itemAsync.when(
      loading:
          () => Scaffold(
            appBar: AppBar(title: Text(l.itemDetail)),
            body: const Center(child: CircularProgressIndicator()),
          ),
      error:
          (_, _) => Scaffold(
            appBar: AppBar(title: Text(l.itemDetail)),
            body: Center(child: Text(l.loadFailed)),
          ),
      data: (item) {
        if (item == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l.itemDetail)),
            body: Center(child: Text(l.noItems)),
          );
        }

        final remindersAsync = ref.watch(
          itemRemindersStreamProvider(widget.itemId),
        );
        final reminders = remindersAsync.valueOrNull ?? const [];

        return Scaffold(
          appBar: AppBar(
            title: Text(item.name),
            actions: [
              IconButton(
                key: const Key('edit_item_action'),
                icon: const Icon(Icons.edit_outlined),
                tooltip: l.editItem,
                onPressed: () => context.push('/items/${widget.itemId}/edit'),
              ),
              PopupMenuButton<String>(
                key: const Key('item_more_options'),
                onSelected: (value) {
                  if (value == 'archive') {
                    _handleArchive(item);
                  } else if (value == 'delete') {
                    _handleDelete(item);
                  }
                },
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: 'archive',
                        child: Row(
                          children: [
                            Icon(
                              item.isArchived ? Icons.unarchive : Icons.archive,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              item.isArchived ? l.unarchiveItem : l.archiveItem,
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l.deleteItem,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderCard(context, l, item),
                const SizedBox(height: 16),
                _buildDetailsCard(context, l, item),
                if (item.hasOdometer) ...[
                  const SizedBox(height: 16),
                  _buildOdometerCard(context, l, item),
                ],
                const SizedBox(height: 24),
                _buildRemindersSection(context, l, item, reminders),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(BuildContext context, AppLocalizations l, Item item) {
    final theme = Theme.of(context);
    final categoryLabel = _categoryLabel(l, item.category);

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
                    item.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (item.isArchived)
                  Chip(
                    label: Text(
                      l.archivedReminders,
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    side: BorderSide(color: theme.colorScheme.error),
                    backgroundColor: theme.colorScheme.error.withValues(
                      alpha: 0.1,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(categoryLabel),
                ),
                if (item.hasOdometer) ...[
                  const SizedBox(width: 8),
                  Chip(
                    visualDensity: VisualDensity.compact,
                    avatar: const Icon(Icons.speed, size: 16),
                    label: Text('${item.currentOdometer ?? 0} km'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(
    BuildContext context,
    AppLocalizations l,
    Item item,
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
              l.itemDetail,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            if (item.brand != null && item.brand!.isNotEmpty)
              _buildInfoRow(l.brand, item.brand!),
            if (item.modelNumber != null && item.modelNumber!.isNotEmpty)
              _buildInfoRow(l.modelNumber, item.modelNumber!),
            if (item.serialOrPlateNumber != null &&
                item.serialOrPlateNumber!.isNotEmpty)
              _buildInfoRow(l.serialOrPlate, item.serialOrPlateNumber!),
            if (item.purchaseDate != null && item.purchaseDate!.isNotEmpty)
              _buildInfoRow(l.purchaseDate, item.purchaseDate!),
            if (item.notes != null && item.notes!.isNotEmpty)
              _buildInfoRow(l.notes, item.notes!),
          ],
        ),
      ),
    );
  }

  Widget _buildOdometerCard(
    BuildContext context,
    AppLocalizations l,
    Item item,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.currentOdometer,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.currentOdometer ?? 0} km',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  key: const Key('update_item_odometer_button'),
                  icon: const Icon(Icons.speed),
                  label: Text(l.updateOdometer),
                  onPressed:
                      _isActionInProgress
                          ? null
                          : () => _showUpdateOdometerDialog(context, l, item),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemindersSection(
    BuildContext context,
    AppLocalizations l,
    Item item,
    List<Reminder> reminders,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l.associatedReminders(reminders.length),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              key: const Key('add_item_reminder_button'),
              icon: const Icon(Icons.add),
              label: Text(l.addReminder),
              onPressed: () => context.push('/reminders/new?itemId=${item.id}'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (reminders.isEmpty)
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
                  l.noAssociatedReminders,
                  key: const Key('no_reminders_text'),
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
            itemCount: reminders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              final engineLabel = switch (reminder.engineType) {
                'usage' => l.usageType,
                'mileage' => l.mileageType,
                _ => l.timeType,
              };

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                child: ListTile(
                  title: Text(reminder.name),
                  subtitle: Text(
                    '$engineLabel · ${reminder.targetDate ?? (reminder.engineType == 'mileage' ? '${reminder.intervalKm ?? 0} km' : '${reminder.usageThreshold ?? 0} ${reminder.usageUnit ?? ''}')}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/reminders/${reminder.id}'),
                ),
              );
            },
          ),
      ],
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

  String _categoryLabel(AppLocalizations l, String category) {
    return switch (category) {
      'vehicle' => l.categoryVehicle,
      'appliance' => l.categoryAppliance,
      'furniture' => l.categoryFurniture,
      'facility' => l.categoryFacility,
      _ => l.categoryOther,
    };
  }

  Future<void> _showUpdateOdometerDialog(
    BuildContext context,
    AppLocalizations l,
    Item item,
  ) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

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
                    if (parsed == null || parsed < 0) {
                      return l.intervalKmPositive;
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
                final currentOdo = item.currentOdometer ?? 0;

                Navigator.pop(dialogContext);

                if (newOdo < currentOdo) {
                  // Odometer decrease requires confirmed correction dialog
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder:
                        (confirmCtx) => AlertDialog(
                          title: Text(l.odometerCorrectionConfirm),
                          content: Text(
                            l.odometerCorrectionDesc(newOdo, currentOdo),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(confirmCtx, false),
                              child: Text(l.cancel),
                            ),
                            FilledButton(
                              key: const Key(
                                'confirm_odometer_correction_button',
                              ),
                              onPressed: () => Navigator.pop(confirmCtx, true),
                              child: Text(l.confirmCorrection),
                            ),
                          ],
                        ),
                  );

                  if (confirmed != true) return;
                }

                setState(() => _isActionInProgress = true);

                try {
                  await ref
                      .read(itemsRepositoryProvider)
                      .updateOdometer(
                        userId: user.id,
                        itemId: item.id,
                        newOdometer: newOdo,
                        allowCorrection: true,
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

  Future<void> _handleArchive(Item item) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(item.isArchived ? l.unarchiveItem : l.archiveItem),
            content: Text(
              item.isArchived ? l.confirmUnarchiveItem : l.confirmArchiveItem,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l.cancel),
              ),
              FilledButton(
                key: const Key('confirm_archive_button'),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l.save),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() => _isActionInProgress = true);

    try {
      await ref
          .read(itemsRepositoryProvider)
          .archiveItem(
            userId: user.id,
            itemId: item.id,
            isArchived: !item.isArchived,
          );
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(item.isArchived ? l.itemUnarchived : l.itemArchived),
        ),
      );
    } catch (_) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(l.itemSaveFailed)));
    } finally {
      if (mounted) {
        setState(() => _isActionInProgress = false);
      }
    }
  }

  Future<void> _handleDelete(Item item) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(l.deleteItem),
            content: Text(l.confirmDeleteItem),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l.cancel),
              ),
              FilledButton(
                key: const Key('confirm_delete_button'),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.error,
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l.deleteItem),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() => _isActionInProgress = true);

    try {
      await ref
          .read(itemsRepositoryProvider)
          .deleteItem(userId: user.id, itemId: item.id);
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(l.itemDeleted)));
      if (mounted) {
        context.go('/items');
      }
    } catch (_) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(l.itemDeleteFailed)),
      );
      if (mounted) {
        setState(() => _isActionInProgress = false);
      }
    }
  }
}
