import 'package:drift/drift.dart';
import 'package:rootin_mobile/core/database/database.dart';

part 'items_dao.g.dart';

@DriftAccessor(tables: [Items])
class ItemsDao extends DatabaseAccessor<AppDatabase> with _$ItemsDaoMixin {
  ItemsDao(super.db);

  /// Streams active items for the specified user.
  Stream<List<Item>> watchItems(String userId, {bool includeArchived = false}) {
    final query = select(items)
      ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull());
    if (!includeArchived) {
      query.where((t) => t.isArchived.equals(false));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch();
  }

  /// Gets active items for the specified user.
  Future<List<Item>> getItems(String userId, {bool includeArchived = false}) {
    final query = select(items)
      ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull());
    if (!includeArchived) {
      query.where((t) => t.isArchived.equals(false));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.get();
  }

  /// Gets a single item by ID for the specified user.
  Future<Item?> getItemById(String userId, String id) {
    return (select(items)..where(
      (t) => t.userId.equals(userId) & t.id.equals(id) & t.deletedAt.isNull(),
    )).getSingleOrNull();
  }

  /// Streams a single item by ID for the specified user.
  Stream<Item?> watchItemById(String userId, String id) {
    return (select(items)..where(
      (t) => t.userId.equals(userId) & t.id.equals(id) & t.deletedAt.isNull(),
    )).watchSingleOrNull();
  }

  /// Inserts or replaces an item.
  Future<int> insertItem(
    ItemsCompanion item, {
    InsertMode mode = InsertMode.insertOrReplace,
  }) {
    return into(items).insert(item, mode: mode);
  }

  /// Updates an item scoped to the user.
  Future<bool> updateItem(String userId, ItemsCompanion item) async {
    final count = await (update(items)..where(
      (t) => t.id.equals(item.id.value) & t.userId.equals(userId),
    )).write(item);
    return count > 0;
  }

  /// Soft deletes an item by setting deletedAt and version.
  Future<bool> softDeleteItem(
    String userId,
    String id, {
    required String deletedAt,
    required int version,
    required String updatedAt,
  }) async {
    final count = await (update(items)
      ..where((t) => t.id.equals(id) & t.userId.equals(userId))).write(
      ItemsCompanion(
        deletedAt: Value(deletedAt),
        version: Value(version),
        updatedAt: Value(updatedAt),
      ),
    );
    return count > 0;
  }

  /// Permanently deletes an item scoped to the user.
  Future<int> deleteItemPermanently(String userId, String id) {
    return (delete(items)
      ..where((t) => t.id.equals(id) & t.userId.equals(userId))).go();
  }

  /// Deletes all items belonging to a user (used during account wipe).
  Future<int> deleteAllForUser(String userId) {
    return (delete(items)..where((t) => t.userId.equals(userId))).go();
  }
}
