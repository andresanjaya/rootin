import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rootin_mobile/core/database/database.dart';
import 'package:rootin_mobile/core/database/database_providers.dart';
import 'package:rootin_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:rootin_mobile/features/items/domain/item_rules.dart';
import 'package:rootin_mobile/features/reminders/data/reminders_repository.dart';

/// Form data for creating or editing an item profile.
class ItemFormData {
  const ItemFormData({
    this.id,
    required this.name,
    required this.category,
    this.brand,
    this.modelNumber,
    this.serialOrPlateNumber,
    this.purchaseDate,
    this.hasOdometer = false,
    this.currentOdometer,
    this.photoLocalPath,
    this.photoRemotePath,
    this.notes,
    this.isArchived = false,
  });

  final String? id;
  final String name;
  final String category;
  final String? brand;
  final String? modelNumber;
  final String? serialOrPlateNumber;
  final String? purchaseDate;
  final bool hasOdometer;
  final int? currentOdometer;
  final String? photoLocalPath;
  final String? photoRemotePath;
  final String? notes;
  final bool isArchived;
}

class ItemsRepository {
  ItemsRepository(this.db, this.remindersRepository);

  final AppDatabase db;
  final RemindersRepository remindersRepository;

  /// Saves an item profile (insert or update) with local Drift persistence and sync outbox queue.
  Future<String> saveItem({
    required String userId,
    required ItemFormData data,
  }) async {
    final validation = ItemRules.validateItemForm(
      name: data.name,
      category: data.category,
      purchaseDate: data.purchaseDate,
      hasOdometer: data.hasOdometer,
      currentOdometer: data.currentOdometer,
    );
    if (validation != null) {
      throw ArgumentError('Invalid item data: $validation');
    }

    final isEdit = data.id != null;
    final itemId = data.id ?? generateUuidV4();
    final operationId = generateUuidV4();
    final nowIso = DateTime.now().toUtc().toIso8601String();

    return await db.transaction(() async {
      int nextVersion = 1;
      if (isEdit) {
        final existing = await db.itemsDao.getItemById(userId, itemId);
        if (existing == null) {
          throw StateError(
            'Item not found or does not belong to user: $itemId',
          );
        }
        nextVersion = existing.version + 1;

        await db.itemsDao.updateItem(
          userId,
          ItemsCompanion(
            id: Value(itemId),
            name: Value(data.name.trim()),
            category: Value(data.category),
            brand: Value(data.brand?.trim()),
            modelNumber: Value(data.modelNumber?.trim()),
            serialOrPlateNumber: Value(data.serialOrPlateNumber?.trim()),
            purchaseDate: Value(data.purchaseDate?.trim()),
            hasOdometer: Value(data.hasOdometer),
            currentOdometer: Value(data.currentOdometer ?? 0),
            photoLocalPath: Value(data.photoLocalPath),
            photoRemotePath: Value(data.photoRemotePath),
            notes: Value(data.notes?.trim()),
            version: Value(nextVersion),
            updatedAt: Value(nowIso),
          ),
        );
      } else {
        await db.itemsDao.insertItem(
          ItemsCompanion.insert(
            id: itemId,
            userId: userId,
            name: data.name.trim(),
            category: data.category,
            brand: Value(data.brand?.trim()),
            modelNumber: Value(data.modelNumber?.trim()),
            serialOrPlateNumber: Value(data.serialOrPlateNumber?.trim()),
            purchaseDate: Value(data.purchaseDate?.trim()),
            hasOdometer: Value(data.hasOdometer),
            currentOdometer: Value(data.currentOdometer ?? 0),
            photoLocalPath: Value(data.photoLocalPath),
            photoRemotePath: Value(data.photoRemotePath),
            notes: Value(data.notes?.trim()),
            isArchived: const Value(false),
            createdAt: nowIso,
            updatedAt: nowIso,
            version: const Value(1),
          ),
        );

        if (data.hasOdometer && (data.currentOdometer ?? 0) > 0) {
          final progressId = generateUuidV4();
          await db
              .into(db.progressEvents)
              .insert(
                ProgressEventsCompanion.insert(
                  id: progressId,
                  userId: userId,
                  itemId: itemId,
                  kind: 'odometer',
                  amount: data.currentOdometer!,
                  recordedAt: nowIso,
                ),
              );
        }
      }

      final outboxPayload = {
        'name': data.name.trim(),
        'category': data.category,
        'brand': data.brand?.trim(),
        'model_number': data.modelNumber?.trim(),
        'serial_or_plate_number': data.serialOrPlateNumber?.trim(),
        'purchase_date': data.purchaseDate?.trim(),
        'has_odometer': data.hasOdometer,
        'current_odometer': data.currentOdometer ?? 0,
        'notes': data.notes?.trim(),
        if (!isEdit) 'is_archived': false,
      };

      final outboxRequest = {
        'operation_id': operationId,
        'record_id': itemId,
        'entity_type': 'item',
        'operation_type': isEdit ? 'update' : 'insert',
        'version': isEdit ? nextVersion - 1 : 1,
        'payload': outboxPayload,
      };

      await db.outboxDao.enqueue(
        SyncOutboxCompanion.insert(
          operationId: operationId,
          userId: userId,
          entityType: 'item',
          recordId: itemId,
          operationType: isEdit ? 'update' : 'insert',
          createdAt: nowIso,
          payloadJson: jsonEncode(outboxRequest),
        ),
      );

      return itemId;
    });
  }

  /// Archives or unarchives an item profile.
  Future<void> archiveItem({
    required String userId,
    required String itemId,
    required bool isArchived,
  }) async {
    final existing = await db.itemsDao.getItemById(userId, itemId);
    if (existing == null) {
      throw StateError('Item not found: $itemId');
    }

    final operationId = generateUuidV4();
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final nextVersion = existing.version + 1;

    await db.transaction(() async {
      await db.itemsDao.updateItem(
        userId,
        ItemsCompanion(
          id: Value(itemId),
          isArchived: Value(isArchived),
          version: Value(nextVersion),
          updatedAt: Value(nowIso),
        ),
      );

      final outboxRequest = {
        'operation_id': operationId,
        'record_id': itemId,
        'entity_type': 'item',
        'operation_type': 'update',
        'version': existing.version,
        'payload': {'is_archived': isArchived},
      };

      await db.outboxDao.enqueue(
        SyncOutboxCompanion.insert(
          operationId: operationId,
          userId: userId,
          entityType: 'item',
          recordId: itemId,
          operationType: 'update',
          createdAt: nowIso,
          payloadJson: jsonEncode(outboxRequest),
        ),
      );
    });
  }

  /// Soft deletes an item profile and soft deletes all its associated reminders.
  Future<void> deleteItem({
    required String userId,
    required String itemId,
  }) async {
    final existing = await db.itemsDao.getItemById(userId, itemId);
    if (existing == null) {
      throw StateError('Item not found: $itemId');
    }

    final operationId = generateUuidV4();
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final nextVersion = existing.version + 1;

    await db.transaction(() async {
      await db.itemsDao.softDeleteItem(
        userId,
        itemId,
        deletedAt: nowIso,
        version: nextVersion,
        updatedAt: nowIso,
      );

      // Soft delete associated reminders
      await db.remindersDao.softDeleteRemindersByItem(
        userId,
        itemId,
        deletedAt: nowIso,
        updatedAt: nowIso,
      );

      final outboxRequest = {
        'operation_id': operationId,
        'record_id': itemId,
        'entity_type': 'item',
        'operation_type': 'delete',
        'version': existing.version,
        'payload': {'deleted_at': nowIso},
      };

      await db.outboxDao.enqueue(
        SyncOutboxCompanion.insert(
          operationId: operationId,
          userId: userId,
          entityType: 'item',
          recordId: itemId,
          operationType: 'delete',
          createdAt: nowIso,
          payloadJson: jsonEncode(outboxRequest),
        ),
      );
    });
  }

  /// Updates vehicle odometer with optional confirmation for lower correction.
  Future<String> updateOdometer({
    required String userId,
    required String itemId,
    required int newOdometer,
    bool allowCorrection = false,
  }) {
    return remindersRepository.recordOdometerUpdate(
      userId: userId,
      itemId: itemId,
      newOdometer: newOdometer,
      allowCorrection: allowCorrection,
    );
  }

  /// Streams active or archived items for the user.
  Stream<List<Item>> watchItems(String userId, {bool includeArchived = false}) {
    return db.itemsDao.watchItems(userId, includeArchived: includeArchived);
  }

  /// Streams single item by ID.
  Stream<Item?> watchItemById(String userId, String itemId) {
    return db.itemsDao.watchItemById(userId, itemId);
  }

  /// Streams reminders associated with a specific item.
  Stream<List<Reminder>> watchItemReminders(String userId, String itemId) {
    return db.remindersDao.watchReminders(userId, itemId: itemId);
  }
}

final itemsRepositoryProvider = Provider<ItemsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final remindersRepo = ref.watch(remindersRepositoryProvider);
  return ItemsRepository(db, remindersRepo);
});

final itemDetailStreamProvider = StreamProvider.family<Item?, String>((
  ref,
  itemId,
) {
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) return Stream.value(null);
  return ref.watch(itemsRepositoryProvider).watchItemById(userId, itemId);
});

final itemRemindersStreamProvider =
    StreamProvider.family<List<Reminder>, String>((ref, itemId) {
      final userId = ref.watch(currentUserProvider)?.id;
      if (userId == null) return Stream.value([]);
      return ref
          .watch(itemsRepositoryProvider)
          .watchItemReminders(userId, itemId);
    });

final itemsListProvider = StreamProvider.family<List<Item>, bool>((
  ref,
  includeArchived,
) {
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) return Stream.value([]);
  return ref
      .watch(itemsRepositoryProvider)
      .watchItems(userId, includeArchived: includeArchived);
});
