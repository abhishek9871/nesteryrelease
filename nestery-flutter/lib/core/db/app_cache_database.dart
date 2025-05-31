import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

part 'app_cache_database.g.dart';

// Define a simple cache table for DriftCacheStore to use
class CacheEntries extends Table {
  TextColumn get key => text()();
  BlobColumn get value => blob()();
  DateTimeColumn get expiry => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [CacheEntries])
class AppCacheDatabase extends _$AppCacheDatabase {
  final String dbPath;

  AppCacheDatabase({required this.dbPath}) : super(_openConnection(dbPath));

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection(String dbPath) {
  return LazyDatabase(() async {
    return NativeDatabase(File(dbPath));
  });
}
