import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
export './store/impl.dart';
export './store/models.dart';

const dbFile = 'mikack.db';

Future<Database> database() async {
  var databasePath = await getDatabasesPath();
  return openDatabase(
    join(databasePath, dbFile),
    onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE sources(id INTEGER PRIMARY KEY AUTOINCREMENT, domain TEXT NOT NULL, name TEXT NOT NULL);');
      await db.execute(
          'CREATE UNIQUE INDEX sources_domain_idx ON sources (domain);');
      await db.execute('CREATE TABLE histories('
          'id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'source_id INTEGER NOT NULL,'
          'title TEXT NOT NULL,'
          'address TEXT NOT NULL,'
          'cover TEXT,'
          'inserted_at TEXT NOT NULL,'
          'FOREIGN KEY(source_id) REFERENCES sources(id)'
          ');');
      await db.execute(
          'CREATE UNIQUE INDEX histories_address_dex ON histories (address);');
      await db.execute('CREATE TABLE favorites('
          'id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'source_id INTEGER NOT NULL,'
          'last_read_history_id INTEGER,'
          'name TEXT NOT NULL,'
          'address TEXT NOT NULL,'
          'cover TEXT,'
          'inserted_chapters_count INTEGER NOT NULL DEFAULT 0,'
          'latest_chapters_count INTEGER NOT NULL DEFAULT 0,'
          'last_read_time TEXT NOT NULL,'
          'inserted_at TEXT NOT NULL,'
          'updated_at TEXT NOT NULL,'
          'FOREIGN KEY(source_id) REFERENCES sources(id),'
          'FOREIGN KEY(last_read_history_id) REFERENCES histories(id)'
          ');');
      await db.execute(
          'CREATE UNIQUE INDEX favorites_address_dex ON favorites (address);');
    },
    version: 1,
  );
}

Future<void> dangerouslyDestory() async {
  var databasePath = await getDatabasesPath();
  return deleteDatabase(join(databasePath, dbFile));
}
