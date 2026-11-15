import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Mengarahkan sqflite ke implementasi SQLite yang sesuai dengan platform.
/// Pada Web, database disimpan menggunakan IndexedDB melalui SQLite WASM.
void initializeDatabaseFactory() {
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
}

Future<Database> openNotesDb() async {
  // Pastikan factory Web sudah diatur sebelum memanggil openDatabase.
  initializeDatabaseFactory();

  // getDatabasesPath() tidak diperlukan pada Web. Gunakan nama database
  // relatif agar implementasi Web menyimpannya di IndexedDB.
  final dbPath = kIsWeb
      ? 'offline_notes.db'
      : '${await getDatabasesPath()}/offline_notes.db';

  return openDatabase(
    dbPath,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE notes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          body TEXT NOT NULL DEFAULT '',
          updated_at TEXT NOT NULL,
          dirty INTEGER NOT NULL DEFAULT 0
        )
      ''');
      await db.execute('''
        CREATE TABLE cached_posts(
          id INTEGER PRIMARY KEY,
          payload TEXT NOT NULL,
          cached_at TEXT NOT NULL
        )
      ''');
    },
  );
}
