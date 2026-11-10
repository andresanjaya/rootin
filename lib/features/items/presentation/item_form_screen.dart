import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rootin_mobile/core/time/calendar_clock.dart';
import 'package:rootin_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:rootin_mobile/features/items/data/items_repository.dart';
import 'package:rootin_mobile/l10n/generated/app_localizations.dart';

class ItemFormScreen extends ConsumerStatefulWidget {
  const ItemFormScreen({this.itemId, super.key});

  final String? itemId;

  @override
  ConsumerState<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends ConsumerState<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _modelController;
  late final TextEditingController _serialController;
  late final TextEditingController _purchaseDateController;
  late final TextEditingController _odometerController;
  late final TextEditingController _notesController;

  String _category = 'vehicle';
  bool _hasOdometer = true;
  bool _isSaving = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _brandController = TextEditingController();
    _modelController = TextEditingController();
    _serialController = TextEditingController();
    _purchaseDateController = TextEditingController();
    _odometerController = TextEditingController(text: '0');
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _serialController.dispose();
    _purchaseDateController.dispose();
    _odometerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _initFromItem(dynamic item) {
    if (_initialized || item == null) return;
    _initialized = true;
    _nameController.text = item.name;
    _category = item.category;
    _brandController.text = item.brand ?? '';
    _modelController.text = item.modelNumber ?? '';
    _serialController.text = item.serialOrPlateNumber ?? '';
    _purchaseDateController.text = item.purchaseDate ?? '';
    _hasOdometer = item.hasOdometer;
    _odometerController.text = (item.currentOdometer ?? 0).toString();
    _notesController.text = item.notes ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isEdit = widget.itemId != null;

    if (isEdit) {
      final itemAsync = ref.watch(itemDetailStreamProvider(widget.itemId!));
      itemAsync.whenData((item) {
        if (item != null) _initFromItem(item);
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? l.editItem : l.addItem)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const Key('item_name_input'),
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l.itemName,
                  hintText: l.itemNameHint,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l.itemNameRequired;
                  }
                  if (value.trim().length > 150) {
                    return l.reminderNameTooLong;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                key: const Key('item_category_input'),
                value: _category,
                decoration: InputDecoration(labelText: l.category),
                items: [
                  DropdownMenuItem(
                    value: 'vehicle',
                    child: Text(l.categoryVehicle),
                  ),
                  DropdownMenuItem(
                    value: 'appliance',
                    child: Text(l.categoryAppliance),
                  ),
                  DropdownMenuItem(
                    value: 'furniture',
                    child: Text(l.categoryFurniture),
                  ),
                  DropdownMenuItem(
                    value: 'facility',
                    child: Text(l.categoryFacility),
                  ),
                  DropdownMenuItem(
                    value: 'other',
                    child: Text(l.categoryOther),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _category = value;
                      if (value == 'vehicle') {
                        _hasOdometer = true;
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      key: const Key('item_brand_input'),
                      controller: _brandController,
                      decoration: InputDecoration(
                        labelText: l.brand,
                        hintText: l.brandHint,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      key: const Key('item_model_input'),
                      controller: _modelController,
                      decoration: InputDecoration(
                        labelText: l.modelNumber,
                        hintText: l.modelNumberHint,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('item_serial_input'),
                controller: _serialController,
                decoration: InputDecoration(
                  labelText: l.serialOrPlate,
                  hintText: l.serialOrPlateHint,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('item_purchase_date_input'),
                controller: _purchaseDateController,
                decoration: InputDecoration(
                  labelText: l.purchaseDate,
                  hintText: 'YYYY-MM-DD',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1980),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        _purchaseDateController.text = formatCalendarDate(
                          picked,
                        );
                      }
                    },
                  ),
                ),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    try {
                      parseCalendarDate(value.trim());
                    } catch (_) {
                      return l.targetDateInvalid;
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                key: const Key('item_has_odometer_switch'),
                title: Text(l.hasOdometer),
                subtitle: Text(l.hasOdometerDesc),
                value: _hasOdometer,
                onChanged: (val) => setState(() => _hasOdometer = val),
              ),
              if (_hasOdometer) ...[
                const SizedBox(height: 8),
                TextFormField(
                  key: const Key('item_odometer_input'),
                  controller: _odometerController,
                  decoration: InputDecoration(
                    labelText: isEdit ? l.currentOdometer : l.initialOdometer,
                    hintText: l.initialOdometerHint,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (!_hasOdometer) return null;
                    if (value == null || value.trim().isEmpty) {
                      return l.lastServiceOdometerRequired;
                    }
                    final odo = int.tryParse(value.trim());
                    if (odo == null || odo < 0) {
                      return l.intervalKmPositive;
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('item_notes_input'),
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: l.notes,
                  hintText: l.notesHint,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('save_item_button'),
                onPressed: _isSaving ? null : _saveItem,
                child:
                    _isSaving
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : Text(l.save),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isSaving = true);
    final l = AppLocalizations.of(context)!;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final odo =
          _hasOdometer ? int.tryParse(_odometerController.text.trim()) : 0;
      final data = ItemFormData(
        id: widget.itemId,
        name: _nameController.text.trim(),
        category: _category,
        brand:
            _brandController.text.trim().isEmpty
                ? null
                : _brandController.text.trim(),
        modelNumber:
            _modelController.text.trim().isEmpty
                ? null
                : _modelController.text.trim(),
        serialOrPlateNumber:
            _serialController.text.trim().isEmpty
                ? null
                : _serialController.text.trim(),
        purchaseDate:
            _purchaseDateController.text.trim().isEmpty
                ? null
                : _purchaseDateController.text.trim(),
        hasOdometer: _hasOdometer,
        currentOdometer: odo,
        notes:
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
      );

      final id = await ref
          .read(itemsRepositoryProvider)
          .saveItem(userId: user.id, data: data);

      scaffoldMessenger.showSnackBar(SnackBar(content: Text(l.itemSaved)));

      if (mounted) {
        if (widget.itemId != null) {
          context.pop();
        } else {
          context.go('/items/$id');
        }
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(l.itemSaveFailed)));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
