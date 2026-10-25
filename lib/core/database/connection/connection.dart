import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:rootin_mobile/core/constants/app_constants.dart';

/// Opens a persistent SQLite connection using [NativeDatabase].
// ponytail: uses standard sqlite3 file; upgrade to sqlcipher when secure column encryption is needed.
QueryExecutor openConnection({String? dbName}) {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(
      p.join(dbFolder.path, dbName ?? AppConstants.databaseName),
    );
    return NativeDatabase.createInBackground(file);
  });
}

/// Creates an in-memory database executor for testing.
QueryExecutor openInMemoryConnection({bool logStatements = false}) {
  return NativeDatabase.memory(logStatements: logStatements);
}
