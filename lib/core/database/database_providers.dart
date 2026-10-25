import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rootin_mobile/core/database/database.dart';

/// Riverpod provider for the central [AppDatabase].
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Riverpod provider for [ItemsDao].
final itemsDaoProvider = Provider<ItemsDao>((ref) {
  return ref.watch(appDatabaseProvider).itemsDao;
});

/// Riverpod provider for [RemindersDao].
final remindersDaoProvider = Provider<RemindersDao>((ref) {
  return ref.watch(appDatabaseProvider).remindersDao;
});

/// Riverpod provider for [ReminderLogsDao].
final reminderLogsDaoProvider = Provider<ReminderLogsDao>((ref) {
  return ref.watch(appDatabaseProvider).reminderLogsDao;
});

/// Riverpod provider for [OutboxDao].
final outboxDaoProvider = Provider<OutboxDao>((ref) {
  return ref.watch(appDatabaseProvider).outboxDao;
});
